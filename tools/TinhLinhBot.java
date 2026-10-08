import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.lang.reflect.Method;
import java.lang.reflect.Modifier;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;
import java.util.Properties;
import java.util.concurrent.atomic.AtomicBoolean;

import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.Screen;
import com.badlogic.gdx.backends.lwjgl3.Lwjgl3Graphics;
import com.badlogic.gdx.backends.lwjgl3.Lwjgl3Window;
import com.badlogic.gdx.math.Vector2;
import com.badlogic.gdx.scenes.scene2d.Actor;
import com.badlogic.gdx.scenes.scene2d.EventListener;
import com.badlogic.gdx.scenes.scene2d.Group;
import com.badlogic.gdx.scenes.scene2d.InputEvent;
import com.badlogic.gdx.scenes.scene2d.ui.Button;
import com.badlogic.gdx.scenes.scene2d.ui.Label;
import com.badlogic.gdx.scenes.scene2d.utils.ChangeListener;
import com.badlogic.gdx.scenes.scene2d.utils.ClickListener;
import com.badlogic.gdx.utils.Pools;
import com.badlogic.gdx.utils.SnapshotArray;
import org.lwjgl.glfw.GLFW;

/**
 * TinhLinhBot - Core Automation Engine for Tinh Linh Game.
 * Feature 1: Auto Login, Auto Reconnect & Watchdog Lifecycle.
 * Feature 2: Map & Location Telemetry (getCurrentMapName, getCurrentMapId, getCurrentZone, getPlayerPosition).
 * Feature 3: Exhaustion Coordinate Saving & State Persistence (saveExhaustionCoordinate, isExhaustionDialogVisible).
 * Feature 4: Auto Select Return to Village Menu upon Exhaustion (autoSelectReturnToVillage).
 */
public final class TinhLinhBot {
    private static final String VERSION = "1.3.0-Feature4-AutoVillage";
    private static final long POLL_INTERVAL_MS = 800L;
    private static final long LOADING_TIMEOUT_MS = 180_000L;
    private static final long MAX_LOG_FILE_BYTES = 3 * 1024 * 1024; // 3MB

    private static final AtomicBoolean STARTED = new AtomicBoolean(false);
    private static volatile boolean isLoggingIn = false;
    private static volatile boolean wasInGame = false;
    private static volatile int loginAttempts = 0;
    private static volatile long gameStartTime = 0L;
    private static volatile long lastLoginAttemptTime = 0L;
    private static volatile long loadingScreenStartTime = 0L;
    private static volatile long lastGuardCheckTime = 0L;

    private static volatile int lastKnownMapId = -1;
    private static volatile String lastKnownMapName = "";
    private static volatile int lastKnownZone = -1;
    private static volatile long lastMapLogTime = 0L;

    private static volatile SavedCoordinate lastSavedExhaustionCoord = null;
    private static volatile boolean previousExhausted = false;
    private static volatile long lastVillageSelectAttemptTime = 0L;
    private static final String EXHAUSTION_STATE_FILE = "tinhlinh-exhaustion-state.properties";
    private static final String EXHAUSTION_COORD_FILE = "saved_exhaustion_coord.txt";
    private static final String LAST_FARM_MAP_FILE = "last_farm_map.txt";

    private static volatile String savedUsername = null;
    private static volatile String savedPassword = null;

    private static final SimpleDateFormat DATE_FORMAT = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

    private TinhLinhBot() {
    }

    /**
     * Call-site hook: Injected into com.a.c.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75.create()
     * Starts the background daemon watcher thread once the LibGDX application is created.
     */
    public static void startWatcher() {
        if (!STARTED.compareAndSet(false, true)) {
            return;
        }

        gameStartTime = System.currentTimeMillis();
        loadSavedAccount();

        log("========================================================");
        log(" [TinhLinhBot] He Thong Auto Login & Watchdog Bat Dau!");
        log(" Phien Ban: " + VERSION);
        log(" Tai khoan mac dinh: " + (savedUsername != null ? savedUsername : "(chua co)"));
        log(" Auto Login Enabled: " + isAutoLoginEnabled());
        log("========================================================");

        Thread watcher = new Thread(TinhLinhBot::runWatcherLoop, "AutoFarm-Watcher");
        watcher.setDaemon(true);
        watcher.start();
    }

    /**
     * Fallback hook: Injected by WindowPatch into AtlasLoader.findRegion()
     * Prevents game crash when headless/Mesa driver fails to load a specific sprite region.
     */
    public static void recordAtlasFallback() {
        log("[AtlasFallback] Phat hien thieu AtlasRegion -> Da su dung fallback texture dau tien.");
    }

    private static void runWatcherLoop() {
        log("[AutoFarm-Watcher] Vong lap giam sat 800ms da bat dau.");
        while (true) {
            try {
                Thread.sleep(POLL_INTERVAL_MS);
                tick();
            } catch (Throwable t) {
                log("[WatcherError] Ngoai le trong vong lap: " + t.getMessage());
            }
        }
    }

