package com.a.d;

import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.math.Vector2;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.Writer;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.lang.reflect.Modifier;
import java.lang.reflect.Array;
import java.nio.charset.StandardCharsets;
import java.util.Collections;
import java.util.IdentityHashMap;
import java.util.Set;

public final class AutoReconnect extends AutoReconnectBase {
    private static final long POSITION_MAX_AGE_MS = 604800000L;
    private static final long RETURN_TIMEOUT_MS = 60000L;
    private static final float RETURN_RADIUS = 3.0f;
    private static volatile boolean coordinateWatcherStarted;
    private static volatile boolean positionValid;
    private static volatile boolean returnActive;
    private static volatile int positionMapId = -1;
    private static volatile String positionMapName = "";
    private static volatile float positionX;
    private static volatile float positionY;
    private static volatile long positionSavedAt;
    private static volatile long returnStartedAt;
    private static volatile long lastMoveCommandAt;
    private static volatile long lastExhaustionTriggerAt;
    private static volatile boolean autoAttackRequested;
    private static volatile long lastAutoAttackAttemptAt;
    private static final long EMPTY_MAP_CONFIRM_MS = 3000L;
    private static final long EMPTY_MAP_REISSUE_MS = 2500L;
    private static final long EMPTY_MAP_NOTICE_MS = 10000L;
    private static final float START_GATE_RADIUS = 5.0f;
    private static volatile String emptyMapCandidateKey = "";
    private static volatile long emptyMapCandidateSince;
    private static volatile String emptyMapHandledKey = "";
    private static volatile long lastEmptyMapCommandAt;
    private static volatile long lastEmptyMapNoticeAt;
    private static volatile float emptyGateX;
    private static volatile float emptyGateY;

    private AutoReconnect() {
    }

    public static synchronized void startWatcher() {
        configureTestFarmMap();
        AutoReconnectBase.startWatcher();
        if (coordinateWatcherStarted) {
            return;
        }
        coordinateWatcherStarted = true;
        loadPosition();
        Thread watcher = new Thread(new Runnable() {
            @Override
            public void run() {
                watchExhaustionAndReturn();
            }
        }, "Exhaustion-Coordinate-Watcher");
        watcher.setDaemon(true);
        watcher.start();
    }

    private static void configureTestFarmMap() {
        if (!"5".equals(System.getProperty("tinhlinh.test.map"))) {
            return;
        }
        try {
            setBaseInt("lastFarmMapId", 5);
            setBaseString("lastFarmMapName", "Vách núi Eldarah");
            log("[AutoFarm] Test override: chon map 5 - Vách núi Eldarah.");
        }
        catch (Throwable throwable) {
            log("[AutoFarm] Loi chon map test 5: " + throwable.getMessage());
        }
    }

    private static void watchExhaustionAndReturn() {
        while (true) {
            try {
                Thread.sleep(800L);
                Object player = currentPlayer();
                if (player == null) {
                    autoAttackRequested = false;
                    continue;
                }
                ensureAutoAttackForSession(player);
                String mapName = AutoReconnectBase.getCurrentMapName();
                if (mapName == null || mapName.trim().isEmpty()) {
                    continue;
                }
                int mapId = currentMapId();
                Vector2 position = playerPosition(player);
                if (isExhausted(player)) {
                    captureAndReturn(mapId, mapName, position);
                    continue;
                }
                if (positionValid && !returnActive && isSavedMap(mapName, mapId)) {
                    returnActive = true;
                    returnStartedAt = System.currentTimeMillis();
                    lastMoveCommandAt = 0L;
                    log("[AutoFarm] Da vao lai map luu toa do kiet suc -> bat dau quay lai vi tri cu.");
                }
                if (returnActive && isSavedMap(mapName, mapId)) {
                    guideBackToPosition(player, mapName, mapId, position);
                }
                if (!returnActive) {
                    handleEmptyMobMap(player, mapName, mapId, position);
                }
            }
            catch (InterruptedException interrupted) {
                Thread.currentThread().interrupt();
                return;
            }
            catch (Throwable throwable) {
                log("[AutoFarm] Loi watcher toa do kiet suc: " + throwable.getMessage());
            }
        }
    }

