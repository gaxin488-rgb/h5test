import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.lang.reflect.Array;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.nio.charset.StandardCharsets;
import java.nio.file.AtomicMoveNotSupportedException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.nio.file.StandardOpenOption;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Properties;
import java.util.concurrent.atomic.AtomicBoolean;

/**
 * Fresh exhaustion state machine. It observes the live player, preserves the
 * last map/coordinate, lets the game's native death pipeline return home, then
 * walks back through a matching portal and restores the saved coordinate.
 */
public final class FreshExhaustion {
    private static final String PLAYER_CLASS =
            "com.a.c.f.a.b.j.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75";
    private static final String GAME_CLASS =
            "com.a.c.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75";
    private static final String PLAYER_GETTER =
            "GiRLKUN75NEklliilLliIiwhATDOyOUWanTheREhIhIHiHAHahahOHOHOhEhEHeGiRLkuN75";
    private static final String EXHAUSTION_CHECK =
            "gIrLkun75nEKiLliiliiLiWhATDOYouWAntHeReHiHihIhaHahAHoHohOHEHEheGIrlKUN75";
    private static final String PLAYER_POSITION_FIELD =
            "gIRlKun75NekLLllIlllIlwHAtDOYoUWaNThERehihiHihahahahOhohOhEHEHEGirlkun75";
    private static final String GAME_FIELD =
            "GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75";
    private static final String SCREEN_GETTER =
            "gIrlKuN75NEKIlILIIiLlLWHatDOYouWanthereHihIhiHaHahAhOhoHOhEHEHEGIRLkun75";
    private static final String SCREEN_MAP_FIELD =
            "GIrLkUn75NEkIlillliLIIwhatDOYOUwaNThEREHIHihIHAHAHAHoHoHOHehEhEGIrLKuN75";
    private static final String MAP_NAME_FIELD =
            "GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75";
    private static final String MAP_ID_METHOD = "a_";
    private static final String MOVE_METHOD =
            "GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75";
    private static final long POLL_MILLIS = 500L;
    private static final long ACTION_TIMEOUT_MILLIS = 180_000L;
    private static final float ARRIVAL_RADIUS = 1.5f;

    private static final AtomicBoolean STARTED = new AtomicBoolean();
    private static volatile String LAST_SNAPSHOT_ERROR;
    private static final Path STATE_FILE = Paths.get(
            System.getProperty("user.dir", "."), "tinhlinh-exhaustion-state.properties");
    private static final Path LOG_FILE = Paths.get(
            System.getProperty("java.io.tmpdir", "."), "tinhlinh-exhaustion.log");

    private enum Phase {
        IDLE,
        WAITING_FOR_VILLAGE,
        WAITING_FOR_SAVED_MAP,
        MOVING_TO_SAVED_COORDINATE
    }

    private static final class Snapshot {
        final Object player;
        final Object map;
        final int mapId;
        final String mapName;
        final float x;
        final float y;
        final boolean exhausted;

        Snapshot(Object player, Object map, int mapId, String mapName,
                 float x, float y, boolean exhausted) {
            this.player = player;
            this.map = map;
            this.mapId = mapId;
            this.mapName = mapName;
            this.x = x;
            this.y = y;
            this.exhausted = exhausted;
        }
    }

    private static final class SavedCoordinate {
        final int mapId;
        final String mapName;
        final float x;
        final float y;
        final long savedAt;

        SavedCoordinate(int mapId, String mapName, float x, float y, long savedAt) {
            this.mapId = mapId;
            this.mapName = mapName;
            this.x = x;
            this.y = y;
            this.savedAt = savedAt;
        }
    }

    private static final class RuntimeState {
        Phase phase = Phase.IDLE;
        SavedCoordinate saved;
        boolean previousExhausted;
        long actionStartedAt;
        long forcedAt;
        boolean forced;
        boolean portalMoveIssued;
        int lastMapId = Integer.MIN_VALUE;
        int arrivalSamples;
    }

    private FreshExhaustion() {
    }

    /** Hooked into the game's create() method by WindowPatch. */
    public static void startWatcher() {
        if (!STARTED.compareAndSet(false, true)) {
            return;
        }
        RuntimeState state = new RuntimeState();
        state.saved = loadState();
        log("WATCHER_STARTED phase=" + state.phase + " saved=" + describe(state.saved));
        Thread watcher = new Thread(() -> runLoop(state), "tinhlinh-exhaustion-watcher");
        watcher.setDaemon(true);
        watcher.start();
    }