    private static void tick() {
        // --- 0. Kiem tra Memory & Storage Guard dinh ky ---
        runGuards();

        // --- 1. Kiem tra dong cua so GLFW ---
        if (Gdx.graphics instanceof Lwjgl3Graphics) {
            Lwjgl3Window window = ((Lwjgl3Graphics) Gdx.graphics).getWindow();
            if (window != null && window.getWindowHandle() != 0L && GLFW.glfwWindowShouldClose(window.getWindowHandle())) {
                log("[Watchdog] Nguoi dung da bam nut [X] dong game. Thoat JVM sach se de Watchdog khoi dong lai...");
                System.exit(0);
            }
        }

        if (Gdx.app == null || Gdx.graphics == null) {
            log("[Watchdog] LibGDX graphics/app bi huy. Thoat JVM...");
            System.exit(0);
        }

        // --- 2. Kiem tra Singleton Game ---
        com.a.c.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75 game =
                com.a.c.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75;
        if (game == null) {
            return;
        }

        Screen screen = game.getScreen();
        if (screen == null) {
            return;
        }

        boolean isLoadingScreen = screen instanceof com.a.c.f.b.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75;
        boolean isLoginScreen = screen instanceof com.a.c.f.c.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75;
        boolean isInGame = game.gIrlKuN75NEKIlILIIiLlLWHatDOYouWanthereHihIhiHaHahAhOhoHOhEHEHEGIRLkun75() != null
                && screen == game.gIrlKuN75NEKIlILIIiLlLWHatDOYouWanthereHihIhiHaHahAhOhoHOhEHEHEGIRLkun75();

        long now = System.currentTimeMillis();

        // --- 3. Watchdog man hinh Loading (Kiem tra du lieu) ---
        if (isLoadingScreen) {
            if (loadingScreenStartTime == 0L) {
                loadingScreenStartTime = now;
                log("[WatchdogLoad] Phat hien man hinh 'Kiem Tra Du Lieu' (LoadingScreen). Theo doi timeout...");
            } else {
                long elapsed = now - loadingScreenStartTime;
                if (elapsed > LOADING_TIMEOUT_MS) {
                    log("[WatchdogLoad] CANH BAO: Man hinh loading bi treo qua " + (elapsed / 1000L)
                            + "s! Tu dong thoat JVM de khoi dong lai...");
                    System.exit(0);
                } else if (elapsed > 30_000L && (elapsed / 60_000L) > ((elapsed - POLL_INTERVAL_MS) / 60_000L)) {
                    log("[WatchdogLoad] Dang cho game kiem tra du lieu... " + (elapsed / 1000L) + "s / 180s");
                }
            }
            return;
        } else if (loadingScreenStartTime != 0L) {
            log("[WatchdogLoad] Da thoat man hinh loading. Reset timeout.");
            loadingScreenStartTime = 0L;
        }

        // --- 4. Xu ly Auto Login & Ket Noi Mang khi chua vao game ---
        if (!isInGame) {
            wasInGame = false;

            if (!isAutoLoginEnabled()) {
                return;
            }

            if (isLoggingIn || now - gameStartTime <= 3000L) {
                return;
            }

            long backoffInterval = (loginAttempts < 3) ? 8000L : 15000L;
            if (now - lastLoginAttemptTime <= backoffInterval) {
                return;
            }
            lastLoginAttemptTime = now;

            // Kiem tra trang thai socket KryoNet
            boolean isConnected = false;
            try {
                isConnected = com.a.d.gIrlKuN75NEKIlILIIiLlLWHatDOYouWanthereHihIhiHaHahAhOhoHOhEHEHEGIRLkun75.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75;
            } catch (Throwable ignored) {
            }

            if (!isConnected) {
                log("[AutoLogin] Chua co ket noi mang toi game server -> Dang gui goi TCP connect(0)...");
                try {
                    com.a.d.a.gIRLkuN75nEKliLILiiLiiWhAtDOYOUwAnTherehiHihIHAHAhaHOhohohEheHEgIRlKUN75 client =
                            com.a.d.a.gIRLkuN75nEKliLILiiLiiWhAtDOYOUwAnTherehiHihIHAHAhaHOhohohEheHEgIRlKUN75.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75();
                    if (client != null) {
                        client.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75(0);
                    }
                } catch (Throwable t) {
                    log("[AutoLogin] Loi gui lenh connect: " + t.getMessage());
                }
                return;
            }

            if (isLoginScreen) {
                loginAttempts++;
                log("[AutoLogin] Server da ket noi. Dang thuc hien dang nhap lan " + loginAttempts + "...");
                Gdx.app.postRunnable(TinhLinhBot::doLogin);
            }
            return;
        }

        // --- 5. Xu ly khi da vao the gioi game (isInGame == true) ---
        if (!wasInGame) {
            wasInGame = true;
            loginAttempts = 0;
            log("[AutoLogin] XAC NHAN: Da dang nhap vao the gioi game thanh cong!");

            // Luu lai tai khoan vua dang nhap neu co
            try {
                String curUser = com.a.c.f.e.b.GiRlKun75neklIiLliILliWHatdOyOUwANThEREHihiHIHAHAhahoHOhOhEHeHeGiRlkUN75.GIRLkuN75nEkLlLiiLIlLlwhATdoYouwaNtherEHiHiHihaHaHAHOHOHoHehEHeGIrlKun75;
                String curPass = com.a.c.f.e.b.GiRlKun75neklIiLliILliWHatdOyOUwANThEREHihiHIHAHAhahoHOhOhEHeHeGiRlkUN75.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75;
                if (curUser != null && !curUser.trim().isEmpty() && curPass != null && !curPass.trim().isEmpty()) {
                    if (!curUser.equals(savedUsername)) {
                        savedUsername = curUser.trim();
                        savedPassword = curPass.trim();
                        saveAccountToFile(savedUsername, savedPassword);
                    }
                }
            } catch (Throwable ignored) {
            }
        }

        // --- 6. Giam sat Vi tri & Map hien tai (Location Telemetry) ---
        checkLocationTelemetry(now);
    }

    // =========================================================================
    // MAP & CHARACTER LOCATION TELEMETRY
    // =========================================================================

    /**
     * Tra ve ten Map hien tai ma nhan vat dang dung (vi du: "Làng", "Rừng cổ mộc",...).
     * Neu chua vao the gioi game hoac khong xac dinh, tra ve chuoi rong "".
     */
    public static String getCurrentMapName() {
        try {
            com.a.c.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75 game =
                    com.a.c.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75;
            if (game == null) return "";
            com.a.c.f.a.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 world =
                    game.gIrlKuN75NEKIlILIIiLlLWHatDOYouWanthereHihIhiHaHahAhOhoHOhEHEHEGIRLkun75();
            if (world == null) return "";
            com.a.c.f.a.b.e.GIRLkuN75nEkLlLiiLIlLlwhATdoYouwaNtherEHiHiHihaHaHAHOHOHoHehEHeGIrlKun75 map =
                    world.GIrLkUn75NEkIlillliLIIwhatDOYOUwaNThEREHIHihIHAHAHAHoHoHOHehEhEGIrLKuN75;
            if (map != null && map.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 != null) {
                return map.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75.trim();
            }
        } catch (Throwable ignored) {
        }
        return "";
    }

    /**
     * Tra ve ID cua Map hien tai (vi du: 0 = Lang, 7 = Rung co moc, 5 = Vach nui,...).
     * Neu chua vao game hoac khong xac dinh, tra ve -1.
     */
    public static int getCurrentMapId() {
        try {
            com.a.c.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75 game =
                    com.a.c.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75;
            if (game == null) return -1;
            com.a.c.f.a.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 world =
                    game.gIrlKuN75NEKIlILIIiLlLWHatDOYouWanthereHihIhiHaHahAhOhoHOhEHEHEGIRLkun75();
            if (world == null) return -1;
            com.a.c.f.a.b.e.GIRLkuN75nEkLlLiiLIlLlwhATdoYouwaNtherEHiHiHihaHaHAHOHOHoHehEHeGIrlKun75 map =
                    world.GIrLkUn75NEkIlillliLIIwhatDOYOUwaNThEREHIHihIHAHAHAHoHoHOHehEhEGIrLKuN75;
            if (map != null) {
                return map.a_();
            }
        } catch (Throwable ignored) {
        }
        return -1;
    }