    private static boolean isExhausted(Object player) {
        try {
            Method defeated = player.getClass().getMethod(
                "gIrLkun75nEKiLliiliiLiWhATDOYouWAntHeReHiHihIhaHahAHoHohOHEHEheGIrlKUN75");
            Object result = defeated.invoke(player);
            if (Boolean.TRUE.equals(result)) {
                return true;
            }
        }
        catch (Throwable ignored) {
        }
        try {
            int[] stamina = AutoReconnectBase.getPlayerTheLuc();
            return stamina != null && stamina.length > 1 && stamina[1] > 0 && stamina[0] <= 0;
        }
        catch (Throwable ignored) {
            return false;
        }
    }

    private static void ensureAutoAttackForSession(Object player) {
        long now = System.currentTimeMillis();
        if (autoAttackRequested || now - lastAutoAttackAttemptAt < 5000L) {
            return;
        }
        try {
            Class<?> expectedType = Class.forName(
                "com.a.c.f.a.b.j.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75");
            if (!expectedType.isInstance(player)) {
                return;
            }
        }
        catch (Throwable ignored) {
            return;
        }
        lastAutoAttackAttemptAt = now;
        try {
            enableAutoAttack(player);
            autoAttackRequested = true;
            log("[AutoFarm] Da gui lenh bat menu Tu Dong Tan Cong sau khi vao game.");
        }
        catch (Throwable throwable) {
            log("[AutoFarm] Loi bat menu Tu Dong Tan Cong: " + throwable.getMessage());
        }
    }

    private static void captureAndReturn(int mapId, String mapName, Vector2 position) {
        String normalized = AutoReconnectBase.normalize(mapName);
        if (normalized.contains("lang") || normalized.contains("nong trai")
            || AutoReconnectBase.isIntermediateTransitMap(mapName)) {
            return;
        }
        long now = System.currentTimeMillis();
        if (now - lastExhaustionTriggerAt < 3000L) {
            return;
        }
        lastExhaustionTriggerAt = now;
        if (position != null) {
            savePosition(mapId, mapName, position);
        }
        AutoReconnectBase.sendReturnToVillage("KietSuc_ToaDo");
        log("[AutoFarm] Kiet suc -> tu dong ve lang; giu muc tieu toa do da luu.");
    }

    private static void guideBackToPosition(final Object player, String mapName, int mapId, Vector2 position) {
        if (!positionValid || !isSavedMap(mapName, mapId)) {
            returnActive = false;
            return;
        }
        long now = System.currentTimeMillis();
        if (now - positionSavedAt > POSITION_MAX_AGE_MS) {
            clearPosition("qua han");
            return;
        }
        if (returnStartedAt == 0L) {
            returnStartedAt = now;
        }
        setBaseFlag("isReturningToFarm", false);
        setBaseFlag("isWalkingToEndOfMap", false);
        if (now - returnStartedAt > RETURN_TIMEOUT_MS) {
            log("[AutoFarm] Khong toi duoc toa do kiet suc sau " + RETURN_TIMEOUT_MS / 1000L + " giay.");
            clearPosition("timeout quay lai");
            return;
        }
        if (position == null) {
            return;
        }
        float distance = (float)Math.hypot(position.x - positionX, position.y - positionY);
        if (distance <= RETURN_RADIUS) {
            log("[AutoFarm] Da quay lai toa do kiet suc: x=" + format(positionX)
                + " y=" + format(positionY) + " lech=" + format(distance));
            clearPosition("da den dich");
            postToGame(new Runnable() {
                @Override
                public void run() {
                    try {
                        enableAutoAttack(currentPlayer());
                    }
                    catch (Throwable throwable) {
                        log("[AutoFarm] Loi bat lai tu dong danh: " + throwable.getMessage());
                    }
                }
            });
            return;
        }
        if (now - lastMoveCommandAt >= 1000L) {
            lastMoveCommandAt = now;
            final float targetX = positionX;
            final float targetY = positionY;
            postToGame(new Runnable() {
                @Override
                public void run() {
                    issuePositionCommand(player, targetX, targetY);
                }
            });
        }
    }