    private static void runLoop(RuntimeState state) {
        while (true) {
            try {
                Snapshot snapshot = readSnapshot();
                if (snapshot != null) {
                    processSnapshot(state, snapshot);
                }
            } catch (Throwable error) {
                log("WATCHER_ERROR " + compact(error));
            }
            sleep(POLL_MILLIS);
        }
    }

    private static void processSnapshot(RuntimeState state, Snapshot snapshot) {
        if (snapshot.mapId != state.lastMapId) {
            log("MAP_OBSERVED id=" + snapshot.mapId + " name=" + safe(snapshot.mapName)
                    + " x=" + snapshot.x + " y=" + snapshot.y + " phase=" + state.phase);
            state.lastMapId = snapshot.mapId;
        }

        maybeForceDiagnosticExhaustion(state, snapshot);
        boolean newlyExhausted = snapshot.exhausted && !state.previousExhausted;
        state.previousExhausted = snapshot.exhausted;

        if (newlyExhausted && state.phase == Phase.IDLE) {
            state.saved = new SavedCoordinate(snapshot.mapId, snapshot.mapName,
                    snapshot.x, snapshot.y, System.currentTimeMillis());
            persistState(state.saved);
            state.phase = Phase.WAITING_FOR_VILLAGE;
            state.actionStartedAt = System.currentTimeMillis();
            state.portalMoveIssued = false;
            state.arrivalSamples = 0;
            log("EXHAUSTION_DETECTED saved=" + describe(state.saved));
            log("AUTO_VILLAGE_ARMED native_death_pipeline=true");
            return;
        }

        if (state.saved == null || state.phase == Phase.IDLE) {
            return;
        }
        if (timedOut(state)) {
            log("RECOVERY_TIMEOUT phase=" + state.phase + " currentMap=" + snapshot.mapId
                    + " savedMap=" + state.saved.mapId);
            state.phase = Phase.IDLE;
            state.saved = null;
            deleteState();
            return;
        }

        if (state.phase == Phase.WAITING_FOR_VILLAGE) {
            if (!snapshot.exhausted && snapshot.mapId != state.saved.mapId) {
                state.phase = Phase.WAITING_FOR_SAVED_MAP;
                state.actionStartedAt = System.currentTimeMillis();
                log("VILLAGE_RETURN_CONFIRMED map=" + snapshot.mapId + " name="
                        + safe(snapshot.mapName));
            } else if (!snapshot.exhausted && snapshot.mapId == state.saved.mapId) {
                state.phase = Phase.MOVING_TO_SAVED_COORDINATE;
                state.actionStartedAt = System.currentTimeMillis();
                log("VILLAGE_RETURN_SAME_MAP native_respawn=true");
            }
            return;
        }

        if (state.phase == Phase.WAITING_FOR_SAVED_MAP) {
            if (snapshot.mapId == state.saved.mapId && !snapshot.exhausted) {
                state.phase = Phase.MOVING_TO_SAVED_COORDINATE;
                state.actionStartedAt = System.currentTimeMillis();
                state.portalMoveIssued = false;
                log("SAVED_MAP_CONFIRMED id=" + snapshot.mapId + " name="
                        + safe(snapshot.mapName));
            } else if (!state.portalMoveIssued) {
                state.portalMoveIssued = true;
                log("SAVED_MAP_ROUTE_WAITING currentMap=" + snapshot.mapId
                        + " targetMap=" + state.saved.mapId);
                requestPortalRoute(snapshot.map, state.saved);
            }
            return;
        }

        if (state.phase == Phase.MOVING_TO_SAVED_COORDINATE) {
            if (snapshot.mapId != state.saved.mapId) {
                state.phase = Phase.WAITING_FOR_SAVED_MAP;
                state.portalMoveIssued = false;
                log("MAP_CHANGED_DURING_RETURN currentMap=" + snapshot.mapId);
                return;
            }
            float dx = state.saved.x - snapshot.x;
            float dy = state.saved.y - snapshot.y;
            float distance = (float) Math.sqrt(dx * dx + dy * dy);
            if (distance <= ARRIVAL_RADIUS) {
                state.arrivalSamples++;
                log("RETURN_DISTANCE distance=" + distance + " samples=" + state.arrivalSamples);
                if (state.arrivalSamples >= 2) {
                    log("RETURN_COMPLETE map=" + state.saved.mapId + " x=" + state.saved.x
                            + " y=" + state.saved.y);
                    state.phase = Phase.IDLE;
                    state.saved = null;
                    deleteState();
                }
            } else {
                state.arrivalSamples = 0;
                postMove(snapshot.player, state.saved.x, state.saved.y);
                log("RETURN_MOVE targetX=" + state.saved.x + " targetY=" + state.saved.y
                        + " distance=" + distance);
            }
        }
    }