    /**
     * Tra ve Khu vuc (Zone) hien tai cua nhan vat (1..15).
     * Neu chua vao game hoac khong xac dinh, tra ve -1.
     */
    public static int getCurrentZone() {
        try {
            com.a.c.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75 game =
                    com.a.c.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75;
            if (game == null) return -1;
            com.a.c.f.a.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 world =
                    game.gIrlKuN75NEKIlILIIiLlLWHatDOYouWanthereHihIhiHaHahAhOhoHOhEHEHEGIRLkun75();
            if (world == null) return -1;
            com.a.c.f.a.b.e.GIRLkuN75nEkLlLiiLIlLlwhATdoYouwaNtherEHiHiHihaHaHAHOHOHoHehEHeGIrlKun75 map =
                    world.GIrLkUn75NEkIlillliLIIwhatDOYOUwaNThEREHIHihIHAHAHAHoHoHOHehEhEGIrLKuN75;
            if (map != null) {
                return map.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75;
            }
        } catch (Throwable ignored) {
        }
        return -1;
    }

    /**
     * Tra ve toa do Vector2 (X, Y) cua nhan vat tren ban do hien tai.
     * Neu chua vao game hoac player null, tra ve null.
     */
    public static Vector2 getPlayerPosition() {
        try {
            com.a.c.f.a.b.j.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75 player =
                    com.a.c.f.a.b.j.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75.GiRLKUN75NEklliilLliIiwhATDOyOUWanTheREhIhIHiHAHahahOHOHOhEhEHeGiRLkuN75();
            if (player != null) {
                // 1. Toa do truc tiep tu GameObject (Box2D / World Position)
                Vector2 pos = player.gIRLkuN75nEKliLILiiLiiWhAtDOYOUwAnTherehiHihIHAHAhaHOhohohEheHEgIRlKUN75();
                if (pos != null && (pos.x != 0.0f || pos.y != 0.0f)) {
                    return pos;
                }

                // 2. Fallback sang Center Position
                Vector2 centerPos = player.GirlKun75NekIlliLiLIiiWhAtdOyOuwAnTHereHIhihiHahAHAHOHOHOhEHeHeGiRLKuN75();
                if (centerPos != null && (centerPos.x != 0.0f || centerPos.y != 0.0f)) {
                    return centerPos;
                }

                // 3. Fallback sang Box2D Body Position
                try {
                    com.a.a.b.girLkUN75NekLiiiliILiiWhaTdOYOUwaNTHeReHihiHihahAhAHOhOHohEhEHEGiRlKUN75 comp =
                            player.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75();
                    if (comp != null) {
                        com.a.a.b.GIRLkuN75nEkLlLiiLIlLlwhATdoYouwaNtherEHiHiHihaHaHAHOHOHoHehEHeGIrlKun75 physComp =
                                comp.gIRLkUn75NEkLlLillLiLiwhatDOyouWanthERehihihIHAHAhAhOhOHoheHEHEgirLkuN75();
                        if (physComp != null) {
                            com.badlogic.gdx.physics.box2d.Body body = physComp.gIrLkUn75nEkIliiIiIILiWHATdoYouWantHEREHIhihIhAhahahohoHoHEheHEGiRlkUn75();
                            if (body != null) {
                                return body.getPosition();
                            }
                        }
                    }
                } catch (Throwable ignored) {
                }

                return pos;
            }
        } catch (Throwable ignored) {
        }
        return null;
    }

    /**
     * Kiem tra xem nhan vat co dang bi kiet suc (HP = 0) hay khong.
     */
    public static boolean isPlayerExhausted() {
        try {
            com.a.c.f.a.b.j.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75 player =
                    com.a.c.f.a.b.j.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75.GiRLKUN75NEklliilLliIiwhATDOyOUWanTheREhIhIHiHAHahahOHOHOhEhEHeGiRLkuN75();
            if (player != null) {
                return player.gIrLkun75nEKiLliiliiLiWhATDOYouWAntHeReHiHihIhaHahAHoHohOHEHEheGIrlKUN75();
            }
        } catch (Throwable ignored) {
        }
        return false;
    }

    /**
     * Cau truc du lieu luu tru toa do kiet suc cua nhan vat.
     */
    public static final class SavedCoordinate {
        public final int mapId;
        public final String mapName;
        public final int zone;
        public final float x;
        public final float y;
        public final long savedAt;

        public SavedCoordinate(int mapId, String mapName, int zone, float x, float y, long savedAt) {
            this.mapId = mapId;
            this.mapName = (mapName != null) ? mapName : "";
            this.zone = zone;
            this.x = x;
            this.y = y;
            this.savedAt = savedAt;
        }

        @Override
        public String toString() {
            return String.format(Locale.ROOT, "Map [%s - ID: %d, Khu: %d] tai (X=%.1f, Y=%.1f)", mapName, mapId, zone, x, y);
        }
    }

    /**
     * Kiem tra xem popup/dialog kiet suc (hoi sinh / ve lang) co dang hien thi tren man hinh hay khong.
     * Ho tro ca 2 lop bao ve:
     * 1. Kiem tra thuoc tinh Entity Player (HP <= 0).
     * 2. Quet cay UI Scene2D DialogManager tim hop thoai mo co chua van ban kiet suc/ve lang/hoi sinh.
     */
    public static boolean isExhaustionDialogVisible() {
        if (isPlayerExhausted()) {
            return true;
        }

        try {
            com.a.c.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75 game =
                    com.a.c.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75;
            if (game == null) return false;
            com.a.c.f.a.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 world =
                    game.gIrlKuN75NEKIlILIIiLlLWHatDOYouWanthereHihIhiHaHahAhOhoHOhEHEHEGIRLkun75();
            if (world == null) return false;

            com.a.c.f.a.b.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75 uiOverlay =
                    world.GIRLkuN75nEkLlLiiLIlLlwhATdoYouwaNtherEHiHiHihaHaHAHOHOHoHehEHeGIrlKun75;
            if (uiOverlay == null) return false;

            com.a.c.f.e.a.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75 dialogManager =
                    uiOverlay.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75;
            if (dialogManager != null) {
                SnapshotArray<Actor> children = dialogManager.getChildren();
                if (children != null && children.size > 0) {
                    for (int i = 0; i < children.size; i++) {
                        Actor child = children.get(i);
                        if (child != null && child.isVisible()) {
                            if (containsExhaustionText(child)) {
                                return true;
                            }
                        }
                    }
                }
            }
        } catch (Throwable ignored) {
        }
        return false;
    }