    private static void handleEmptyMobMap(final Object player, String mapName, int mapId, Vector2 position) {
        String normalized = AutoReconnectBase.normalize(mapName);
        if (normalized.contains("lang") || normalized.contains("nong trai")
            || AutoReconnectBase.isIntermediateTransitMap(mapName)) {
            resetEmptyMapState();
            return;
        }
        String mapKey = mapId + "|" + normalized;
        Object screen = AutoReconnectBase.getGameScreen();
        if (screen == null) {
            return;
        }
        if (hasActiveMob(screen)) {
            resetEmptyMapState();
            return;
        }
        long now = System.currentTimeMillis();
        if (!mapKey.equals(emptyMapCandidateKey)) {
            emptyMapCandidateKey = mapKey;
            emptyMapCandidateSince = now;
            emptyMapHandledKey = "";
            log("[AutoFarm] Map chua co mob, dang cho xac nhan: " + mapName + ".");
            return;
        }
        if (now - emptyMapCandidateSince < EMPTY_MAP_CONFIRM_MS
            || mapKey.equals(emptyMapHandledKey)) {
            return;
        }
        Object gate = findStartingGate(screen);
        if (gate == null) {
            if (now - lastEmptyMapNoticeAt >= EMPTY_MAP_NOTICE_MS) {
                lastEmptyMapNoticeAt = now;
                log("[AutoFarm] Map khong co mob nhung khong tim thay cong dau map: " + mapName + ".");
            }
            return;
        }
        Vector2 gatePosition = waypointPosition(gate);
        if (gatePosition == null) {
            return;
        }
        emptyGateX = gatePosition.x;
        emptyGateY = gatePosition.y;
        if (position != null && (float)Math.hypot(position.x - emptyGateX, position.y - emptyGateY)
            <= START_GATE_RADIUS) {
            emptyMapHandledKey = mapKey;
            log("[AutoFarm] Da toi cong dau map khi map khong co mob: " + mapName + ".");
            return;
        }
        if (now - lastEmptyMapCommandAt < EMPTY_MAP_REISSUE_MS) {
            return;
        }
        lastEmptyMapCommandAt = now;
        final float targetX = emptyGateX;
        final float targetY = emptyGateY;
        postToGame(new Runnable() {
            @Override
            public void run() {
                issuePositionCommand(player, targetX, targetY);
            }
        });
        log("[AutoFarm] Map khong co mob -> di chuyen ve cong dau map: x="
            + format(emptyGateX) + " y=" + format(emptyGateY) + ".");
    }

    private static void resetEmptyMapState() {
        emptyMapCandidateKey = "";
        emptyMapCandidateSince = 0L;
        emptyMapHandledKey = "";
        lastEmptyMapCommandAt = 0L;
        lastEmptyMapNoticeAt = 0L;
    }

    private static boolean hasActiveMob(Object root) {
        Set<Object> visited = Collections.newSetFromMap(new IdentityHashMap<Object, Boolean>());
        return containsActiveMob(root, 0, visited);
    }