    private static void maybeForceDiagnosticExhaustion(RuntimeState state, Snapshot snapshot) {
        if (state.forced || snapshot.player == null) {
            return;
        }
        String raw = System.getProperty("tinhlinh.test.exhaustionAfterMillis", "").trim();
        if (raw.isEmpty()) {
            return;
        }
        long delay;
        try {
            delay = Long.parseLong(raw);
        } catch (NumberFormatException error) {
            log("DIAGNOSTIC_PROPERTY_INVALID value=" + safe(raw));
            state.forced = true;
            return;
        }
        if (state.forcedAt == 0L) {
            state.forcedAt = System.currentTimeMillis();
        }
        if (System.currentTimeMillis() - state.forcedAt < delay) {
            return;
        }
        state.forced = true;
        post(() -> {
            try {
                Object stats = getField(snapshot.player, "GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75");
                Field hp = findField(stats.getClass(), "GirLKun75NekiiiIIIIiIiwHATDoYoUWANtHERehihIhIHAHAhAHOhOhoHEhehegIrlKUN75");
                hp.set(stats, 0L);
                log("DIAGNOSTIC_EXHAUSTION_INJECTED hp=0");
            } catch (Throwable error) {
                log("DIAGNOSTIC_INJECTION_ERROR " + compact(error));
            }
        });
    }

    private static Snapshot readSnapshot() {
        try {
            Class<?> playerType = Class.forName(PLAYER_CLASS);
            Object player = invokeStatic(playerType, PLAYER_GETTER);
            if (player == null) {
                return null;
            }
            Object game = getStatic(Class.forName(GAME_CLASS), GAME_FIELD);
            Object screen = invoke(game, SCREEN_GETTER);
            Object map = getField(screen, SCREEN_MAP_FIELD);
            Object position = getField(player, PLAYER_POSITION_FIELD);
            int mapId = ((Number) invoke(map, MAP_ID_METHOD)).intValue();
            String mapName = String.valueOf(getField(map, MAP_NAME_FIELD));
            float x = ((Number) getField(position, "x")).floatValue();
            float y = ((Number) getField(position, "y")).floatValue();
            boolean exhausted = (Boolean) invoke(player, EXHAUSTION_CHECK);
            return new Snapshot(player, map, mapId, mapName, x, y, exhausted);
        } catch (Throwable error) {
            String detail = compact(error);
            if (!detail.equals(LAST_SNAPSHOT_ERROR)) {
                LAST_SNAPSHOT_ERROR = detail;
                log("SNAPSHOT_ERROR " + detail);
            }
            return null;
        }
    }

    private static void requestPortalRoute(Object map, SavedCoordinate saved) {
        try {
            Object portal = findPortal(map, saved.mapId, saved.mapName);
            if (portal == null) {
                log("SAVED_MAP_PORTAL_NOT_FOUND targetId=" + saved.mapId
                        + " targetName=" + safe(saved.mapName));
                return;
            }
            float[] target = portalPosition(portal);
            if (target == null) {
                log("SAVED_MAP_PORTAL_POSITION_NOT_FOUND class=" + portal.getClass().getName());
                return;
            }
            Class<?> playerType = Class.forName(PLAYER_CLASS);
            Object player = invokeStatic(playerType, PLAYER_GETTER);
            postMove(player, target[0], target[1]);
            log("SAVED_MAP_PORTAL_MOVE x=" + target[0] + " y=" + target[1]
                    + " class=" + portal.getClass().getName());
        } catch (Throwable error) {
            log("SAVED_MAP_ROUTE_ERROR " + compact(error));
        }
    }

    private static Object findPortal(Object map, int targetId, String targetName) throws Exception {
        for (Field field : allFields(map.getClass())) {
            Object value = field.get(map);
            if (value == null || !value.getClass().getName().equals("com.badlogic.gdx.utils.Array")) {
                continue;
            }
            Object items = getField(value, "items");
            int size = ((Number) getField(value, "size")).intValue();
            for (int i = 0; i < size; i++) {
                Object item = Array.get(items, i);
                if (item != null && portalMatches(item, targetId, targetName)) {
                    return item;
                }
            }
        }
        return null;
    }