    private static boolean containsExhaustionText(Actor actor) {
        if (actor == null) return false;
        if (actor instanceof Label) {
            CharSequence text = ((Label) actor).getText();
            if (text != null) {
                String s = text.toString().toLowerCase(Locale.ROOT);
                if (s.contains("kiệt sức") || s.contains("kiet suc") || s.contains("về làng") || s.contains("ve lang") || s.contains("hồi sinh") || s.contains("hoi sinh")) {
                    return true;
                }
            }
        }
        if (actor instanceof Group) {
            Group group = (Group) actor;
            SnapshotArray<Actor> kids = group.getChildren();
            if (kids != null) {
                for (int i = 0; i < kids.size; i++) {
                    if (containsExhaustionText(kids.get(i))) {
                        return true;
                    }
                }
            }
        }
        return false;
    }

    /**
     * Ham luu toa do nhan vat khi hien popup kiet suc.
     * Ghi nhan: Map ID, Ten Map, Khu vuc, Toa do X, Y va Thoi diem kiet suc.
     * Luu vao RAM va dong bo ngay lap tuc xuong dia:
     * - tinhlinh-exhaustion-state.properties
     * - saved_exhaustion_coord.txt
     * - last_farm_map.txt
     */
    public static synchronized SavedCoordinate saveExhaustionCoordinate() {
        int mapId = getCurrentMapId();
        String mapName = getCurrentMapName();
        int zone = getCurrentZone();
        Vector2 pos = getPlayerPosition();

        // Fallback ve lastKnown neu map hien tai dang bi rong trong luc chuyen canh
        if ((mapName == null || mapName.trim().isEmpty()) && lastKnownMapName != null && !lastKnownMapName.trim().isEmpty()) {
            mapName = lastKnownMapName;
            mapId = lastKnownMapId;
            zone = lastKnownZone;
        }

        float x = (pos != null) ? pos.x : 0.0f;
        float y = (pos != null) ? pos.y : 0.0f;
        long now = System.currentTimeMillis();

        SavedCoordinate coord = new SavedCoordinate(mapId, mapName, zone, x, y, now);
        lastSavedExhaustionCoord = coord;

        persistExhaustionState(coord);

        log("[AutoFarm-Exhaustion] >>> DA LUU TOA DO KIET SUC THANH CONG <<<");
        log("[AutoFarm-Exhaustion] Toa do: " + coord + " luc " + DATE_FORMAT.format(new Date(now)));
        log("[AutoFarm-Exhaustion] Cac file da cap nhat: " + EXHAUSTION_STATE_FILE + ", " + EXHAUSTION_COORD_FILE + ", " + LAST_FARM_MAP_FILE);

        return coord;
    }

    /**
     * Tra ve toa do kiet suc da luu (tu RAM hoac nap tu file).
     */
    public static SavedCoordinate getSavedExhaustionCoordinate() {
        if (lastSavedExhaustionCoord != null) {
            return lastSavedExhaustionCoord;
        }
        lastSavedExhaustionCoord = loadSavedExhaustionCoordinate();
        return lastSavedExhaustionCoord;
    }

    private static void persistExhaustionState(SavedCoordinate coord) {
        if (coord == null) return;
        try {
            // 1. Luu file properties day du
            Properties props = new Properties();
            props.setProperty("mapId", Integer.toString(coord.mapId));
            props.setProperty("mapName", coord.mapName);
            props.setProperty("zone", Integer.toString(coord.zone));
            props.setProperty("x", String.format(Locale.ROOT, "%.2f", coord.x));
            props.setProperty("y", String.format(Locale.ROOT, "%.2f", coord.y));
            props.setProperty("savedAt", Long.toString(coord.savedAt));
            props.setProperty("savedTime", DATE_FORMAT.format(new Date(coord.savedAt)));

            File propFile = new File(EXHAUSTION_STATE_FILE);
            try (OutputStream os = new FileOutputStream(propFile, false)) {
                props.store(os, "Tinh Linh Exhaustion State & Saved Coordinate");
            }

            // 2. Luu file text gon nhe saved_exhaustion_coord.txt (mapId:mapName:zone:x:y)
            File txtFile = new File(EXHAUSTION_COORD_FILE);
            try (OutputStreamWriter writer = new OutputStreamWriter(new FileOutputStream(txtFile, false), StandardCharsets.UTF_8)) {
                writer.write(coord.mapId + ":" + coord.mapName + ":" + coord.zone + ":"
                        + String.format(Locale.ROOT, "%.2f", coord.x) + ":"
                        + String.format(Locale.ROOT, "%.2f", coord.y) + "\r\n");
            }

            // 3. Luu last_farm_map.txt neu day la map chien dau
            if (coord.mapId > 0 && coord.mapName != null && !coord.mapName.isEmpty()
                    && !coord.mapName.contains("Làng") && !coord.mapName.contains("Nông trại")) {
                File farmMapFile = new File(LAST_FARM_MAP_FILE);
                try (OutputStreamWriter writer = new OutputStreamWriter(new FileOutputStream(farmMapFile, false), StandardCharsets.UTF_8)) {
                    writer.write(coord.mapId + ":" + coord.mapName + "\r\n");
                }
            }
        } catch (Throwable t) {
            log("[AutoFarm-Exhaustion] Loi khi ghi file trang thai kiet suc: " + t.getMessage());
        }
    }

    private static SavedCoordinate loadSavedExhaustionCoordinate() {
        File propFile = new File(EXHAUSTION_STATE_FILE);
        if (!propFile.exists() || !propFile.isFile()) {
            return null;
        }
        try (InputStream is = new FileInputStream(propFile)) {
            Properties props = new Properties();
            props.load(is);
            int mapId = Integer.parseInt(props.getProperty("mapId", "-1"));
            String mapName = props.getProperty("mapName", "");
            int zone = Integer.parseInt(props.getProperty("zone", "-1"));
            float x = Float.parseFloat(props.getProperty("x", "0.0"));
            float y = Float.parseFloat(props.getProperty("y", "0.0"));
            long savedAt = Long.parseLong(props.getProperty("savedAt", "0"));
            return new SavedCoordinate(mapId, mapName, zone, x, y, savedAt);
        } catch (Throwable ignored) {
            return null;
        }
    }