    private static boolean containsActiveMob(Object value, int depth, Set<Object> visited) {
        if (value == null || depth > 8) {
            return false;
        }
        Class<?> type = value.getClass();
        if (isActiveMob(value)) {
            return true;
        }
        if (type == String.class || type.isPrimitive() || value instanceof Number
            || value instanceof Boolean || value instanceof Enum<?>) {
            return false;
        }
        if (!visited.add(value)) {
            return false;
        }
        if (type.isArray()) {
            int length = Math.min(Array.getLength(value), 300);
            for (int i = 0; i < length; i++) {
                if (containsActiveMob(Array.get(value, i), depth + 1, visited)) {
                    return true;
                }
            }
            return false;
        }
        if (value instanceof Iterable<?>) {
            int count = 0;
            for (Object item : (Iterable<?>)value) {
                if (containsActiveMob(item, depth + 1, visited)) {
                    return true;
                }
                if (++count >= 300) {
                    break;
                }
            }
            return false;
        }
        if (type.getName().equals("com.badlogic.gdx.utils.Array")) {
            Object items;
            try {
                items = fieldValue(value, "items");
            }
            catch (Throwable ignored) {
                return false;
            }
            if (items == null || !items.getClass().isArray()) {
                return false;
            }
            int size = numberField(value, "size", Array.getLength(items));
            int length = Math.min(Math.min(size, 300), Array.getLength(items));
            for (int i = 0; i < length; i++) {
                if (containsActiveMob(Array.get(items, i), depth + 1, visited)) {
                    return true;
                }
            }
            return false;
        }
        if (!type.getName().startsWith("com.a.")) {
            return false;
        }
        Class<?> current = type;
        while (current != null && current.getName().startsWith("com.a.")) {
            for (Field field : current.getDeclaredFields()) {
                if (Modifier.isStatic(field.getModifiers()) || field.isSynthetic()
                    || field.getType().isPrimitive() || field.getType() == String.class) {
                    continue;
                }
                try {
                    field.setAccessible(true);
                    if (containsActiveMob(field.get(value), depth + 1, visited)) {
                        return true;
                    }
                }
                catch (Throwable ignored) {
                }
            }
            current = current.getSuperclass();
        }
        return false;
    }

    private static boolean isActiveMob(Object value) {
        String className = value.getClass().getName();
        if (!className.startsWith("com.a.c.f.a.b.g.") || className.startsWith("com.a.c.f.a.b.g.a.")) {
            return false;
        }
        try {
            Method alive = value.getClass().getMethod(
                "gIrLkun75nEKiLliiliiLiWhATDOYouWAntHeReHiHihIhaHahAHoHohOHEHEheGIrlKUN75");
            return !Boolean.FALSE.equals(alive.invoke(value));
        }
        catch (Throwable ignored) {
            return true;
        }
    }

    private static Object findStartingGate(Object screen) {
        try {
            Object map = fieldValue(screen,
                "GIrLkUn75NEkIlillliLIIwhatDOYouwaNThEREHIHihIHAHAHAHoHoHOHehEhEGIrLKuN75");
            Object waypoints = fieldValue(map,
                "GIRLkuN75nEkLlLiiLIlLlwhATdoYouwaNtherEHiHiHihaHaHAHOHOHoHehEHeGIrlKun75");
            if (waypoints == null) {
                return null;
            }
            Object first = null;
            Vector2 firstPosition = null;
            int size = numberField(waypoints, "size", 0);
            Object items = fieldValue(waypoints, "items");
            if (items == null || !items.getClass().isArray()) {
                return null;
            }
            size = Math.min(size, Array.getLength(items));
            for (int i = 0; i < size; i++) {
                Object waypoint = Array.get(items, i);
                Vector2 position = waypointPosition(waypoint);
                if (position != null && (firstPosition == null || position.x < firstPosition.x)) {
                    first = waypoint;
                    firstPosition = position;
                }
            }
            return first;
        }
        catch (Throwable ignored) {
            return null;
        }
    }

    private static Vector2 waypointPosition(Object waypoint) {
        if (waypoint == null) {
            return null;
        }
        try {
            Method getter = waypoint.getClass().getMethod(
                "gIRLkuN75nEKliLILiiLiiWhAtDOYOUwAnTherehiHihIHAHAhaHOhohohEheHEgIRlKUN75");
            Object result = getter.invoke(waypoint);
            return result instanceof Vector2 ? new Vector2((Vector2)result) : null;
        }
        catch (Throwable ignored) {
            return null;
        }
    }

    private static int numberField(Object target, String name, int fallback) {
        try {
            Object value = fieldValue(target, name);
            return value instanceof Number ? ((Number)value).intValue() : fallback;
        }
        catch (Throwable ignored) {
            return fallback;
        }
    }

