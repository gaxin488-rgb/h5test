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
import java.util.concurrent.atomic.AtomicBoolean;

import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.Screen;
import com.badlogic.gdx.backends.lwjgl3.Lwjgl3Graphics;
import com.badlogic.gdx.backends.lwjgl3.Lwjgl3Window;
import org.lwjgl.glfw.GLFW;

/**
 * TinhLinhBot - Core Automation Engine for Tinh Linh Game.
 * Feature 1: Auto Login, Auto Reconnect & Watchdog Lifecycle.
 */
public final class TinhLinhBot {
    private static final String VERSION = "1.0.0-Feature1-AutoLogin";
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

    private static void rotateLog(File file) {
        try {
            java.util.List<String> lines = new java.util.ArrayList<>(2000);
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(new FileInputStream(file), StandardCharsets.UTF_8))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    lines.add(line);
                }
            }
            int keepCount = Math.min(lines.size(), 1500);
            java.util.List<String> keepLines = lines.subList(lines.size() - keepCount, lines.size());
            try (OutputStreamWriter writer = new OutputStreamWriter(new FileOutputStream(file, false), StandardCharsets.UTF_8)) {
                for (String l : keepLines) {
                    writer.write(l + "\r\n");
                }
            }
        } catch (Throwable ignored) {
        }
    }
}