    /**
     * Tu dong tim va kich hoat lua chon 'Ve Lang' khi popup kiet suc dang hien thi.
     * Ho tro moi loai Actor Scene2D: Button, TextButton, Label, Table row hoac ClickListener.
     * @return true neu da tim thay va gui su kien click thanh cong vao menu Ve Lang, false neu khong co popup.
     */
    public static synchronized boolean autoSelectReturnToVillage() {
        try {
            com.a.c.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75 game =
                    com.a.c.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75;
            if (game == null) return false;
            com.a.c.f.a.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 world =
                    game.gIrlKuN75NEKIlILIIiLlLWHatDOYouWanthereHihIhiHaHahAhOhoHOhEHEHEGIRLkun75();
            if (world == null) return false;

            com.a.c.f.a.b.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75 uiOverlay =
                    world.GIRLkuN75nEkLlLiiLIlLlwhATdoYouwaNtherEHiHiHihaHaHAHOHOHoHehEHeGIrlKun75;
            if (uiOverlay == null) return false;

            com.a.c.f.e.a.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75 dialogManager =
                    uiOverlay.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75;
            if (dialogManager == null) return false;

            SnapshotArray<Actor> dialogs = dialogManager.getChildren();
            if (dialogs == null || dialogs.size == 0) return false;

            for (int i = 0; i < dialogs.size; i++) {
                Actor dialog = dialogs.get(i);
                if (dialog != null && dialog.isVisible()) {
                    Actor targetButton = findVillageButton(dialog);
                    if (targetButton != null) {
                        String btnText = getActorText(targetButton);
                        log("[AutoFarm-Exhaustion] Tim thay nut Ve Lang: [" + (btnText.isEmpty() ? targetButton.getClass().getSimpleName() : btnText) + "] tren popup. Dang thuc hien click...");
                        Gdx.app.postRunnable(() -> clickActor(targetButton));
                        return true;
                    }
                }
            }
        } catch (Throwable t) {
            log("[AutoFarm-Exhaustion] Loi trong autoSelectReturnToVillage: " + t.getMessage());
        }
        return false;
    }

    private static Actor findVillageButton(Actor root) {
        if (root == null) return null;

        // 1. Uu tien tuyet doi: Nut hoac text chua truc tiep chu 've lang' / 'về làng' / 've thanh' / 'về thành'
        Actor directBtn = searchActorMatching(root, text -> {
            String s = text.toLowerCase(Locale.ROOT);
            return s.contains("về làng") || s.contains("ve lang") || s.contains("về thành") || s.contains("ve thanh");
        });
        if (directBtn != null) {
            return directBtn;
        }

        // 2. Neu popup la hop thoai kiet suc, tim nut 'dong y' / 'xac nhan' / 'ok' / 'hoi sinh'
        if (containsExhaustionText(root)) {
            Actor confirmBtn = searchActorMatching(root, text -> {
                String s = text.toLowerCase(Locale.ROOT).trim();
                return s.equals("đồng ý") || s.equals("dong y") || s.equals("xác nhận") || s.equals("xac nhan")
                        || s.equals("ok") || s.contains("về") || s.contains("hoi sinh") || s.contains("hồi sinh");
            });
            if (confirmBtn != null) {
                return confirmBtn;
            }

            // 3. Neu khong co text cu the nhung la Button trong popup kiet suc: lay nut dau tien
            Actor firstButton = searchFirstButton(root);
            if (firstButton != null) {
                return firstButton;
            }
        }

        return null;
    }

    private interface TextMatcher {
        boolean matches(String text);
    }

    private static Actor searchActorMatching(Actor actor, TextMatcher matcher) {
        if (actor == null) return null;

        if (actor instanceof Label) {
            CharSequence text = ((Label) actor).getText();
            if (text != null && matcher.matches(text.toString())) {
                // Neu Label nam trong Button, tra ve Button cha
                if (actor.getParent() != null && actor.getParent() instanceof Button) {
                    return actor.getParent();
                }
                return actor;
            }
        }

        if (actor instanceof Button) {
            String text = getActorText(actor);
            if (!text.isEmpty() && matcher.matches(text)) {
                return actor;
            }
        }

        if (actor instanceof Group) {
            Group group = (Group) actor;
            SnapshotArray<Actor> children = group.getChildren();
            if (children != null) {
                for (int i = 0; i < children.size; i++) {
                    Actor found = searchActorMatching(children.get(i), matcher);
                    if (found != null) {
                        return found;
                    }
                }
            }
        }

        return null;
    }

    private static Actor searchFirstButton(Actor actor) {
        if (actor == null) return null;
        if (actor instanceof Button && actor.isVisible()) {
            return actor;
        }
        if (actor instanceof Group) {
            Group group = (Group) actor;
            SnapshotArray<Actor> children = group.getChildren();
            if (children != null) {
                for (int i = 0; i < children.size; i++) {
                    Actor found = searchFirstButton(children.get(i));
                    if (found != null) {
                        return found;
                    }
                }
            }
        }
        return null;
    }

    private static String getActorText(Actor actor) {
        if (actor == null) return "";
        if (actor instanceof Label) {
            CharSequence cs = ((Label) actor).getText();
            return (cs != null) ? cs.toString() : "";
        }
        if (actor instanceof Group) {
            Group g = (Group) actor;
            SnapshotArray<Actor> kids = g.getChildren();
            if (kids != null) {
                for (int i = 0; i < kids.size; i++) {
                    String t = getActorText(kids.get(i));
                    if (!t.isEmpty()) return t;
                }
            }
        }
        return "";
    }

    private static void clickActor(Actor actor) {
        if (actor == null) return;
        try {
            float centerX = actor.getWidth() / 2f;
            float centerY = actor.getHeight() / 2f;

            // 1. Phuc vu ca ClickListener
            if (actor.getListeners() != null) {
                SnapshotArray<EventListener> listeners = new SnapshotArray<>(actor.getListeners());
                for (int i = 0; i < listeners.size; i++) {
                    EventListener l = listeners.get(i);
                    if (l instanceof ClickListener) {
                        ((ClickListener) l).clicked(new InputEvent(), centerX, centerY);
                    }
                }
            }

            // 2. Neu la Button
            if (actor instanceof Button) {
                Button btn = (Button) actor;
                if (btn.getClickListener() != null) {
                    btn.getClickListener().clicked(new InputEvent(), centerX, centerY);
                }
                btn.toggle();
            }

            // 3. Gui InputEvent TouchDown va TouchUp
            InputEvent downEvent = new InputEvent();
            downEvent.setType(InputEvent.Type.touchDown);
            downEvent.setStage(actor.getStage());
            downEvent.setTarget(actor);
            downEvent.setStageX(actor.getX() + centerX);
            downEvent.setStageY(actor.getY() + centerY);
            actor.fire(downEvent);

            InputEvent upEvent = new InputEvent();
            upEvent.setType(InputEvent.Type.touchUp);
            upEvent.setStage(actor.getStage());
            upEvent.setTarget(actor);
            upEvent.setStageX(actor.getX() + centerX);
            upEvent.setStageY(actor.getY() + centerY);
            actor.fire(upEvent);

            // 4. ChangeEvent
            try {
                ChangeListener.ChangeEvent change = Pools.obtain(ChangeListener.ChangeEvent.class);
                actor.fire(change);
                Pools.free(change);
            } catch (Throwable ignored) {
            }

            log("[AutoFarm-Exhaustion] Da kich hoat click thanh cong vao Actor: [" + actor.getClass().getSimpleName() + "].");
        } catch (Throwable t) {
            log("[AutoFarm-Exhaustion] Loi khi kich hoat click actor: " + t.getMessage());
        }
    }