    private static Object currentPlayer() {
        try {
            Class<?> playerClass = Class.forName("com.a.c.f.a.b.j.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75");
            Method getter = playerClass.getMethod("GiRLKUN75NEklliilLliIiwhATDOyOUWanTheREhIhIHiHAHahahOHOHOhEhEHeGiRLkuN75");
            Object player = getter.invoke(null);
            if (player != null) {
                return player;
            }
        }
        catch (Throwable throwable) {
        }
        try {
            Object screen = AutoReconnectBase.getGameScreen();
            return fieldValue(screen,
                "GIRLkuN75nEkLlLiiLIlLlwhATdoYouwaNtherEHiHiHihaHaHAHOHOHoHehEHeGIrlKun75");
        }
        catch (Throwable ignored) {
            return null;
        }
    }

    private static Vector2 playerPosition(Object player) {
        try {
            Object result = fieldValue(player,
                "gIRlKun75NekLLllIlllIlwHAtDOYoUWaNThERehihiHihahahahOhohOhEHEHEGirlkun75");
            if (result instanceof Vector2) {
                return new Vector2((Vector2)result);
            }
        }
        catch (Throwable ignored) {
        }
        String[] getterNames = {
            "gIRlKun75NekLLllIlllIlwHAtDOYoUWaNThERehihiHihahahahOhohOhEHEHEGirlkun75",
            "gIRLkuN75nEKliLILiiLiiWhAtDOYOUwAnTherehiHihIHAHAhaHOhohohEheHEgIRlKUN75"
        };
        for (String getterName : getterNames) {
            try {
                Method getter = player.getClass().getMethod(getterName);
                Object result = getter.invoke(player);
                if (result instanceof Vector2) {
                    return new Vector2((Vector2)result);
                }
            }
            catch (Throwable ignored) {
            }
        }
        return null;
    }

    private static int currentMapId() {
        try {
            Class<?> appClass = Class.forName("com.a.c.GIRLKUn75NEKLiIILilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75");
            Object app = staticField(appClass, "GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75");
            Object screen = app.getClass().getMethod("gIrlKuN75NEKIlILIIiLlLWHatDOYouWanthereHihIhiHaHahAhOhoHOhEHEHEGIRLkun75").invoke(app);
            Object map = fieldValue(screen, "GIrLkUn75NEkIlillliLIIwhatDOYOUwaNThEREHIHihIHAHAHAHoHoHOHehEhEGIrLKuN75");
            Object id = map.getClass().getMethod("a_").invoke(map);
            return id instanceof Number ? ((Number)id).intValue() : -1;
        }
        catch (Throwable throwable) {
            return -1;
        }
    }

    private static void issuePositionCommand(Object player, float targetX, float targetY) {
        try {
            Object controller = fieldValue(player, "girLKUn75nEkLiLLlIllLIWhAtdOyouWaNTHErehIHiHiHahAhAHOHoHohEhEHegirLkUN75");
            if (controller == null) {
                return;
            }
            for (Method method : controller.getClass().getMethods()) {
                if (method.getName().equals("GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75")
                    && method.getParameterTypes().length == 3) {
                    method.invoke(controller, Float.valueOf(targetX), Float.valueOf(targetY), null);
                    log("[AutoFarm] Dang quay lai toa do kiet suc: x=" + format(targetX) + " y=" + format(targetY));
                    return;
                }
            }
        }
        catch (Throwable throwable) {
            log("[AutoFarm] Loi lenh quay lai toa do: " + throwable.getMessage());
        }
    }

    private static boolean isSavedMap(String mapName, int mapId) {
        if (!positionValid) {
            return false;
        }
        return mapId >= 0 && mapId == positionMapId
            || AutoReconnectBase.isMapMatch(mapName, positionMapName);
    }

    private static void savePosition(int mapId, String mapName, Vector2 position) {
        String safeName = mapName.trim().replace('|', ' ');
        long savedAt = System.currentTimeMillis();
        try (Writer writer = new OutputStreamWriter(new FileOutputStream(new File("last_farm_map_position.txt")), StandardCharsets.UTF_8)) {
            writer.write(mapId + "|" + safeName + "|" + position.x + "|" + position.y + "|" + savedAt);
            positionMapId = mapId;
            positionMapName = safeName;
            positionX = position.x;
            positionY = position.y;
            positionSavedAt = savedAt;
            positionValid = true;
            returnActive = false;
            log("[AutoFarm] Da luu toa do kiet suc: map=" + safeName + " (ID=" + mapId
                + ") x=" + format(position.x) + " y=" + format(position.y));
        }
        catch (Throwable throwable) {
            log("[AutoFarm] Loi luu toa do kiet suc: " + throwable.getMessage());
        }
    }

