import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.lang.reflect.Method;
import java.lang.reflect.Modifier;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;
import java.util.concurrent.atomic.AtomicBoolean;

import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.Screen;
import com.badlogic.gdx.backends.lwjgl3.Lwjgl3Graphics;
import com.badlogic.gdx.backends.lwjgl3.Lwjgl3Window;
import com.badlogic.gdx.math.Vector2;
import org.lwjgl.glfw.GLFW;

/**
 * TinhLinhBot - Core Automation Engine for Tinh Linh Game.
 * Feature 1: Auto Login, Auto Reconnect & Watchdog Lifecycle.
 * Feature 2: Map & Location Telemetry (getCurrentMapName, getCurrentMapId, getCurrentZone, getPlayerPosition).
 */
public final class TinhLinhBot {
    private static final String VERSION = "1.1.0-Feature2-MapTelemetry";
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
                return player.gIRlKun75NekLLllIlllIlwHAtDOYoUWaNThERehihiHihahahahOhohOhEHEHEGirlkun75;
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
     * Giam sat va log vi tri Map, Khu vuc va toa do nhan vat dinh ky hoac khi chuyen map.
     */
    private static void checkLocationTelemetry(long now) {
        String mapName = getCurrentMapName();
        if (mapName == null || mapName.trim().isEmpty()) {
            return;
        }

        int mapId = getCurrentMapId();
        int zone = getCurrentZone();
        Vector2 pos = getPlayerPosition();
        boolean exhausted = isPlayerExhausted();

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