    private static boolean portalMatches(Object item, int targetId, String targetName) {
        for (Field field : allFields(item.getClass())) {
            try {
                Object value = field.get(item);
                if (value instanceof Number && ((Number) value).intValue() == targetId) {
                    return true;
                }
                if (value instanceof String && targetName != null
                        && !targetName.isEmpty()
                        && ((String) value).toLowerCase(Locale.ROOT)
                        .contains(targetName.toLowerCase(Locale.ROOT))) {
                    return true;
                }
            } catch (IllegalAccessException ignored) {
                // Field accessibility is configured by allFields().
            }
        }
        return false;
    }

    private static float[] portalPosition(Object item) throws Exception {
        for (Field field : allFields(item.getClass())) {
            Object value = field.get(item);
            if (value == null) {
                continue;
            }
            Class<?> type = value.getClass();
            if (type.getName().equals("com.badlogic.gdx.math.Vector2")
                    || type.getName().equals("com.badlogic.gdx.math.Vector3")) {
                float x = ((Number) getField(value, "x")).floatValue();
                float y = ((Number) getField(value, "y")).floatValue();
                return new float[]{x, y};
            }
        }
        return null;
    }

    private static void postMove(Object player, float x, float y) {
        post(() -> {
            try {
                invoke(player, MOVE_METHOD, new Class<?>[]{float.class, float.class}, x, y);
            } catch (Throwable error) {
                log("MOVE_COMMAND_ERROR " + compact(error));
            }
        });
    }

    private static void post(Runnable action) {
        try {
            Class<?> gdx = Class.forName("com.badlogic.gdx.Gdx");
            Object app = getStatic(gdx, "app");
            invoke(app, "postRunnable", new Class<?>[]{Runnable.class}, action);
        } catch (Throwable error) {
            log("GAME_THREAD_POST_ERROR " + compact(error));
        }
    }

    private static boolean timedOut(RuntimeState state) {
        return state.actionStartedAt > 0L
                && System.currentTimeMillis() - state.actionStartedAt > ACTION_TIMEOUT_MILLIS;
    }

    private static SavedCoordinate loadState() {
        if (!Files.isRegularFile(STATE_FILE)) {
            return null;
        }
        Properties properties = new Properties();
        try (InputStream input = Files.newInputStream(STATE_FILE)) {
            properties.load(input);
            return new SavedCoordinate(
                    Integer.parseInt(properties.getProperty("mapId")),
                    properties.getProperty("mapName", ""),
                    Float.parseFloat(properties.getProperty("x")),
                    Float.parseFloat(properties.getProperty("y")),
                    Long.parseLong(properties.getProperty("savedAt")));
        } catch (Exception error) {
            log("STATE_LOAD_ERROR " + compact(error));
            return null;
        }
    }

    private static void persistState(SavedCoordinate coordinate) {
        Properties properties = new Properties();
        properties.setProperty("mapId", Integer.toString(coordinate.mapId));
        properties.setProperty("mapName", coordinate.mapName == null ? "" : coordinate.mapName);
        properties.setProperty("x", Float.toString(coordinate.x));
        properties.setProperty("y", Float.toString(coordinate.y));
        properties.setProperty("savedAt", Long.toString(coordinate.savedAt));
        Path temporary = STATE_FILE.resolveSibling(STATE_FILE.getFileName() + ".tmp");
        try (OutputStream output = Files.newOutputStream(temporary, StandardOpenOption.CREATE,
                StandardOpenOption.TRUNCATE_EXISTING, StandardOpenOption.WRITE)) {
            properties.store(output, "Fresh exhaustion recovery state");
            try {
                Files.move(temporary, STATE_FILE, StandardCopyOption.REPLACE_EXISTING,
                        StandardCopyOption.ATOMIC_MOVE);
            } catch (AtomicMoveNotSupportedException ignored) {
                Files.move(temporary, STATE_FILE, StandardCopyOption.REPLACE_EXISTING);
            }
        } catch (IOException error) {
            log("STATE_SAVE_ERROR " + compact(error));
        }
    }

    private static void deleteState() {
        try {
            Files.deleteIfExists(STATE_FILE);
        } catch (IOException error) {
            log("STATE_DELETE_ERROR " + compact(error));
        }
    }