    /**
     * Giam sat va log vi tri Map, Khu vuc va toa do nhan vat dinh ky hoac khi chuyen map.
     * Tu dong phat hien trang thai kiet suc / hien popup kiet suc de goi saveExhaustionCoordinate().
     */
    private static void checkLocationTelemetry(long now) {
        String mapName = getCurrentMapName();
        if (mapName == null || mapName.trim().isEmpty()) {
            return;
        }

        int mapId = getCurrentMapId();
        int zone = getCurrentZone();
        Vector2 pos = getPlayerPosition();
        boolean exhausted = isPlayerExhausted() || isExhaustionDialogVisible();

        // 1. Theo doi va tu dong luu toa do khi phat hien kiet suc (rising-edge trigger)
        if (exhausted && !previousExhausted) {
            log("[AutoFarm-Exhaustion] PHAT HIEN POPUP/TRANG THAI KIET SUC! Tu dong luu toa do tran danh...");
            saveExhaustionCoordinate();
            log("[AutoFarm-Exhaustion] Tu dong chon menu [Ve Lang] tren popup...");
            autoSelectReturnToVillage();
        } else if (exhausted) {
            // Neu van con kiet suc va popup chua dong, thu chon lai menu Ve Lang moi 2.4s (3 ticks)
            if (now - lastVillageSelectAttemptTime >= 2400L) {
                lastVillageSelectAttemptTime = now;
                autoSelectReturnToVillage();
            }
        } else if (!exhausted && previousExhausted) {
            log("[AutoFarm-Exhaustion] Nhan vat da ve lang / thoat trang thai kiet suc.");
        }
        previousExhausted = exhausted;

        // 2. Theo doi chuyen Map & dinh ky 10s
        boolean mapChanged = (mapId != lastKnownMapId) || (zone != lastKnownZone) || (!mapName.equals(lastKnownMapName));
        boolean periodicLog = (now - lastMapLogTime >= 10000L); // Dinh ky moi 10 giay

        if (mapChanged || periodicLog) {
            lastKnownMapId = mapId;
            lastKnownMapName = mapName;
            lastKnownZone = zone;
            lastMapLogTime = now;

            String posStr = (pos != null) ? String.format(Locale.ROOT, "(X=%.1f, Y=%.1f)", pos.x, pos.y) : "(X=?, Y=?)";
            String statusStr = exhausted ? "[KIET SUC/HP=0]" : "[BINH THUONG]";
            if (mapChanged) {
                log("[AutoFarm-Map] CHUYEN MAP -> Map [" + mapName + " - ID: " + mapId + ", Khu: " + zone + "] tai " + posStr + " " + statusStr);
            } else {
                log("[AutoFarm-Map] Dang o Map [" + mapName + " - ID: " + mapId + ", Khu: " + zone + "] tai " + posStr + " " + statusStr);
            }
        }
    }

    private static synchronized void doLogin() {
        if (!isAutoLoginEnabled()) {
            log("[AutoLogin] Auto Login dang bi tat -> Bo qua.");
            return;
        }

        try {
            isLoggingIn = true;

            // Dong cac thong bao/dialog loi dang hien tren man hinh login
            try {
                com.a.c.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75 game =
                        com.a.c.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75;
                if (game != null && game.getScreen() instanceof com.a.c.f.c.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75) {
                    com.a.c.f.c.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 loginScreen =
                            (com.a.c.f.c.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75) game.getScreen();
                    if (loginScreen.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75 != null) {
                        loginScreen.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75(
                                com.a.c.f.e.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75.gIrlKuN75NEKIlILIIiLlLWHatDOYouWanthereHihIhiHaHahAhOhoHOhEHEHEGIRLkun75
                        );
                    }
                }
            } catch (Throwable ignored) {
            }

            if (savedUsername == null || savedUsername.trim().isEmpty() || savedPassword == null || savedPassword.trim().isEmpty()) {
                loadSavedAccount();
            }

            String targetUser = com.a.c.f.e.b.GiRlKun75neklIiLliILliWHatdOyOUwANThEREHihiHIHAHAhahoHOhOhEHeHeGiRlkUN75.GIRLkuN75nEkLlLiiLIlLlwhATdoYouwaNtherEHiHiHihaHaHAHOHOHoHehEHeGIrlKun75;
            String targetPass = com.a.c.f.e.b.GiRlKun75neklIiLliILliWHatdOyOUwANThEREHihiHIHAHAhahoHOhOhEHeHeGiRlkUN75.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75;

            if ((targetUser == null || targetUser.trim().isEmpty() || targetPass == null || targetPass.trim().isEmpty())
                    && savedUsername != null && !savedUsername.trim().isEmpty()) {
                targetUser = savedUsername;
                targetPass = savedPassword;
                com.a.c.f.e.b.GiRlKun75neklIiLliILliWHatdOyOUwANThEREHihiHIHAHAhahoHOhOhEHeHeGiRlkUN75.GIRLkuN75nEkLlLiiLIlLlwhATdoYouwaNtherEHiHiHihaHaHAHOHOHoHehEHeGIrlKun75 = targetUser;
                com.a.c.f.e.b.GiRlKun75neklIiLliILliWHatdOyOUwANThEREHihiHIHAHAhahoHOhOhEHeHeGiRlkUN75.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75 = targetPass;
            }

            // Kiem tra tu lich su dang nhap cua game neu van chua co
            if ((targetUser == null || targetUser.trim().isEmpty() || targetPass == null || targetPass.trim().isEmpty())
                    && com.a.c.girLkUN75NekLiiiliILiiWhaTdOYOUwaNTHeReHihiHihahAhAHOhOHohEhEHEGiRlKUN75.GIrlkuN75nEKillILLIiiiwhaTdoYouWANTherEhihIHihAhAhahoHOHohEHehEGIRLkUN75 != null
                    && !com.a.c.girLkUN75NekLiiiliILiiWhaTdOYOUwaNTHeReHihiHihahAhAHOhOHohEhEHEGiRlKUN75.GIrlkuN75nEKillILLIiiiwhaTdoYouWANTherEhihIHihAhAhahoHOHohEHehEGIRLkUN75.isEmpty()) {
                com.a.c.c.a.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 historyAccount =
                        (com.a.c.c.a.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75) com.a.c.girLkUN75NekLiiiliILiiWhaTdOYOUwaNTHeReHihiHihahAhAHOhOHohEhEHEGiRlKUN75.GIrlkuN75nEKillILLIiiiwhaTdoYouWANTherEhihIHihAhAhahoHOHohEHehEGIRLkUN75.first();
                targetUser = historyAccount.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75;
                targetPass = historyAccount.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75;
                com.a.c.f.e.b.GiRlKun75neklIiLliILliWHatdOyOUwANThEREHihiHIHAHAhahoHOhOhEHeHeGiRlkUN75.GIRLkuN75nEkLlLiiLIlLlwhATdoYouwaNtherEHiHiHihaHaHAHOHOHoHehEHeGIrlKun75 = targetUser;
                com.a.c.f.e.b.GiRlKun75neklIiLliILliWHatdOyOUwANThEREHihiHIHAHAhahoHOhOhEHeHeGiRlkUN75.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75 = targetPass;
            }

            if (targetUser != null && !targetUser.trim().isEmpty() && targetPass != null && !targetPass.trim().isEmpty()) {
                log("[AutoLogin] Dang tu dong dang nhap tai khoan: [" + targetUser + "]...");
                saveAccountToFile(targetUser, targetPass);

                Class<?> loginClass = com.a.c.f.e.b.GiRlKun75neklIiLliILliWHatdOyOUwANThEREHihiHIHAHAhahoHOhOhEHeHeGiRlkUN75.class;
                Method loginMethod = null;
                for (Method m : loginClass.getDeclaredMethods()) {
                    if (Modifier.isStatic(m.getModifiers()) && m.getParameterCount() == 0 && m.getReturnType() == Void.TYPE && m.getName().startsWith("G")) {
                        loginMethod = m;
                        break;
                    }
                }
                if (loginMethod != null) {
                    loginMethod.setAccessible(true);
                    loginMethod.invoke(null);
                    log("[AutoLogin] Da goi thanh cong ham dang nhap he thong.");
                } else {
                    log("[AutoLogin] Khong tim thay ham login static trong class " + loginClass.getName());
                }
            } else {
                log("[AutoLogin] Khong tim thay thong tin tai khoan de dang nhap! Vui long tao file saved_account.txt (user:pass).");
            }
        } catch (Throwable t) {
            log("[AutoLogin] Loi trong doLogin: " + t.getMessage());
        } finally {
            isLoggingIn = false;
        }
    }