    private static void loadPosition() {
        File file = new File("last_farm_map_position.txt");
        if (!file.exists()) {
            return;
        }
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(new FileInputStream(file), StandardCharsets.UTF_8))) {
            String[] parts = reader.readLine().split("\\|", -1);
            if (parts.length != 5) {
                return;
            }
            positionMapId = Integer.parseInt(parts[0]);
            positionMapName = parts[1].trim();
            positionX = Float.parseFloat(parts[2]);
            positionY = Float.parseFloat(parts[3]);
            positionSavedAt = Long.parseLong(parts[4]);
            positionValid = !positionMapName.isEmpty()
                && System.currentTimeMillis() - positionSavedAt <= POSITION_MAX_AGE_MS;
            if (positionValid) {
                log("[AutoFarm] Da nap toa do kiet suc: map=" + positionMapName + " (ID=" + positionMapId
                    + ") x=" + format(positionX) + " y=" + format(positionY));
            }
        }
        catch (Throwable throwable) {
            log("[AutoFarm] Loi nap toa do kiet suc: " + throwable.getMessage());
        }
    }

    private static void clearPosition(String reason) {
        boolean hadPosition = positionValid;
        positionValid = false;
        returnActive = false;
        positionMapId = -1;
        positionMapName = "";
        positionX = 0.0f;
        positionY = 0.0f;
        positionSavedAt = 0L;
        returnStartedAt = 0L;
        lastMoveCommandAt = 0L;
        File file = new File("last_farm_map_position.txt");
        if (file.exists() && !file.delete()) {
            log("[AutoFarm] Khong xoa duoc file toa do sau khi " + reason + ".");
        }
        if (hadPosition) {
            log("[AutoFarm] Da xoa toa do kiet suc: " + reason + ".");
        }
    }

    private static void setBaseFlag(String name, boolean value) {
        try {
            Field field = AutoReconnectBase.class.getDeclaredField(name);
            field.setAccessible(true);
            field.setBoolean(null, value);
        }
        catch (Throwable ignored) {
        }
    }

    private static void setBaseInt(String name, int value) throws Exception {
        Field field = AutoReconnectBase.class.getDeclaredField(name);
        field.setAccessible(true);
        field.setInt(null, value);
    }

    private static void setBaseString(String name, String value) throws Exception {
        Field field = AutoReconnectBase.class.getDeclaredField(name);
        field.setAccessible(true);
        field.set(null, value);
    }

    private static Object staticField(Class<?> type, String name) throws Exception {
        Field field = type.getDeclaredField(name);
        field.setAccessible(true);
        return field.get(null);
    }

    private static Object fieldValue(Object target, String name) throws Exception {
        Class<?> type = target.getClass();
        while (type != null) {
            try {
                Field field = type.getDeclaredField(name);
                field.setAccessible(true);
                return field.get(target);
            }
            catch (NoSuchFieldException ignored) {
                type = type.getSuperclass();
            }
        }
        return null;
    }

    private static void postToGame(Runnable runnable) {
        try {
            if (Gdx.app != null) {
                Gdx.app.postRunnable(runnable);
            }
        }
        catch (Throwable throwable) {
            log("[AutoFarm] Loi dua lenh ve game thread: " + throwable.getMessage());
        }
    }

    private static void enableAutoAttack(Object player) throws Exception {
        if (player == null) {
            return;
        }
        Class<?> playerType = Class.forName("com.a.c.f.a.b.j.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75");
        Method method = AutoReconnectBase.class.getMethod("ensureAutoAttackEnabled", playerType);
        method.invoke(null, player);
    }

    private static String format(float value) {
        return String.format("%.2f", value);
    }

    private static void log(String message) {
        System.out.println(message);
    }
}