    private static void log(String message) {
        String line = System.currentTimeMillis() + " " + message + System.lineSeparator();
        try {
            if (Files.exists(LOG_FILE) && Files.size(LOG_FILE) > 512 * 1024) {
                Files.delete(LOG_FILE);
            }
            Files.writeString(LOG_FILE, line, StandardCharsets.UTF_8,
                    StandardOpenOption.CREATE, StandardOpenOption.APPEND);
        } catch (IOException ignored) {
            // Logging must never interrupt the game loop.
        }
        System.out.print("[FreshExhaustion] " + message + System.lineSeparator());
    }

    private static List<Field> allFields(Class<?> type) {
        List<Field> fields = new ArrayList<>();
        for (Class<?> current = type; current != null; current = current.getSuperclass()) {
            for (Field field : current.getDeclaredFields()) {
                try {
                    field.setAccessible(true);
                    fields.add(field);
                } catch (RuntimeException ignored) {
                    // Strong encapsulation can reject unrelated platform fields.
                }
            }
        }
        return fields;
    }

    private static Field findField(Class<?> type, String name) throws NoSuchFieldException {
        for (Class<?> current = type; current != null; current = current.getSuperclass()) {
            try {
                Field field = current.getDeclaredField(name);
                field.setAccessible(true);
                return field;
            } catch (NoSuchFieldException ignored) {
                // Continue through the inheritance chain.
            }
        }
        throw new NoSuchFieldException(name);
    }

    private static Object getField(Object object, String name) throws Exception {
        return findField(object.getClass(), name).get(object);
    }

    private static Object getStatic(Class<?> type, String name) throws Exception {
        return findField(type, name).get(null);
    }

    private static Object invokeStatic(Class<?> type, String name, Object... arguments) throws Exception {
        return findMethod(type, name, arguments).invoke(null, arguments);
    }

    private static Object invoke(Object receiver, String name, Object... arguments) throws Exception {
        return findMethod(receiver.getClass(), name, arguments).invoke(receiver, arguments);
    }

    private static Object invoke(Object receiver, String name, Class<?>[] types, Object... arguments)
            throws Exception {
        Method method = receiver.getClass().getMethod(name, types);
        method.setAccessible(true);
        return method.invoke(receiver, arguments);
    }

    private static Method findMethod(Class<?> type, String name, Object[] arguments)
            throws NoSuchMethodException {
        for (Class<?> current = type; current != null; current = current.getSuperclass()) {
            for (Method method : current.getDeclaredMethods()) {
                if (!method.getName().equals(name)
                        || method.getParameterCount() != arguments.length) {
                    continue;
                }
                if (compatible(method.getParameterTypes(), arguments)) {
                    method.setAccessible(true);
                    return method;
                }
            }
        }
        throw new NoSuchMethodException(type.getName() + "." + name);
    }

    private static boolean compatible(Class<?>[] types, Object[] arguments) {
        for (int i = 0; i < types.length; i++) {
            if (arguments[i] == null) {
                continue;
            }
            Class<?> boxed = box(types[i]);
            if (!boxed.isAssignableFrom(arguments[i].getClass())) {
                return false;
            }
        }
        return true;
    }

    private static Class<?> box(Class<?> type) {
        if (!type.isPrimitive()) {
            return type;
        }
        if (type == float.class) return Float.class;
        if (type == double.class) return Double.class;
        if (type == int.class) return Integer.class;
        if (type == long.class) return Long.class;
        if (type == boolean.class) return Boolean.class;
        if (type == byte.class) return Byte.class;
        if (type == short.class) return Short.class;
        if (type == char.class) return Character.class;
        return type;
    }

    private static void sleep(long millis) {
        try {
            Thread.sleep(millis);
        } catch (InterruptedException interrupted) {
            Thread.currentThread().interrupt();
        }
    }

    private static String describe(SavedCoordinate coordinate) {
        if (coordinate == null) {
            return "none";
        }
        return "map=" + coordinate.mapId + ",name=" + safe(coordinate.mapName)
                + ",x=" + coordinate.x + ",y=" + coordinate.y;
    }

    private static String safe(String value) {
        return value == null ? "" : value.replace('\n', ' ').replace('\r', ' ');
    }

    private static String compact(Throwable error) {
        Throwable cause = error;
        while (cause.getCause() != null && cause.getCause() != cause) {
            cause = cause.getCause();
        }
        return cause.getClass().getSimpleName() + ":" + safe(cause.getMessage());
    }
}