    public static boolean isAutoLoginEnabled() {
        if (new File("tat_auto_login.txt").exists() || new File("no_auto_login.txt").exists()) {
            return false;
        }
        if (new File("bat_auto_login.txt").exists()) {
            return true;
        }
        try {
            String dir = new File(".").getAbsolutePath().toLowerCase();
            if (dir.contains("maythat") || dir.contains("may_that")) {
                return false;
            }
        } catch (Throwable ignored) {
        }
        return true;
    }

    public static void loadSavedAccount() {
        String[] candidatePaths = {
                "saved_account.txt",
                "C:\\TinhLinh\\saved_account.txt",
                "d:\\tinhlinh\\saved_account.txt"
        };
        for (String path : candidatePaths) {
            File f = new File(path);
            if (f.exists() && f.isFile()) {
                try (BufferedReader reader = new BufferedReader(new InputStreamReader(new FileInputStream(f), StandardCharsets.UTF_8))) {
                    String line = reader.readLine();
                    if (line != null && line.contains(":")) {
                        String[] parts = line.split(":", 2);
                        savedUsername = parts[0].trim();
                        savedPassword = parts[1].trim();
                        log("[AutoLogin] Da doc tai khoan tu file " + f.getName() + ": [" + savedUsername + "]");
                        return;
                    }
                } catch (Throwable ignored) {
                }
            }
        }

        // Doc tu LibGDX .prefs neu khong co file txt
        try {
            File prefFile = new File(System.getProperty("user.home"), ".prefs/account");
            if (prefFile.exists()) {
                try (BufferedReader reader = new BufferedReader(new InputStreamReader(new FileInputStream(prefFile), StandardCharsets.UTF_8))) {
                    String line;
                    String prefUser = null;
                    String prefPass = null;
                    while ((line = reader.readLine()) != null) {
                        if (line.contains("username0\">")) {
                            int start = line.indexOf("username0\">") + 11;
                            int end = line.indexOf("</entry>", start);
                            if (end > start) {
                                prefUser = line.substring(start, end).trim();
                            }
                        }
                        if (line.contains("password0\">")) {
                            int start = line.indexOf("password0\">") + 11;
                            int end = line.indexOf("</entry>", start);
                            if (end > start) {
                                prefPass = line.substring(start, end).trim();
                            }
                        }
                    }
                    if (prefUser != null && !prefUser.isEmpty() && prefPass != null && !prefPass.isEmpty()) {
                        savedUsername = prefUser;
                        savedPassword = prefPass;
                        log("[AutoLogin] Da khoi phuc tai khoan tu LibGDX .prefs: [" + savedUsername + "]");
                        saveAccountToFile(savedUsername, savedPassword);
                    }
                }
            }
        } catch (Throwable ignored) {
        }
    }

    public static void saveAccountToFile(String username, String password) {
        if (username == null || username.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            return;
        }
        String[] targetPaths = {
                "saved_account.txt",
                "C:\\TinhLinh\\saved_account.txt"
        };
        for (String path : targetPaths) {
            try {
                File file = new File(path);
                File parent = file.getParentFile();
                if (parent != null && !parent.exists()) {
                    continue;
                }
                try (OutputStreamWriter writer = new OutputStreamWriter(new FileOutputStream(file, false), StandardCharsets.UTF_8)) {
                    writer.write(username.trim() + ":" + password.trim());
                }
            } catch (Throwable ignored) {
            }
        }
    }

    public static void log(String message) {
        String timestamp = DATE_FORMAT.format(new Date());
        String formatted = "[" + timestamp + "] " + message;
        System.out.println(formatted);

        // Ghi vao autofarm_log.txt voi co che tu dong cat tia (Storage Guard)
        try {
            File logFile = new File("autofarm_log.txt");
            if (logFile.exists() && logFile.length() > MAX_LOG_FILE_BYTES) {
                // Cat tia: giu lai 1500 dong cuoi cung
                rotateLog(logFile);
            }
            try (OutputStreamWriter writer = new OutputStreamWriter(new FileOutputStream(logFile, true), StandardCharsets.UTF_8)) {
                writer.write(formatted + "\r\n");
            }
        } catch (Throwable ignored) {
        }
    }

    private static void runGuards() {
        long now = System.currentTimeMillis();
        if (now - lastGuardCheckTime < 8000L) {
            return;
        }
        lastGuardCheckTime = now;

        // 1. Memory Guard (Heap RAM)
        long freeMem = Runtime.getRuntime().freeMemory();
        long totalMem = Runtime.getRuntime().totalMemory();
        long maxMem = Runtime.getRuntime().maxMemory();
        long usedMem = totalMem - freeMem;
        if (maxMem > 0 && usedMem > (maxMem * 85 / 100)) {
            long usedMb = usedMem / (1024L * 1024L);
            long maxMb = maxMem / (1024L * 1024L);
            log("[MemoryGuard] Heap usage cao: " + usedMb + "MB / " + maxMb + "MB (>85%). Goi System.gc() thu hoi bo nho...");
            System.gc();
        }

        // 2. Storage Guard (O dia & File log)
        File root = new File(".");
        long usableBytes = root.getUsableSpace();
        long usableMb = usableBytes / (1024L * 1024L);
        File logFile = new File("autofarm_log.txt");

        if (usableMb < 1024L || (logFile.exists() && logFile.length() > MAX_LOG_FILE_BYTES)) {
            log("[StorageGuard] Kiem tra dung luong: Trong=" + usableMb + "MB, Log=" + (logFile.length() / 1024L) + "KB. Kich hoat don dep...");
            if (logFile.exists() && logFile.length() > (500 * 1024)) {
                rotateLog(logFile);
            }
            cleanTempFiles();
            System.gc();
        }

        // 3. Stress Test Triggers (Kiem thu mo phong crash / tran RAM / spam log)
        File testCrash = new File("test_trigger_crash.txt");
        if (testCrash.exists()) {
            testCrash.delete();
            log("[StressTest] Nhan lenh test_trigger_crash.txt! Mo phong crash tien trinh voi ma thoat 137...");
            System.exit(137);
        }

        File testOom = new File("test_trigger_oom.txt");
        if (testOom.exists()) {
            testOom.delete();
            log("[StressTest] Nhan lenh test_trigger_oom.txt! Mo phong tran RAM OutOfMemoryError...");
            java.util.List<byte[]> leak = new java.util.ArrayList<>();
            while (true) {
                leak.add(new byte[10 * 1024 * 1024]); // 10MB allocations until OOM
            }
        }

        File testSpamLog = new File("test_spam_log.txt");
        if (testSpamLog.exists()) {
            testSpamLog.delete();
            log("[StressTest] Nhan lenh test_spam_log.txt! Mo phong ghi tran log 10MB...");
            try (OutputStreamWriter writer = new OutputStreamWriter(new FileOutputStream(logFile, true), StandardCharsets.UTF_8)) {
                for (int i = 0; i < 50000; i++) {
                    writer.write("[SPAM_TEST_LINE_" + i + "] Du lieu log rac gia lap de thu nghiem bo tu don dep Storage Guard\r\n");
                }
            } catch (Throwable ignored) {
            }
            log("[StressTest] Da ghi xong spam log. Dung luong file: " + (logFile.length() / 1024L) + "KB. Kich hoat Storage Guard cat tia ngay...");
            rotateLog(logFile);
            log("[StressTest] Ket qua sau cat tia: " + (logFile.length() / 1024L) + "KB.");
        }

        // 4. Diagnostic Trigger: Kiem thu luu toa do kiet suc & tu dong ve lang
        File testExhaustion = new File("test_trigger_exhaustion.txt");
        if (testExhaustion.exists()) {
            testExhaustion.delete();
            log("[Diagnostic] Nhan lenh test_trigger_exhaustion.txt! Kich hoat luu toa do kiet suc ngay lap tuc...");
            saveExhaustionCoordinate();
        }

        File testVillage = new File("test_trigger_village.txt");
        if (testVillage.exists()) {
            testVillage.delete();
            log("[Diagnostic] Nhan lenh test_trigger_village.txt! Kich hoat autoSelectReturnToVillage ngay lap tuc...");
            boolean ok = autoSelectReturnToVillage();
            log("[Diagnostic] Ket qua autoSelectReturnToVillage: " + ok);
        }
    }

    private static void cleanTempFiles() {
        try {
            String tmpDir = System.getProperty("java.io.tmpdir");
            if (tmpDir == null) return;
            File dir = new File(tmpDir);
            File[] files = dir.listFiles();
            if (files == null) return;
            long now = System.currentTimeMillis();
            for (File f : files) {
                if (f.isFile() && f.getName().startsWith("tinhlinh-") && (now - f.lastModified() > 60_000L)) {
                    f.delete();
                }
            }
        } catch (Throwable ignored) {
        }
    }

    private static void rotateLog(File file) {
        try {
            if (!file.exists() || !file.isFile()) return;
            long length = file.length();
            java.util.List<String> lines = new java.util.ArrayList<>(2000);

            if (length > 10L * 1024L * 1024L) {
                // Tối ưu đọc file lớn: Chỉ đọc phần đuôi 500KB cuối cùng
                try (java.io.RandomAccessFile raf = new java.io.RandomAccessFile(file, "r")) {
                    long seekPos = Math.max(0L, length - (500L * 1024L));
                    raf.seek(seekPos);
                    String line;
                    while ((line = raf.readLine()) != null) {
                        lines.add(new String(line.getBytes(StandardCharsets.ISO_8859_1), StandardCharsets.UTF_8));
                    }
                }
            } else {
                try (BufferedReader reader = new BufferedReader(new InputStreamReader(new FileInputStream(file), StandardCharsets.UTF_8))) {
                    String line;
                    while ((line = reader.readLine()) != null) {
                        lines.add(line);
                    }
                }
            }

            int keepCount = Math.min(lines.size(), 1500);
            java.util.List<String> keepLines = lines.subList(lines.size() - keepCount, lines.size());
            try (OutputStreamWriter writer = new OutputStreamWriter(new FileOutputStream(file, false), StandardCharsets.UTF_8)) {
                for (String l : keepLines) {
                    writer.write(l + "\r\n");
                }
            }
            log("[StorageGuard] Da cat tia thanh cong autofarm_log.txt: giu lai " + keepLines.size() + " dong (Dung luong con: " + (file.length() / 1024L) + "KB).");
        } catch (Throwable ignored) {
        }
    }
}
