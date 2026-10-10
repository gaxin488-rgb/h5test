import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.lang.reflect.Modifier;
import java.nio.charset.StandardCharsets;
import java.text.Normalizer;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Properties;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.concurrent.atomic.AtomicBoolean;
import java.net.InetSocketAddress;
import java.util.concurrent.Executors;
import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpHandler;
import com.sun.net.httpserver.HttpServer;

import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.Screen;
import com.badlogic.gdx.backends.lwjgl3.Lwjgl3Graphics;
import com.badlogic.gdx.backends.lwjgl3.Lwjgl3Window;
import com.badlogic.gdx.math.Vector2;
import com.badlogic.gdx.scenes.scene2d.Actor;
import com.badlogic.gdx.scenes.scene2d.EventListener;
import com.badlogic.gdx.scenes.scene2d.Group;
import com.badlogic.gdx.scenes.scene2d.InputEvent;
import com.badlogic.gdx.scenes.scene2d.Stage;
import com.badlogic.gdx.scenes.scene2d.ui.Button;
import com.badlogic.gdx.scenes.scene2d.ui.Label;
import com.badlogic.gdx.scenes.scene2d.ui.TextButton;
import com.badlogic.gdx.scenes.scene2d.utils.ClickListener;
import com.badlogic.gdx.utils.Array;
import com.badlogic.gdx.utils.SnapshotArray;
import com.github.tommyettinger.textra.TextraButton;
import com.github.tommyettinger.textra.TextraLabel;
import org.lwjgl.glfw.GLFW;

/**
 * TinhLinhBot - Core Automation Engine for Tinh Linh Game.
 * Feature 1: Auto Login, Auto Reconnect & Watchdog Lifecycle.
 * Feature 2: Map & Location Telemetry (getCurrentMapName, getCurrentMapId, getCurrentZone, getPlayerPosition).
 * Feature 3: Exhaustion Coordinate Saving & State Persistence (saveExhaustionCoordinate, isExhaustionDialogVisible).
 * Feature 4: Auto Select Return to Village Menu upon Exhaustion (autoSelectReturnToVillage).
 * Feature 5: Auto Apple Harvest & Collection Automation (handleAppleHarvest, triggerHarvestApple, moveToWaypoint, getCurrentMapWaypoints).
 * Feature 6: Check Version Update Requirement (isVersionUpdateRequired, checkVersionUpdateRequired, getVersionUpdateMessage).
 * Feature 7: Check Server Under Maintenance (isServerUnderMaintenance, checkServerUnderMaintenance, getServerMaintenanceMessage).
 * Feature 8: Return to Saved Exhaustion Coordinate (returnToExhaustionCoordinate, isReturningToExhaustion, isAutoReturnToExhaustionEnabled, moveTo, clearSavedExhaustionCoordinate).
 * Feature 9: Auto Attack Menu Automation (triggerAutoAttackMenu, openAutoAttackMenu, findAutoAttackButton, findMenuButton, isAutoAttackMenuEnabled, setAutoAttackMenuEnabled).
 * Feature 10: Embedded Local HTTP API Server (Port 7654) for Antigravity MCP Bridge (startHttpApiServer, executeBotCommand, getCharacterName, getCharacterLevel, getPlayerMp, getPlayerMaxMp).
 * Feature 11: Post-Login Automation & Combat Dispatcher (handlePostLoginDispatch, isPostLoginDispatched, resetPostLoginDispatch).
 * Feature 12: Live Combat Engine & EXP Progression Tracking (findNearestLivingMonster, enableGameNativeAutoCombat, executeAttackOnTarget, getPlayerExp, getPlayerMaxExp, getPlayerExpPercent, getCombatDebugInfo).
 * Feature 13: Loop Bo Sung: Auto Phuc Loi, Qua Online, Diem Danh & Dong Popup (handleWelfareLoop, handleOnlineReward, handleDailyCheckin, dismissRewardPopups).
 * Feature 14: Loop Bo Sung: Auto To Doi, Tao To Doi & Phe Duyet Thanh Vien (handlePartyAutomation, dismissOrAcceptPartyDialogs, getPartyStatusInfo, isAutoPartyEnabled, setAutoPartyEnabled).
 * Feature 15: Loop Bo Sung: Quet Map tai Map Kiet Suc - Loc Vat The Spawn Random 'Nam Huong', 'Qua Mong', 'Co Hoi Sinh' (isAtExhaustionMap, handleExhaustionMapScan, getExhaustionMapScanInfo, isTargetSpawnItemName, isMushroomName, lastScannedMushrooms).
 * Feature 16: Loop Bo Sung: Quet Tui Do Nhan Vat (handleBagScan, getBagItems, getBagSummary, lastScannedBagItems, isAutoBagScanEnabled, setAutoBagScanEnabled).
 * Feature 17: Loop Bo Sung: Tu Dong Dung Vat Pham 'Nam Huong' Trong Tui Do (handleAutoUseMushroom, isAutoUseMushroomEnabled, setMushroomUseIntervalMs).
 * Feature 18: Loop Bo Sung: Tu Dong Nhat Item Spawn Random Tren Map Kiet Suc (handlePickupTargetMapItems, isAutoPickupMapItemsEnabled, setAutoPickupMapItemsEnabled, getTotalPickedItemCount, getLastPickedItemName).
 */
public final class TinhLinhBot {
    private static final String VERSION = "1.9.10-Feature18-AutoPickupMapItems";
    private static final long POLL_INTERVAL_MS = 800L;
    private static final long LOADING_TIMEOUT_MS = 180_000L;
    private static final long MAX_LOG_FILE_BYTES = 3 * 1024 * 1024; // 3MB

    // Feature 10: Embedded Local HTTP API Server (Port 7654) cho Antigravity MCP Plugin
    private static volatile HttpServer httpApiServer = null;
    private static final int HTTP_API_PORT = 7654;
    private static final List<String> RECENT_LOGS = new ArrayList<>();
    private static volatile long lastHttpBindRetryTime = 0L;

    private static final AtomicBoolean STARTED = new AtomicBoolean(false);
    private static volatile boolean isLoggingIn = false;
    private static volatile boolean wasInGame = false;
    private static volatile boolean postLoginDispatched = false;
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

    // Feature 5: Tu dong Hai Tao & Thu Hoach (Apple Harvest & Farm Portal Automation)
    private static volatile boolean isAutoAppleHarvestEnabled = true;
    private static volatile boolean hasHarvestedApple = false;
    private static volatile boolean isAppleHarvesting = false;
    private static volatile int appleHarvestStep = 0;
    private static volatile long appleHarvestStartTime = 0L;
    private static volatile long appleEnterNongTraiTime = 0L;
    private static volatile int currentHarvestTreeId = -1;
    private static volatile int currentHarvestTreeTypeId = -1;
    private static volatile long lastMenuClickTime = 0L;
    private static volatile long lastWaypointMoveTime = 0L;

    private static volatile String savedUsername = null;
    private static volatile String savedPassword = null;

    // Feature 6 & 7: Trang thai kiem tra Yeu cau Cap nhat Phien ban & Server Bao tri
    private static volatile String lastDetectedVersionUpdateMsg = "";
    private static volatile long lastDetectedVersionUpdateTime = 0L;
    private static volatile String lastDetectedMaintenanceMsg = "";
    private static volatile long lastDetectedMaintenanceTime = 0L;
    private static volatile long lastMaintenanceLogTime = 0L;

    // Feature 8: Tu dong Quay lai Toa do Kiet suc sau khi Hai Tao / Ve Lang
    private static volatile boolean isReturningToExhaustion = false;
    private static volatile boolean isAutoReturnToExhaustionEnabled = true;
    private static volatile long lastReturnActionTime = 0L;
    private static volatile int returnArrivalSamples = 0;
    private static volatile long returnStartTime = 0L;
    private static final float ARRIVAL_RADIUS = 2.0f;

    // Feature 9: Tu dong Kich hoat Menu Auto Tan Cong (Auto Attack Menu Automation)
    private static volatile boolean isAutoAttackMenuEnabled = true;
    private static volatile long lastAutoAttackTriggerTime = 0L;
    private static volatile boolean isAutoAttackActive = false;
    private static final long AUTO_ATTACK_MENU_DELAY_MS = 400L;
    private static final long AUTO_ATTACK_CONFIRM_DELAY_MS = 300L;
    private static final long AUTO_ATTACK_CONFIRM_TIMEOUT_MS = 1_500L;
    private static final long AUTO_ATTACK_ATTEMPT_TIMEOUT_MS = 5_000L;
    private static final int AUTO_ATTACK_PHASE_INITIAL = 0;
    private static final int AUTO_ATTACK_PHASE_DIRECT_CONFIRM = 1;
    private static final int AUTO_ATTACK_PHASE_MENU_ITEM = 2;
    private static final int AUTO_ATTACK_PHASE_MENU_CONFIRM = 3;
    private static volatile boolean autoAttackAttemptPending = false;
    private static volatile boolean autoAttackRenderTaskQueued = false;
    private static volatile int autoAttackPhase = AUTO_ATTACK_PHASE_INITIAL;
    private static volatile long autoAttackAttemptStartTime = 0L;
    private static volatile long autoAttackPhaseStartTime = 0L;
    private static volatile long autoAttackPhaseDueTime = 0L;
    private static volatile Actor autoAttackLastClickedButton = null;

    // Feature 12: Live Combat Engine & EXP Progression Tracking
    private static volatile long lastRecordedExp = -1L;
    private static volatile long lastCombatMoveTime = 0L;
    private static volatile long lastAttackExecuteTime = 0L;
    private static volatile long lastAttackLogTime = 0L;
    private static volatile long lastCombatScanTime = 0L;
    private static volatile long lastExpLogTime = 0L;

    // Sticky Target Locking: Giu chat 1 quai danh den khi ha guc hoan toan
    private static volatile com.a.c.f.a.b.g.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 currentCombatTarget = null;
    private static volatile int currentCombatTargetId = -1;
    private static volatile long currentTargetLockTime = 0L;
    private static volatile int lastTargetLoggedId = -1;
    private static final long TARGET_LOCK_TIMEOUT_MS = 25_000L; // 25s timeout neu quai bi ket/khong danh duoc

    // Feature 13: Auto Phuc Loi, Qua Online & Diem Danh Hang Ngay
    private static volatile boolean isAutoWelfareEnabled = true;
    private static volatile long lastOnlineRewardCheckTime = 0L;
    private static volatile long lastOnlineRewardClaimTime = 0L;
    private static volatile long lastDailyCheckinCheckTime = 0L;
    private static volatile long lastRewardPopupDismissTime = 0L;
    private static volatile String lastCheckinDate = "";
    private static final String CHECKIN_DATE_FILE = "saved_checkin_date.txt";

    // Feature 14: Loop Bo Sung: Auto To Doi (Tao To Doi & Phe Duyet Thanh Vien)
    private static volatile boolean isAutoPartyEnabled = true;
    private static volatile long lastPartyScanTime = 0L;
    private static volatile long lastPartyCreateTime = 0L;
    private static volatile long lastPartyToggleApproveTime = 0L;
    private static volatile long lastApplicantApproveTime = 0L;
    private static volatile long lastPartyDialogCheckTime = 0L;

    // Feature 15: Loop Bo Sung: Quet Map tai Map Kiet Suc (Loc Vat The Spawn Random 'Nam Huong')
    private static volatile boolean isAutoMapScanEnabled = true;
    private static volatile long lastExhaustionMapScanTime = 0L;
    private static volatile long lastExhaustionMapScanLogTime = 0L;
    private static volatile int lastScannedMushroomCount = 0;
    public static final List<ScannedMushroom> lastScannedMushrooms = new CopyOnWriteArrayList<>();

    // Feature 18: Loop Bo Sung: Tu Dong Nhat Item Spawn Random Tren Map Kiet Suc (Nam Huong, Qua Mong, Co Hoi Sinh)
    private static volatile boolean isAutoPickupMapItemsEnabled = true;
    private static volatile long lastPickupAttemptTime = 0L;
    private static volatile long lastPickupMoveTime = 0L;
    private static volatile int totalPickedItemCount = 0;
    private static volatile String lastPickedItemName = "";
    private static final Map<Integer, Integer> pickupAttemptCounts = new ConcurrentHashMap<>();
    private static final Map<Integer, Long> ignoredPickupItems = new ConcurrentHashMap<>();

    // Feature 16: Loop Bo Sung: Quet Hanh Trang & Tui Do Nhan Vat (Character Equip & Bag Scanner)
    private static volatile boolean isAutoBagScanEnabled = true;
    private static volatile long lastBagScanTime = 0L;
    private static volatile long lastBagScanLogTime = 0L;
    private static volatile int lastScannedBagCount = 0;
    private static volatile long lastScannedBagTotalQty = 0L;
    private static volatile int lastDuiGaCount = 0;
    private static volatile long lastBagGold = 0L;
    private static volatile long lastBagGem = 0L;
    private static volatile long lastBagLocked = 0L;
    public static final List<BagItem> lastScannedEquipItems = new CopyOnWriteArrayList<>();
    private static volatile int lastScannedEquipCount = 0;
    public static final List<BagItem> lastScannedBagItems = new CopyOnWriteArrayList<>();
    public static final List<BagItem> lastScannedBoxItems = new CopyOnWriteArrayList<>();
    private static volatile int lastScannedBoxCount = 0;

    // Feature 17: Tu dong su dung vat pham 'Nam huong' trong tui do
    private static volatile boolean isAutoUseMushroomEnabled = true;
    private static volatile long lastMushroomUseTime = 0L;
    private static volatile long mushroomUseIntervalMs = 1_800_000L; // 30 phut (sau khi test nhanh 30s thanh cong)
    private static volatile int lastMushroomCountInBag = 0;
    private static volatile String lastMushroomUseResult = "";

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
        loadCheckinDate();

        log("========================================================");
        log(" [TinhLinhBot] He Thong Auto Login & Watchdog Bat Dau!");
        log(" Phien Ban: " + VERSION);
        log(" Tai khoan mac dinh: " + (savedUsername != null ? savedUsername : "(chua co)"));
        log(" Auto Login Enabled: " + isAutoLoginEnabled());
        log("========================================================");

        // Feature 10: Khoi dong Local HTTP REST API Server tren cong 7654 cho Antigravity MCP Plugin
        startHttpApiServer();

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
                && screen == game.gIrlKuN75NEKIlILIIiLlLWHatDOYouWanthereHihIhiHaHahAhOhoHOhEHEHEGIRLkun75()
                && getPlayerPosition() != null;

        long now = System.currentTimeMillis();

        // Retry bind HTTP API server dinh ky moi 10s neu luc khoi dong bi trung cong
        if (httpApiServer == null && now - lastHttpBindRetryTime >= 10_000L) {
            lastHttpBindRetryTime = now;
            startHttpApiServer();
        }

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
            log("[WatchdogLoad] Da thoat man hinh loading. Reset timeout. Cho game nap nhan vat va map...");
            loadingScreenStartTime = 0L;
            lastLoginAttemptTime = now; // Cho game co it nhat 25s nap the gioi truoc khi cho phep retry
        }

        // --- 4. Xu ly Auto Login & Ket Noi Mang khi chua vao game ---
        if (!isInGame) {
            wasInGame = false;
            postLoginDispatched = false;

            if (!isAutoLoginEnabled()) {
                return;
            }

            // Cho it nhat 15s sau khi bat game de VPS load day du asset truoc khi bat dau login
            if (isLoggingIn || now - gameStartTime <= 15_000L) {
                return;
            }

            // Tang thoi gian cho load man hinh them 15-20s:
            // Lan 1 va 2 cho 25s (thay vi 8s cu). Tu lan 3 tro di cho 35s (thay vi 15s cu).
            long backoffInterval = (loginAttempts < 3) ? 25_000L : 35_000L;
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
                // Feature 6: Kiem tra Thong bao Cap Nhat Phien Ban
                if (isVersionUpdateRequired()) {
                    String msg = getVersionUpdateMessage();
                    log("[ClientVersion] PHAT HIEN THONG BAO YEU CAU CAP NHAT PHIEN BAN: '" + msg + "' -> Tam dung Auto Login de cap nhat!");
                    return;
                }

                // Feature 7: Kiem tra Thong bao May Chu Dang Bao Tri
                if (isServerUnderMaintenance()) {
                    String msg = getServerMaintenanceMessage();
                    log("[ServerMaintenance] PHAT HIEN MAY CHU DANG BAO TRI: '" + msg + "' -> Tam dung dang nhap (se thu lai sau 60s)...");
                    lastLoginAttemptTime = now + 60_000L;
                    return;
                }

                loginAttempts++;
                log("[AutoLogin] Server da ket noi. Dang thuc hien dang nhap lan " + loginAttempts + "... (Cho toi da 25s nap the gioi)");
                lastLoginAttemptTime = now;
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

        // --- 5.0. Feature 11: Post-Login Dispatch (Kich hoat Auto Tan Cong theo 2 truong hop sau dang nhap) ---
        if (wasInGame && !postLoginDispatched) {
            int curMapId = getCurrentMapId();
            String curMap = getCurrentMapName();
            Vector2 curPos = getPlayerPosition();
            if (curMap != null && !curMap.trim().isEmpty() && curPos != null) {
                postLoginDispatched = true;
                handlePostLoginDispatch(curMapId, curMap, curPos);
            }
        }

        // --- 5.1. Giam sat Thong bao Bao Tri trong game ---
        if (isServerUnderMaintenance()) {
            if (now - lastMaintenanceLogTime > 60_000L) {
                lastMaintenanceLogTime = now;
                String msg = getServerMaintenanceMessage();
                log("[ServerMaintenance] CANH BAO TRONG GAME: Phat hien thong bao bao tri may chu: '" + msg + "'");
            }
        }

        // --- 6. Giam sat Vi tri & Map hien tai (Location Telemetry) ---
        checkLocationTelemetry(now);

        // --- 6.1. Feature 13: Loop Bo Sung - Auto Phuc Loi, Qua Online, Diem Danh & Dong Popup ---
        handleWelfareLoop(now);

        // --- 6.2. Feature 14: Loop Bo Sung - Auto To Doi (Tao To Doi & Phe Duyet Thanh Vien) ---
        handlePartyAutomation(now);

        // --- 6.3. Feature 15: Loop Bo Sung - Quet Map tai Map Kiet Suc (Loc Vat The Spawn Random 'Nam Huong') ---
        handleExhaustionMapScan(now);

        // --- 6.4. Feature 16: Loop Bo Sung - Quet Tui Do Nhan Vat (Character Bag Scanner) ---
        handleBagScan(now);

        // --- 7. Tu dong Hai Tao & Di chuyen qua Cong Nong Trai / Lang ---
        handleAppleAndFarmNavigation(now);

        // --- 8. Tu dong Quay lai Toa do Kiet suc sau khi Hai Tao / Ve Lang ---
        handleReturnToExhaustionNavigation(now);

        // --- 9. Tu dong Duy tri Menu Auto Tan Cong khi o bai train ---
        handleAutoAttackFlow(now);
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

    public static long getPlayerHp() {
        try {
            com.a.c.f.a.b.j.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75 player =
                    com.a.c.f.a.b.j.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75.GiRLKUN75NEklliilLliIiwhATDOyOUWanTheREhIhIHiHAHahahOHOHOhEhEHeGiRLkuN75();
            if (player != null && player.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 != null) {
                return player.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75.GirLKun75NekiiiIIIIiIiwHATDoYoUWANtHERehihIhIHAHAhAHOhOhoHEhehegIrlKUN75;
            }
        } catch (Throwable ignored) {
        }
        return -1L;
    }

    public static long getPlayerMaxHp() {
        try {
            com.a.c.f.a.b.j.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75 player =
                    com.a.c.f.a.b.j.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75.GiRLKUN75NEklliilLliIiwhATDOyOUWanTheREhIhIHiHAHahahOHOHOhEhEHeGiRLkuN75();
            if (player != null && player.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 != null) {
                return player.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75.GIrlKUn75NeKLiiIlIiliLWhAtDOyouWanthErehihIHiHaHAhahoHOhoHEhehEGIRlKUN75;
            }
        } catch (Throwable ignored) {
        }
        return -1L;
    }

    /**
     * Kiem tra xem nhan vat co dang bi kiet suc (HP = 0) hay khong.
     */
    public static boolean isPlayerExhausted() {
        try {
            long curHp = getPlayerHp();
            if (curHp >= 0) {
                return curHp <= 0;
            }
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
     * Tim hop thoai kiet suc thuc su dang mo tren man hinh.
     * Hop thoai kiet suc phai nam trong DialogManager va co chu 'kiet suc'.
     * Neu player dang HP <= 0, hop thoai co 've lang' / 'hoi sinh' trong dialogManager cung duoc chap nhan.
     */
    public static Actor getVisibleExhaustionDialog() {
        try {
            com.a.c.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75 game =
                    com.a.c.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75;
            if (game == null) return null;
            com.a.c.f.a.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 world =
                    game.gIrlKuN75NEKIlILIIiLlLWHatDOYouWanthereHihIhiHaHahAhOhoHOhEHEHEGIRLkun75();
            if (world == null) return null;

            com.a.c.f.a.b.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75 uiOverlay =
                    world.GIRLkuN75nEkLlLiiLIlLlwhATdoYouwaNtherEHiHiHihaHaHAHOHOHoHehEHeGIrlKun75;
            if (uiOverlay == null) return null;

            com.a.c.f.e.a.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75 dialogManager =
                    uiOverlay.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75;
            if (dialogManager == null) return null;

            SnapshotArray<Actor> children = dialogManager.getChildren();
            if (children == null || children.size == 0) return null;

            boolean dead = isPlayerExhausted();

            for (int i = 0; i < children.size; i++) {
                Actor child = children.get(i);
                if (child != null && child.isVisible() && child.getColor().a > 0.1f) {
                    String norm = normalizeText(getActorText(child));
                    if (norm.contains("kiệt sức") || norm.contains("kiet suc")) {
                        return child;
                    }
                    if (dead && (norm.contains("về làng") || norm.contains("ve lang") || norm.contains("hồi sinh") || norm.contains("hoi sinh"))) {
                        return child;
                    }
                }
            }
        } catch (Throwable ignored) {
        }
        return null;
    }

    /**
     * Kiem tra xem popup/dialog kiet suc (hoi sinh / ve lang) co dang hien thi tren man hinh hay khong.
     */
    public static boolean isExhaustionDialogVisible() {
        return getVisibleExhaustionDialog() != null;
    }

    private static String normalizeText(String raw) {
        if (raw == null) return "";
        // Loai bo cac the dinh dang mau/font nhu [#E0A050] hoac {COLOR=RED} trong TextraLabel / LibGDX
        String s = raw.replaceAll("\\[[^\\]]*\\]", " ").replaceAll("\\{[^\\}]*\\}", " ");
        // Loai bo dau tieng Viet (accent/diacritics)
        s = Normalizer.normalize(s, Normalizer.Form.NFD)
                .replaceAll("\\p{M}", "")
                .replace("đ", "d")
                .replace("Đ", "D")
                .replace('?', ' ');
        return s.trim().toLowerCase(Locale.ROOT);
    }

    private static boolean containsExhaustionText(Actor actor) {
        if (actor == null) return false;
        String text = normalizeText(getActorText(actor));
        if (text.isEmpty()) return false;
        return text.contains("kiệt sức") || text.contains("kiet suc");
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

        // Reset trang thai hai tao de khi hoi sinh ve lang se tu dong qua Nong trai thu hoach
        hasHarvestedApple = false;
        isAppleHarvesting = false;
        appleHarvestStep = 0;
        appleEnterNongTraiTime = 0L;
        returnStartTime = 0L;
        isReturningToExhaustion = false;
        isAutoReturnToExhaustionEnabled = true;
        isAutoAttackMenuEnabled = true;
        returnArrivalSamples = 0;

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
        if (propFile.exists() && propFile.isFile()) {
            try (InputStream is = new FileInputStream(propFile)) {
                Properties props = new Properties();
                props.load(is);
                int mapId = Integer.parseInt(props.getProperty("mapId", "-1"));
                String mapName = props.getProperty("mapName", "");
                int zone = Integer.parseInt(props.getProperty("zone", "-1"));
                float x = Float.parseFloat(props.getProperty("x", "0.0"));
                float y = Float.parseFloat(props.getProperty("y", "0.0"));
                long savedAt = Long.parseLong(props.getProperty("savedAt", "0"));
                if (mapId >= 0 || (mapName != null && !mapName.trim().isEmpty())) {
                    return new SavedCoordinate(mapId, mapName, zone, x, y, savedAt);
                }
            } catch (Throwable ignored) {
            }
        }

        // Fallback 1: Doc tu saved_exhaustion_coord.txt (format: mapId:mapName:zone:x:y)
        File txtFile = new File(EXHAUSTION_COORD_FILE);
        if (txtFile.exists() && txtFile.isFile()) {
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(new FileInputStream(txtFile), StandardCharsets.UTF_8))) {
                String line = reader.readLine();
                if (line != null && !line.trim().isEmpty()) {
                    String[] parts = line.trim().split(":");
                    if (parts.length >= 5) {
                        int mapId = Integer.parseInt(parts[0].trim());
                        String mapName = parts[1].trim();
                        int zone = Integer.parseInt(parts[2].trim());
                        float x = Float.parseFloat(parts[3].trim());
                        float y = Float.parseFloat(parts[4].trim());
                        return new SavedCoordinate(mapId, mapName, zone, x, y, txtFile.lastModified());
                    }
                }
            } catch (Throwable ignored) {
            }
        }

        return null;
    }

    /**
     * Doc thong tin map train gan nhat tu last_farm_map.txt (neu co).
     */
    public static SavedCoordinate getLastFarmMap() {
        File farmMapFile = new File(LAST_FARM_MAP_FILE);
        if (farmMapFile.exists() && farmMapFile.isFile()) {
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(new FileInputStream(farmMapFile), StandardCharsets.UTF_8))) {
                String line = reader.readLine();
                if (line != null && !line.trim().isEmpty()) {
                    String[] parts = line.trim().split(":");
                    if (parts.length >= 2) {
                        int mapId = Integer.parseInt(parts[0].trim());
                        String mapName = parts[1].trim();
                        return new SavedCoordinate(mapId, mapName, 0, 0.0f, 0.0f, farmMapFile.lastModified());
                    }
                }
            } catch (Throwable ignored) {
            }
        }
        return null;
    }

    /**
     * Tu dong tim va kich hoat lua chon 'Ve Lang' khi popup kiet suc dang hien thi.
     * Chi hoat dong tren hop thoai kiet suc thuc su trong DialogManager (tranh bam nham menu HUD).
     */
    public static synchronized boolean autoSelectReturnToVillage() {
        try {
            Actor exhaustionDialog = getVisibleExhaustionDialog();
            if (exhaustionDialog == null) {
                return false;
            }

            Actor targetButton = findVillageButton(exhaustionDialog);
            if (targetButton != null) {
                String btnText = getActorText(targetButton);
                log("[AutoFarm-Exhaustion] Tim thay nut Ve Lang: [" + (btnText.isEmpty() ? targetButton.getClass().getSimpleName() : btnText) + "] tren popup kiet suc. Dang thuc hien click...");
                Gdx.app.postRunnable(() -> clickActor(targetButton));
                return true;
            }
        } catch (Throwable t) {
            log("[AutoFarm-Exhaustion] Loi trong autoSelectReturnToVillage: " + t.getMessage());
        }
        return false;
    }

    private static Actor findVillageButton(Actor root) {
        if (root == null) return null;

        // 1. Tim tat ca cac NUT (Button / TextraButton / Clickable) tren hop thoai
        List<Actor> buttons = new ArrayList<>();
        findAllButtons(root, buttons, root);

        if (buttons.isEmpty()) {
            return null;
        }

        // 2. Uu tien 1: Duyet qua cac NUT, tim nut co text chua 've lang' / 'về làng' / 've thanh' / 'về thành'
        for (Actor btn : buttons) {
            String norm = normalizeText(getActorText(btn));
            if (!norm.isEmpty() && norm.length() <= 20) {
                if (norm.contains("về làng") || norm.contains("ve lang") || norm.contains("về thành") || norm.contains("ve thanh") || norm.equals("về") || norm.equals("ve")) {
                    log("[AutoFarm-Exhaustion] Tim thay nut Ve Lang theo text: [" + norm + "] tren popup.");
                    return btn;
                }
            }
        }

        // 3. Uu tien 2: Tren hop thoai kiet suc Tinh Linh (layout 3 nut: [Hoi sinh ngoc] [Hoi sinh mien phi] [Ve lang]),
        // nut Ve Lang luon la nut CUOI CUNG (ngoai cung ben phai).
        // Sap xep cac nut theo toa do X Stage tu trai sang phai
        buttons.sort((a, b) -> {
            try {
                float xa = a.localToStageCoordinates(new Vector2(0, 0)).x;
                float xb = b.localToStageCoordinates(new Vector2(0, 0)).x;
                return Float.compare(xa, xb);
            } catch (Throwable t) {
                return Float.compare(a.getX(), b.getX());
            }
        });

        Actor rightmostButton = buttons.get(buttons.size() - 1);
        String txt = getActorText(rightmostButton);
        log("[AutoFarm-Exhaustion] Chon nut ben phai nhat (Ve Lang) trong " + buttons.size() + " nut tren popup: [" +
                (txt.isEmpty() ? rightmostButton.getClass().getSimpleName() : txt) + "]");
        return rightmostButton;
    }

    private static void findAllButtons(Actor actor, List<Actor> list, Actor root) {
        if (actor == null) return;
        if (actor != root && isClickable(actor) && actor.isVisible()) {
            if (!list.contains(actor)) {
                list.add(actor);
            }
            return;
        }
        if (actor instanceof Group) {
            Group group = (Group) actor;
            SnapshotArray<Actor> children = group.getChildren();
            if (children != null) {
                for (int i = 0; i < children.size; i++) {
                    findAllButtons(children.get(i), list, root);
                }
            }
        }
    }

    private static boolean isClickable(Actor actor) {
        if (actor == null) return false;
        if (actor instanceof Button) return true;
        if (actor instanceof TextButton) return true;
        if (actor instanceof TextraButton) return true;
        if (actor.getListeners() != null) {
            SnapshotArray<EventListener> listeners = new SnapshotArray<>(actor.getListeners());
            for (int i = 0; i < listeners.size; i++) {
                EventListener l = listeners.get(i);
                if (l instanceof ClickListener) {
                    return true;
                }
            }
        }
        return false;
    }

    private static String getDirectActorText(Actor actor) {
        if (actor == null) return "";
        if (actor instanceof Label) {
            CharSequence cs = ((Label) actor).getText();
            if (cs != null) return cs.toString();
        }
        if (actor instanceof TextButton) {
            CharSequence cs = ((TextButton) actor).getText();
            if (cs != null) return cs.toString();
        }
        if (actor instanceof TextraLabel) {
            String s = ((TextraLabel) actor).storedText;
            if (s != null && !s.isEmpty()) return s;
            return actor.toString();
        }
        if (actor instanceof TextraButton) {
            String s = ((TextraButton) actor).getText();
            if (s != null && !s.isEmpty()) return s;
            TextraLabel lbl = ((TextraButton) actor).getTextraLabel();
            if (lbl != null && lbl.storedText != null) return lbl.storedText;
        }
        try {
            Method m = actor.getClass().getMethod("getText");
            Object res = m.invoke(actor);
            if (res != null) return res.toString();
        } catch (Throwable ignored) {
        }
        try {
            Field f = actor.getClass().getField("storedText");
            Object res = f.get(actor);
            if (res != null) return res.toString();
        } catch (Throwable ignored) {
        }
        return "";
    }

    private static String getActorText(Actor actor) {
        if (actor == null) return "";
        StringBuilder sb = new StringBuilder();
        collectActorText(actor, sb);
        return sb.toString().trim();
    }

    private static void collectActorText(Actor actor, StringBuilder sb) {
        if (actor == null) return;
        String direct = getDirectActorText(actor);
        if (!direct.isEmpty()) {
            sb.append(direct).append(" ");
        }
        if (actor instanceof Group) {
            Group g = (Group) actor;
            SnapshotArray<Actor> kids = g.getChildren();
            if (kids != null) {
                for (int i = 0; i < kids.size; i++) {
                    collectActorText(kids.get(i), sb);
                }
            }
        }
    }

    private static boolean clickActor(Actor actor) {
        if (actor == null || !actor.isVisible()) return false;
        try {
            float centerX = actor.getWidth() / 2f;
            float centerY = actor.getHeight() / 2f;
            if (centerX <= 0) centerX = 15f;
            if (centerY <= 0) centerY = 10f;

            Vector2 stageCoords = actor.localToStageCoordinates(new Vector2(centerX, centerY));
            Stage stage = actor.getStage();
            if (stage == null) return false;

            // Fire one Scene2D input sequence on the render thread. Direct listener
            // calls plus synthetic events could toggle the same button twice.
            InputEvent downEvent = new InputEvent();
            downEvent.setType(InputEvent.Type.touchDown);
            downEvent.setStage(stage);
            downEvent.setTarget(actor);
            downEvent.setStageX(stageCoords.x);
            downEvent.setStageY(stageCoords.y);
            downEvent.setPointer(0);
            downEvent.setButton(0);
            actor.fire(downEvent);

            InputEvent upEvent = new InputEvent();
            upEvent.setType(InputEvent.Type.touchUp);
            upEvent.setStage(stage);
            upEvent.setTarget(actor);
            upEvent.setStageX(stageCoords.x);
            upEvent.setStageY(stageCoords.y);
            upEvent.setPointer(0);
            upEvent.setButton(0);
            actor.fire(upEvent);

            log("[AutoFarm-Exhaustion] Da kich hoat click thanh cong vao Actor: [" + actor.getClass().getSimpleName() +
                    "] tai Stage coords (X=" + String.format(Locale.ROOT, "%.1f", stageCoords.x) +
                    ", Y=" + String.format(Locale.ROOT, "%.1f", stageCoords.y) + ").");
            return true;
        } catch (Throwable t) {
            log("[AutoFarm-Exhaustion] Loi khi kich hoat click actor: " + t.getMessage());
            return false;
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
        boolean dead = isPlayerExhausted();
        boolean hasDialog = isExhaustionDialogVisible();
        boolean exhausted = dead || hasDialog;

        // 1. Theo doi va tu dong luu toa do khi phat hien kiet suc (rising-edge trigger)
        if (exhausted && !previousExhausted) {
            log("[AutoFarm-Exhaustion] PHAT HIEN TRANG THAI KIET SUC! Tu dong luu toa do tran danh...");
            saveExhaustionCoordinate();
            if (hasDialog) {
                log("[AutoFarm-Exhaustion] Tu dong chon menu [Ve Lang] tren popup...");
                autoSelectReturnToVillage();
            }
        } else if (exhausted) {
            // Neu van con kiet suc va popup chua dong, thu chon lai menu Ve Lang moi 2.4s (3 ticks)
            if (now - lastVillageSelectAttemptTime >= 2400L) {
                lastVillageSelectAttemptTime = now;
                if (hasDialog) {
                    autoSelectReturnToVillage();
                }
            }
        } else if (!exhausted && previousExhausted) {
            log("[AutoFarm-Exhaustion] Nhan vat da ve lang / thoat trang thai kiet suc.");
        }
        if (exhausted) {
            currentCombatTarget = null;
            currentCombatTargetId = -1;
            lastTargetLoggedId = -1;
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
            long curHp = getPlayerHp();
            long maxHp = getPlayerMaxHp();
            String hpStr = (curHp >= 0 && maxHp > 0) ? String.format(Locale.ROOT, " [HP: %d/%d]", curHp, maxHp) : "";
            String statusStr = exhausted ? ("[KIET SUC" + hpStr + "]") : ("[BINH THUONG" + hpStr + "]");
            if (mapChanged) {
                currentCombatTarget = null;
                currentCombatTargetId = -1;
                lastTargetLoggedId = -1;
                log("[AutoFarm-Map] CHUYEN MAP -> Map [" + mapName + " - ID: " + mapId + ", Khu: " + zone + "] tai " + posStr + " " + statusStr);
            } else {
                log("[AutoFarm-Map] Dang o Map [" + mapName + " - ID: " + mapId + ", Khu: " + zone + "] tai " + posStr + " " + statusStr);
            }
        }
    }

    // =========================================================================
    // FEATURE 5: TU DONG HAI TAO & THU HOACH (APPLE HARVEST & FARM PORTAL)
    // =========================================================================

    public static boolean isAutoAppleHarvestEnabled() {
        if (new File("tat_auto_hai_tao.txt").exists() || new File("no_auto_apple.txt").exists()) {
            return false;
        }
        return isAutoAppleHarvestEnabled;
    }

    public static void setAutoAppleHarvestEnabled(boolean enabled) {
        isAutoAppleHarvestEnabled = enabled;
        log("[AutoFarm-Apple] Auto Apple Harvest da chuyen thanh: " + enabled);
    }

    public static boolean hasHarvestedApple() {
        return hasHarvestedApple;
    }

    public static void setHasHarvestedApple(boolean harvested) {
        hasHarvestedApple = harvested;
    }

    public static boolean isAppleHarvesting() {
        return isAppleHarvesting;
    }

    /**
     * Kich hoat quy trinh hai tao thu cong / reset co thu hoach tao de bot bat dau chu trinh hai tao ngay.
     */
    public static synchronized boolean triggerHarvestApple() {
        log("[AutoFarm-Apple] Kich hoat lenh triggerHarvestApple -> San sang thu hoach!");
        hasHarvestedApple = false;
        isAppleHarvesting = false;
        appleHarvestStep = 0;
        appleEnterNongTraiTime = 0L;
        int curMapId = getCurrentMapId();
        String curMap = getCurrentMapName();
        String normMap = normalizeText(curMap);
        boolean isFarm = (curMapId == 5) || (normMap.contains("nong") && normMap.contains("trai")) || normMap.contains("nong");
        boolean isVillage = (curMapId == 2 || curMapId == 0) || normMap.contains("lang") || normMap.contains("eldarah");

        if (isFarm) {
            return handleAppleHarvest();
        } else if (isVillage) {
            com.a.c.f.a.b.e.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75 farmWp = findWaypointByName("nong trai");
            if (farmWp == null) {
                farmWp = findWaypointByName("nong");
            }
            if (farmWp != null) {
                return moveToWaypoint(farmWp);
            }
        }
        return true;
    }

    /**
     * Dieu khien di chuyen va thu hoach tao giua Lang va Nong trai theo tung chu ky tick.
     */
    private static void handleAppleAndFarmNavigation(long now) {
        if (!isAutoAppleHarvestEnabled()) {
            return;
        }

        int mapId = getCurrentMapId();
        String mapName = getCurrentMapName();
        String normMap = normalizeText(mapName);

        boolean isVillage = (mapId == 2 || mapId == 0) || normMap.contains("lang") || normMap.contains("eldarah");
        boolean isFarm = (mapId == 5) || (normMap.contains("nong") && normMap.contains("trai")) || normMap.contains("nong");

        // 1. Truong hop dang o Lang va chua thu hoach tao -> Di vao cong Nong trai
        if (isVillage && !hasHarvestedApple) {
            if (now - lastWaypointMoveTime >= 3500L) {
                lastWaypointMoveTime = now;
                com.a.c.f.a.b.e.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75 farmWp =
                        findWaypointToTargetMap(mapId, mapName, 5, "Nông trại");
                if (farmWp == null) {
                    farmWp = findWaypointByName("nong trai");
                }
                if (farmWp == null) {
                    farmWp = findWaypointByName("nong");
                }
                if (farmWp == null) {
                    farmWp = findWaypointByName("trai");
                }
                if (farmWp != null) {
                    log("[AutoFarm-Apple] Nhan vat dang o Lang va chua thu hoach tao -> Di chuyen vao cong Nong trai [" + getWaypointName(farmWp) + "]...");
                    moveToWaypoint(farmWp);
                } else {
                    Array<com.a.c.f.a.b.e.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75> wps = getCurrentMapWaypoints();
                    if (wps != null && wps.size > 0) {
                        log("[AutoFarm-Apple] Dang o Lang nhung khong tim thay Waypoint Nong trai trong " + wps.size + " cong tren map.");
                    }
                }
            }
        }
        // 2. Truong hop dang o Nong trai
        else if (isFarm) {
            if (!hasHarvestedApple) {
                handleAppleHarvest();
            } else {
                // Da thu hoach xong tao ma van con trong Nong trai -> di chuyen ra cong ve lai Lang
                if (now - lastWaypointMoveTime >= 3500L) {
                    lastWaypointMoveTime = now;
                    com.a.c.f.a.b.e.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75 villageWp =
                            findWaypointToTargetMap(mapId, mapName, 2, "Làng");
                    if (villageWp == null) {
                        villageWp = findWaypointByName("lang");
                    }
                    if (villageWp == null) {
                        villageWp = findWaypointByName("ve lang");
                    }
                    if (villageWp == null) {
                        Array<com.a.c.f.a.b.e.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75> wps = getCurrentMapWaypoints();
                        if (wps != null && wps.size == 1) {
                            villageWp = wps.get(0);
                        }
                    }
                    if (villageWp != null) {
                        log("[AutoFarm-Apple] Da thu hoach xong tao. Dang o Nong trai -> Di chuyen ra cong ve lai Lang [" + getWaypointName(villageWp) + "]...");
                        moveToWaypoint(villageWp);
                    }
                }
            }
        }
    }

    /**
     * Quy trinh State Machine 5 buoc thu hoach Cay Tao tai Nong Trai:
     * - Buoc 0: Tim cay, luu ID & toa do, di chuyen tiep can.
     * - Buoc 1: Kiem tra tiep can (khoang cach <= 40px hoac timeout 1.2s), dung van toc, gui packet tuong tac cay.
     * - Buoc 2: Phat hien dialog/menu, click lua chon 'Cay tao' (chuyen buoc 3) hoac click 'Thu hoach' (chuyen buoc 4).
     * - Buoc 3: Cho menu con xuat hien, click lua chon 'Thu hoach', gui packet lua chon.
     * - Buoc 4: Cho server dong bo, dong toan bo dialog, danh dau hoan tat.
     */
    public static boolean handleAppleHarvest() {
        if (hasHarvestedApple) {
            return false;
        }

        int mapId = getCurrentMapId();
        String mapName = getCurrentMapName();
        String normMap = normalizeText(mapName);
        boolean isFarm = (mapId == 5) || (normMap.contains("nong") && normMap.contains("trai")) || normMap.contains("nong");
        if (!isFarm) {
            return false;
        }

        long now = System.currentTimeMillis();
        if (appleEnterNongTraiTime == 0L) {
            appleEnterNongTraiTime = now;
        }

        // Cho it nhat 500ms sau khi vao map de load entity
        if (now - appleEnterNongTraiTime < 500L) {
            return true;
        }

        com.a.c.f.a.b.j.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75 player =
                com.a.c.f.a.b.j.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75.GiRLKUN75NEklliilLliIiwhATDOyOUWanTheREhIhIHiHAHahahOHOHOhEhEHeGiRLkuN75();
        if (player == null) {
            return false;
        }

        // Quet tim Cay Tao tren map nong trai
        int treeId = -1;
        int treeTypeId = -1;
        Vector2 treePos = null;
        String treeName = "";

        // 1. Quet tu mang HEntity (gIRlkUn75nEKiilIIIILilwhatDoYOuwaNtherEhiHiHihAHahAhoHOhoHeheheGirlKUN75)
        Array<com.a.c.f.a.b.h.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75> hArray = null;
        try {
            hArray = com.a.c.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75.gIRlkUn75nEKiilIIIILilwhatDoYOuwaNtherEhiHiHihAHahAhoHOhoHeheheGirlKUN75;
        } catch (Throwable ignored) {
        }

        if (hArray != null && hArray.size > 0) {
            for (int i = 0; i < hArray.size; i++) {
                com.a.c.f.a.b.h.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 e = hArray.get(i);
                if (e != null) {
                    String rawName = getEntityHName(e);
                    String norm = normalizeText(rawName);
                    if (norm.contains("tao") || norm.contains("cay") || hArray.size == 1) {
                        treeId = e.a_();
                        treeTypeId = getEntityHTypeId(e);
                        treePos = e.gIRLkuN75nEKliLILiiLiiWhAtDOYOUwAnTherehiHihIHAHAhaHOhohohEheHEgIRlKUN75();
                        treeName = rawName;
                        break;
                    }
                }
            }
            if (treeId < 0 && hArray.get(0) != null) {
                com.a.c.f.a.b.h.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 e = hArray.get(0);
                treeId = e.a_();
                treeTypeId = getEntityHTypeId(e);
                treePos = e.gIRLkuN75nEKliLILiiLiiWhAtDOYOUwAnTherehiHihIHAHAhaHOhohohEheHEgIRlKUN75();
                treeName = getEntityHName(e);
            }
        }

        // 2. Quet tu mang Tree/Monster (GiRLKUN75NEklliilLliIiwhATDOyOUWanTheREhIhIHiHAHahahOHOHOhEhEHeGiRLkuN75)
        if (treeId < 0) {
            Array<com.a.c.f.a.b.g.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75> treeArray = null;
            try {
                treeArray = com.a.c.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75.GiRLKUN75NEklliilLliIiwhATDOyOUWanTheREhIhIHiHAHahahOHOHOhEhEHeGiRLkuN75;
            } catch (Throwable ignored) {
            }
            if (treeArray != null && treeArray.size > 0) {
                for (int i = 0; i < treeArray.size; i++) {
                    com.a.c.f.a.b.g.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 t = treeArray.get(i);
                    if (t != null) {
                        String rawName = getTreeName(t);
                        String norm = normalizeText(rawName);
                        if (norm.contains("tao") || treeArray.size == 1) {
                            treeId = t.a_();
                            treeTypeId = getTreeTypeId(t);
                            treePos = t.gIRLkuN75nEKliLILiiLiiWhAtDOYOUwAnTherehiHihIHAHAhaHOhohohEheHEgIRlKUN75();
                            treeName = rawName;
                            break;
                        }
                    }
                }
                if (treeId < 0 && treeArray.get(0) != null) {
                    com.a.c.f.a.b.g.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 t = treeArray.get(0);
                    treeId = t.a_();
                    treeTypeId = getTreeTypeId(t);
                    treePos = t.gIRLkuN75nEKliLILiiLiiWhAtDOYOUwAnTherehiHihIHAHAhaHOhohohEheHEgIRlKUN75();
                    treeName = getTreeName(t);
                }
            }
        }

        // 3. Quet tu mang NPC (GIrlkuN75nEKillILLIiiiwhaTdoYouWANTherEhihIHihAhAhahoHOHohEHehEGIRLkUN75)
        if (treeId < 0) {
            Array<com.a.c.f.a.b.d.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75> npcArray = null;
            try {
                npcArray = com.a.c.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75.GIrlkuN75nEKillILLIiiiwhaTdoYouWANTherEhihIHihAhAhahoHOHohEHehEGIRLkUN75;
            } catch (Throwable ignored) {
            }
            if (npcArray != null && npcArray.size > 0) {
                for (int i = 0; i < npcArray.size; i++) {
                    com.a.c.f.a.b.d.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 n = npcArray.get(i);
                    if (n != null) {
                        String rawName = getNPCName(n);
                        String norm = normalizeText(rawName);
                        if (norm.contains("tao") || norm.contains("cay") || npcArray.size == 1) {
                            treeId = n.a_();
                            treeTypeId = getNPCTypeId(n);
                            treePos = n.gIRLkuN75nEKliLILiiLiiWhAtDOYOUwAnTherehiHihIHAHAhaHOhohohEheHEgIRlKUN75();
                            treeName = rawName;
                            break;
                        }
                    }
                }
            }
        }

        // Neu van khong tim thay cay sau 3.5s
        if (treeId < 0) {
            if (now - appleEnterNongTraiTime < 3500L) {
                return true;
            }
            log("[AutoFarm-Apple] Khong tim thay thong tin Cay Tao tai nong trai -> Bo qua thu hoach.");
            hasHarvestedApple = true;
            isAppleHarvesting = false;
            appleHarvestStep = 0;
            appleEnterNongTraiTime = 0L;
            return false;
        }

        final int finalTreeId = treeId;
        final int finalTreeTypeId = treeTypeId;
        final Vector2 finalTreePos = treePos;
        final String finalTreeName = (treeName != null && !treeName.isEmpty()) ? treeName : "Cay Tao";

        // --- BUOC 0: Phat hien cay va khoi dong tiep can ---
        if (appleHarvestStep == 0) {
            appleHarvestStep = 1;
            isAppleHarvesting = true;
            appleHarvestStartTime = now;
            currentHarvestTreeId = finalTreeId;
            currentHarvestTreeTypeId = finalTreeTypeId;
            log("[AutoFarm-Apple] Phat hien [" + finalTreeName + "] (ID=" + finalTreeId + ", Type=" + finalTreeTypeId + ") tai nong trai. Dang tiep can de thu hoach...");

            if (finalTreePos != null) {
                Gdx.app.postRunnable(() -> {
                    try {
                        if (player.girLKUn75nEkLiLLlIllLIWhAtdOyouWaNTHErehIHiHiHahAhAHOHoHohEhEHegirLkUN75 != null) {
                            player.girLKUn75nEkLiLLlIllLIWhAtdOyouWaNTHErehIHiHiHahAhAHOHoHohEhEHegirLkUN75.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75(
                                    finalTreePos.x, finalTreePos.y, null
                            );
                        }
                    } catch (Throwable t) {
                        log("[AutoFarm-Apple] Loi di chuyen den Cay Tao: " + t.getMessage());
                    }
                });
            }
            return true;
        }

        // --- BUOC 1: Kiem tra da tiep can va gui goi tin tuong tac ---
        if (appleHarvestStep == 1) {
            long stepElapsed = now - appleHarvestStartTime;
            float dist = 999f;
            Vector2 playerPos = getPlayerPosition();
            if (playerPos != null && finalTreePos != null) {
                dist = playerPos.dst(finalTreePos);
            }

            if (dist > 40f && stepElapsed < 1200L) {
                return true; // Tiep tuc di chuyen
            }

            appleHarvestStep = 2;
            appleHarvestStartTime = now;
            log("[AutoFarm-Apple] Da tiep can Cay Tao (khoang cach=" + (int) dist + "px). Dang gui goi tin tuong tac cay len server...");

            Gdx.app.postRunnable(() -> {
                try {
                    if (player.girLKUn75nEkLiLLlIllLIWhAtdOyouWaNTHErehIHiHiHahAhAHOHoHohEhEHegirLkUN75 != null) {
                        player.girLKUn75nEkLiLLlIllLIWhAtdOyouWaNTHErehIHiHiHahAhAHOHoHohEhEHegirLkUN75.GirLKun75nEkLlilLiLlILwHATDOYouWaNtherEHIhIHIHAhahAHoHoHoHEheHegiRlkun75(false);
                    }
                    stopPlayerVelocity(player);

                    com.a.d.a.gIRLkuN75nEKliLILiiLiiWhAtDOYOUwAnTherehiHihIHAHAhaHOhohohEheHEgIRlKUN75 sender =
                            com.a.d.a.gIRLkuN75nEKliLILiiLiiWhAtDOYOUwAnTherehiHihIHAHAhaHOhohohEheHEgIRlKUN75.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75();
                    if (sender != null) {
                        sender.GirLKun75nEkLlilLiLlILwHATDOYouWaNtherEHIhIHIHAhahAHoHoHoHEheHegiRlkun75(finalTreeId, finalTreeTypeId);
                        log("[AutoFarm-Apple] Da gui packet tuong tac Cay Tao (ID=" + finalTreeId + ", Type=" + finalTreeTypeId + ")!");
                    }
                } catch (Throwable t) {
                    log("[AutoFarm-Apple] Loi gui goi tin tuong tac cay: " + t.getMessage());
                }
            });
            return true;
        }

        // --- BUOC 2: Click menu lua chon 'Cay tao' / 'Thu hoach' ---
        if (appleHarvestStep == 2) {
            long stepElapsed = now - appleHarvestStartTime;
            Gdx.app.postRunnable(() -> {
                int res = tryClickHarvestMenu(2);
                if (res == 2) {
                    appleHarvestStep = 4;
                    appleHarvestStartTime = System.currentTimeMillis();
                    log("[AutoFarm-Apple] [V] Da click nut 'Thu hoach'! Chuyen sang buoc hoan tat...");
                } else if (res == 1) {
                    appleHarvestStep = 3;
                    appleHarvestStartTime = System.currentTimeMillis();
                    lastMenuClickTime = System.currentTimeMillis();
                    log("[AutoFarm-Apple] [V] Da click lua chon: 'Cay tao'! Dang cho menu con 'Thu hoach' xuat hien...");
                } else if (res == 3) {
                    appleHarvestStep = 4;
                    appleHarvestStartTime = System.currentTimeMillis();
                    log("[AutoFarm-Apple] Da dong menu. Chuyen sang buoc hoan tat...");
                } else if (stepElapsed > 1500L && stepElapsed < 2200L) {
                    try {
                        com.a.d.a.gIRLkuN75nEKliLILiiLiiWhAtDOYOUwAnTherehiHihIHAHAhaHOhohohEheHEgIRlKUN75 sender =
                                com.a.d.a.gIRLkuN75nEKliLILiiLiiWhAtDOYOUwAnTherehiHihIHAHAhaHOhohohEheHEgIRlKUN75.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75();
                        if (sender != null && currentHarvestTreeId > 0) {
                            sender.GirLKun75nEkLlilLiLlILwHATDOYouWaNtherEHIhIHIHAhahAHoHoHoHEheHegiRlkun75(currentHarvestTreeId, currentHarvestTreeTypeId);
                            log("[AutoFarm-Apple] Gui lai packet tuong tac Cay Tao...");
                        }
                    } catch (Throwable ignored) {
                    }
                }
            });

            if (stepElapsed > 4000L) {
                log("[AutoFarm-Apple] Timeout cho doi menu cay tao buoc 2 -> Bo qua.");
                appleHarvestStep = 0;
                isAppleHarvesting = false;
                hasHarvestedApple = true;
                appleEnterNongTraiTime = 0L;
                return false;
            }
            return true;
        }

        // --- BUOC 3: Click lua chon 'Thu hoach' trong menu con ---
        if (appleHarvestStep == 3) {
            long stepElapsed = now - appleHarvestStartTime;
            if (now - lastMenuClickTime < 300L) {
                return true;
            }

            Gdx.app.postRunnable(() -> {
                int res = tryClickHarvestMenu(3);
                if (res == 2 || res == 3) {
                    appleHarvestStep = 4;
                    appleHarvestStartTime = System.currentTimeMillis();
                    log("[AutoFarm-Apple] [V] Da thuc hien xong menu thu hoach. Chuyen sang buoc hoan tat...");
                }
            });

            if (stepElapsed > 3500L) {
                log("[AutoFarm-Apple] Timeout cho doi menu thu hoach buoc 3 -> Bo qua.");
                appleHarvestStep = 0;
                isAppleHarvesting = false;
                hasHarvestedApple = true;
                appleEnterNongTraiTime = 0L;
                return false;
            }
            return true;
        }

        // --- BUOC 4: Cho dong dialog va hoan tat ---
        if (appleHarvestStep == 4) {
            if (now - appleHarvestStartTime < 1500L) {
                return true;
            }

            Gdx.app.postRunnable(TinhLinhBot::closeAllHarvestDialogs);

            appleHarvestStep = 0;
            isAppleHarvesting = false;
            hasHarvestedApple = true;
            appleEnterNongTraiTime = 0L;
            lastMenuClickTime = 0L;
            log("[AutoFarm-Apple] >>> HOAN TAT THU HOACH CAY TAO THANH CONG! <<<");
            return false;
        }

        return false;
    }

    public static int tryClickHarvestMenu(int step) {
        try {
            com.a.c.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75 game =
                    com.a.c.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75;
            if (game == null) return 0;
            com.a.c.f.a.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 world =
                    game.gIrlKuN75NEKIlILIIiLlLWHatDOYouWanthereHihIhiHaHahAhOhoHOhEHEHEGIRLkun75();
            if (world == null) return 0;
            com.a.c.f.a.b.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75 uiOverlay =
                    world.GIRLkuN75nEkLlLiiLIlLlwhATdoYouwaNtherEHiHiHihaHaHAHOHOHoHehEHeGIrlKun75;
            if (uiOverlay == null) return 0;

            // 1. Quet tren dialogManager
            if (uiOverlay.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75 != null) {
                SnapshotArray<Actor> children = uiOverlay.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75.getChildren();
                if (children != null) {
                    for (int i = 0; i < children.size; i++) {
                        Actor child = children.get(i);
                        if (child != null && child.isVisible()) {
                            int res = findAndClickHarvestOption(child, step);
                            if (res != 0) return res;
                        }
                    }
                }
            }

            // 2. Quet cac dialog component khac tren uiOverlay qua reflection
            for (Method m : uiOverlay.getClass().getMethods()) {
                if (m.getParameterCount() == 1 && m.getParameterTypes()[0] == Class.class) {
                    try {
                        String[] dialogClasses = {
                                "com.a.c.f.a.b.k.giRLkuN75nekLiIiIIlILLwHATdoYOUwAnTHERehIhIhIHAHahAHOhOhOHehEHEgIRlKun75",
                                "com.a.c.f.a.b.k.GIrlKun75neKlIilILliIIwHaTdoyOuwaNtherEHiHIhiHAHAHAHOhohOHehEHEGIRLkun75"
                        };
                        for (String dClassName : dialogClasses) {
                            try {
                                Class<?> dClass = Class.forName(dClassName);
                                Actor dActor = (Actor) m.invoke(uiOverlay, dClass);
                                if (dActor != null && dActor.isVisible()) {
                                    int res = findAndClickHarvestOption(dActor, step);
                                    if (res != 0) return res;
                                }
                            } catch (Throwable ignored) {
                            }
                        }
                    } catch (Throwable ignored) {
                    }
                    break;
                }
            }
        } catch (Throwable t) {
            log("[AutoFarm-Apple] Loi trong tryClickHarvestMenu: " + t.getMessage());
        }
        return 0;
    }

    public static int findAndClickHarvestOption(Actor root, int step) {
        if (root == null) return 0;
        List<Actor> buttons = new ArrayList<>();
        findAllButtons(root, buttons, root);
        if (buttons.isEmpty()) return 0;

        int harvestIdx = -1;
        int treeMenuIdx = -1;
        int closeIdx = -1;

        for (int i = 0; i < buttons.size(); i++) {
            Actor btn = buttons.get(i);
            String norm = normalizeText(getActorText(btn));
            if (norm.contains("thu hoach") || norm.contains("hai") || (norm.contains("thu") && !norm.contains("thuong") && !norm.contains("thue"))) {
                harvestIdx = i;
            }
            if (norm.contains("cay tao") || norm.contains("tao") || norm.contains("nong trai")) {
                treeMenuIdx = i;
            }
            if (norm.contains("dong") || norm.contains("thoat") || norm.contains("huy") || norm.contains("ve lang")) {
                closeIdx = i;
            }
        }

        int chosenIdx = -1;
        int resultType = 0;

        if (harvestIdx != -1) {
            chosenIdx = harvestIdx;
            resultType = 2; // Thu hoach
            log("[AutoFarm-Apple] Phat hien nut [Thu Hoach] tai vi tri " + harvestIdx + " ('" + getActorText(buttons.get(harvestIdx)) + "')");
        } else if (step == 2 && treeMenuIdx != -1) {
            chosenIdx = treeMenuIdx;
            resultType = 1; // Cay tao
            log("[AutoFarm-Apple] Phat hien nut [Cay Tao] tai vi tri " + treeMenuIdx + " ('" + getActorText(buttons.get(treeMenuIdx)) + "')");
        } else if (step == 3) {
            if (buttons.size() == 1) {
                chosenIdx = 0;
                resultType = 2; // Thu hoach
                log("[AutoFarm-Apple] Menu con chi co 1 nut duy nhat -> Chon nut index 0 de thu hoach ('" + getActorText(buttons.get(0)) + "')");
            } else {
                long elapsed = System.currentTimeMillis() - appleHarvestStartTime;
                if (elapsed > 1200L) {
                    log("[AutoFarm-Apple] Khong thay nut [Thu hoach] (cay chua chin hoac da thu hoach). Chuan bi dong dialog...");
                    chosenIdx = (closeIdx != -1) ? closeIdx : (buttons.size() - 1);
                    resultType = 3; // Dong menu
                }
            }
        } else if (step == 2) {
            if (buttons.size() == 1) {
                chosenIdx = 0;
                resultType = 1; // Cay tao
                log("[AutoFarm-Apple] Menu cay chi co 1 nut duy nhat -> Click nut 0 de mo menu thu hoach ('" + getActorText(buttons.get(0)) + "')");
            } else {
                long elapsed = System.currentTimeMillis() - appleHarvestStartTime;
                if (elapsed > 1500L) {
                    chosenIdx = (closeIdx != -1) ? closeIdx : 0;
                    resultType = (closeIdx != -1) ? 3 : 1;
                }
            }
        }

        if (chosenIdx < 0 || chosenIdx >= buttons.size()) {
            return 0;
        }

        Actor targetBtn = buttons.get(chosenIdx);
        log("[AutoFarm-Apple] Dang thuc hien click lua chon index " + chosenIdx + ": [" + getActorText(targetBtn) + "] (Ket qua=" + resultType + ")...");
        clickActor(targetBtn);

        // Gui packet truc tiep fallback
        try {
            com.a.d.a.gIRLkuN75nEKliLILiiLiiWhAtDOYOUwAnTherehiHihIHAHAhaHOhohohEheHEgIRlKUN75 sender =
                    com.a.d.a.gIRLkuN75nEKliLILiiLiiWhAtDOYOUwAnTherehiHihIHAHAhaHOhohohEheHEgIRlKUN75.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75();
            if (sender != null && currentHarvestTreeId > 0) {
                sender.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75(0, currentHarvestTreeId, chosenIdx);
                log("[AutoFarm-Apple] Da gui packet menu truc tiep (p1=0, treeId=" + currentHarvestTreeId + ", idx=" + chosenIdx + ")");
            }
        } catch (Throwable t) {
            log("[AutoFarm-Apple] Loi gui packet menu truc tiep: " + t.getMessage());
        }

        if (resultType == 2 || resultType == 3) {
            try {
                Method closeMethod = root.getClass().getMethod("GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75");
                closeMethod.invoke(root);
            } catch (Throwable ignored) {
            }
        }

        return resultType;
    }

    private static void closeAllHarvestDialogs() {
        try {
            com.a.c.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75 game =
                    com.a.c.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75;
            if (game == null) return;
            com.a.c.f.a.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 world =
                    game.gIrlKuN75NEKIlILIIiLlLWHatDOYouWanthereHihIhiHaHahAhOhoHOhEHEHEGIRLkun75();
            if (world == null) return;
            com.a.c.f.a.b.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75 uiOverlay =
                    world.GIRLkuN75nEkLlLiiLIlLlwhATdoYouwaNtherEHiHiHihaHaHAHOHOHoHehEHeGIrlKun75;
            if (uiOverlay == null) return;

            if (uiOverlay.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75 != null) {
                SnapshotArray<Actor> children = uiOverlay.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75.getChildren();
                if (children != null) {
                    for (int i = 0; i < children.size; i++) {
                        Actor child = children.get(i);
                        if (child != null && child.isVisible()) {
                            try {
                                Method closeMethod = child.getClass().getMethod("GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75");
                                closeMethod.invoke(child);
                            } catch (Throwable ignored) {
                            }
                        }
                    }
                }
            }
        } catch (Throwable ignored) {
        }
    }

    private static void stopPlayerVelocity(com.a.c.f.a.b.j.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75 player) {
        if (player == null) return;
        try {
            com.a.a.b.GIRLkuN75nEkLlLiiLIlLlwhATdoYouwaNtherEHiHiHihaHaHAHOHOHoHehEHeGIrlKun75 phys =
                    player.GirLKun75nEkLlilLiLlILwHATDOYouWaNtherEHIhIHIHAhahAHoHoHoHEheHegiRlkun75;
            if (phys != null) {
                Method m = phys.getClass().getMethod("gIrLkUn75nEkIliiIiIILiWHATdoYouWantHEREHIhihIhAhahahohoHoHEheHEGiRlkUn75");
                com.badlogic.gdx.physics.box2d.Body body = (com.badlogic.gdx.physics.box2d.Body) m.invoke(phys);
                if (body != null) {
                    body.setLinearVelocity(0f, 0f);
                }
            }
        } catch (Throwable ignored) {
        }
    }

    /**
     * Tra ve danh sach tat ca cac cong Waypoint tren map hien tai.
     */
    public static Array<com.a.c.f.a.b.e.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75> getCurrentMapWaypoints() {
        try {
            com.a.c.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75 game =
                    com.a.c.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75;
            if (game == null) return null;
            com.a.c.f.a.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 world =
                    game.gIrlKuN75NEKIlILIIiLlLWHatDOYouWanthereHihIhiHaHahAhOhoHOhEHEHEGIRLkun75();
            if (world == null) return null;
            com.a.c.f.a.b.e.GIRLkuN75nEkLlLiiLIlLlwhATdoYouwaNtherEHiHiHihaHaHAHOHOHoHehEHeGIrlKun75 map =
                    world.GIrLkUn75NEkIlillliLIIwhatDOYOUwaNThEREHIHihIHAHAHAHoHoHOHehEhEGIrLKuN75;
            if (map != null) {
                return map.GIRLkuN75nEkLlLiiLIlLlwhATdoYouwaNtherEHiHiHihaHaHAHOHOHoHehEHeGIrlKun75;
            }
        } catch (Throwable ignored) {
        }
        return null;
    }

    /**
     * Doc ten cua mot cong Waypoint thong qua reflection cac truong String.
     */
    public static String getWaypointName(com.a.c.f.a.b.e.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75 wp) {
        if (wp == null) return "";
        try {
            for (Field f : wp.getClass().getDeclaredFields()) {
                if (Modifier.isStatic(f.getModifiers()) || f.getType() != String.class) continue;
                f.setAccessible(true);
                Object obj = f.get(wp);
                if (obj != null) {
                    String s = obj.toString().trim();
                    if (!s.isEmpty()) return s;
                }
            }
            if (wp.getClass().getSuperclass() != null) {
                for (Field f : wp.getClass().getSuperclass().getDeclaredFields()) {
                    if (Modifier.isStatic(f.getModifiers()) || f.getType() != String.class) continue;
                    f.setAccessible(true);
                    Object obj = f.get(wp);
                    if (obj != null) {
                        String s = obj.toString().trim();
                        if (!s.isEmpty()) return s;
                    }
                }
            }
        } catch (Throwable ignored) {
        }
        return "";
    }

    /**
     * Tim cong Waypoint tren map hien tai khop voi tu khoa (vi du: "nong trai", "lang",...).
     */
    public static com.a.c.f.a.b.e.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75 findWaypointByName(String targetKeyword) {
        if (targetKeyword == null || targetKeyword.trim().isEmpty()) {
            return null;
        }
        String targetNorm = normalizeText(targetKeyword);
        Array<com.a.c.f.a.b.e.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75> waypoints = getCurrentMapWaypoints();
        if (waypoints == null || waypoints.size == 0) {
            return null;
        }

        StringBuilder allWp = new StringBuilder();
        for (int i = 0; i < waypoints.size; i++) {
            com.a.c.f.a.b.e.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75 wp = waypoints.get(i);
            if (wp != null) {
                int targetId = wp.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75;
                if ((targetNorm.contains("nong") || targetNorm.contains("trai")) && targetId == 5) {
                    return wp;
                }
                if ((targetNorm.contains("lang") || targetNorm.contains("eldarah")) && (targetId == 2 || targetId == 0)) {
                    return wp;
                }
                if (targetNorm.contains("thung lung") && targetId == 3) {
                    return wp;
                }
                if (targetNorm.contains("thao nguyen") && targetId == 4) {
                    return wp;
                }
                if ((targetNorm.contains("doi ngan") || targetNorm.contains("sayari")) && (targetId == 6 || targetId == 1)) {
                    return wp;
                }
                if (targetNorm.contains("rung co moc") && (targetId == 7 || targetId == 2)) {
                    return wp;
                }
                String wpName = getWaypointName(wp);
                String wpNorm = normalizeText(wpName);
                if (allWp.length() > 0) allWp.append(", ");
                allWp.append("[").append(wpName).append(" (ID:").append(targetId).append(")]");
                if (wpNorm.contains(targetNorm) || targetNorm.contains(wpNorm) || (targetNorm.contains("nong") && wpNorm.contains("nong"))) {
                    return wp;
                }
            }
        }
        log("[Waypoint] Khong tim thay cong khop voi '" + targetKeyword + "'. Cac cong tren map (" + waypoints.size + "): " + allWp);
        return null;
    }

    /**
     * Di chuyen nhan vat den cong Waypoint va kich hoat chuyen map thong qua Waypoint Wrapper callback.
     */
    public static boolean moveToWaypoint(com.a.c.f.a.b.e.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75 waypoint) {
        if (waypoint == null) {
            return false;
        }
        try {
            com.a.c.f.a.b.j.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75 player =
                    com.a.c.f.a.b.j.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75.GiRLKUN75NEklliilLliIiwhATDOyOUWanTheREhIhIHiHAHahahOHOHOhEhEHeGiRLkuN75();
            if (player == null || player.girLKUn75nEkLiLLlIllLIWhAtdOyouWaNTHErehIHiHiHahAhAHOHoHohEhEHegirLkUN75 == null) {
                return false;
            }

            Vector2 wpPos = waypoint.gIRLkuN75nEKliLILiiLiiWhAtDOYOUwAnTherehiHihIHAHAhaHOhohohEheHEgIRlKUN75();
            if (wpPos == null) {
                return false;
            }

            final Vector2 targetPos = wpPos;
            final com.a.c.f.a.b.e.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75 targetWp = waypoint;
            String wpName = getWaypointName(targetWp);

            Gdx.app.postRunnable(() -> {
                try {
                    Class<?> clazz = Class.forName("com.a.c.f.a.b.e.GIrLkUn75NEkIlillliLIIwhatDOYOUwaNThEREHIHihIHAHAHAHoHoHOHehEhEGIrLKuN75");
                    Constructor<?> constructor = clazz.getDeclaredConstructors()[0];
                    constructor.setAccessible(true);
                    Object wpTrigger = constructor.newInstance(targetWp);
                    Object controller = player.girLKUn75nEkLiLLlIllLIWhAtdOyouWaNTHErehIHiHiHahAhAHOHoHohEhEHegirLkUN75;
                    Class<?> callbackClass = Class.forName("com.a.c.f.a.b.j.a.GirlKun75NekIlliLiLIiiWhAtdOyOuwAnTHereHIhihiHahAHAHOHOHOhEHeHeGiRLKuN75$GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75");
                    Method moveMethod = controller.getClass().getMethod(
                            "GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75",
                            float.class, float.class, callbackClass
                    );
                    moveMethod.invoke(controller, targetPos.x, targetPos.y, wpTrigger);
                    log("[Waypoint] Dang di chuyen den cong [" + wpName + "] tai (X=" + targetPos.x + ", Y=" + targetPos.y + ")...");
                } catch (Throwable t) {
                    log("[Waypoint] Loi khi khoi tao di chuyen cong waypoint: " + t.getMessage());
                }
            });
            return true;
        } catch (Throwable t) {
            log("[Waypoint] Loi trong moveToWaypoint: " + t.getMessage());
            return false;
        }
    }

    private static String getEntityHName(com.a.c.f.a.b.h.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 e) {
        if (e == null) return "Cay Tao";
        try {
            String s = e.GiRLKUN75NEklliilLliIiwhATDOyOUWanTheREhIhIHiHAHahahOHOHOhEhEHeGiRLkuN75();
            if (s != null && !s.trim().isEmpty()) return s.trim();
        } catch (Throwable ignored) {
        }
        return "Cay Tao";
    }

    private static int getEntityHTypeId(com.a.c.f.a.b.h.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 e) {
        try {
            if (e != null && e.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 != null
                    && e.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 != null) {
                return e.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75;
            }
        } catch (Throwable ignored) {
        }
        return 0;
    }

    private static String getTreeName(com.a.c.f.a.b.g.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 t) {
        if (t == null) return "Cay Tao";
        try {
            if (t.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 != null
                    && t.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75 != null) {
                String s = t.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75;
                if (s != null && !s.trim().isEmpty()) return s.trim();
            }
        } catch (Throwable ignored) {
        }
        return "Cay Tao";
    }

    private static int getTreeTypeId(com.a.c.f.a.b.g.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 t) {
        try {
            if (t != null && t.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 != null
                    && t.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75 != null) {
                return t.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75;
            }
        } catch (Throwable ignored) {
        }
        return 0;
    }

    private static String getNPCName(com.a.c.f.a.b.d.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 n) {
        if (n == null) return "NPC";
        try {
            Object obj = n.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75;
            if (obj != null) {
                for (Field f : obj.getClass().getDeclaredFields()) {
                    f.setAccessible(true);
                    Object val = f.get(obj);
                    if (val != null) {
                        for (Field inner : val.getClass().getDeclaredFields()) {
                            if (inner.getType() == String.class) {
                                inner.setAccessible(true);
                                String s = (String) inner.get(val);
                                if (s != null && !s.trim().isEmpty()) {
                                    return s.trim();
                                }
                            }
                        }
                    }
                }
            }
        } catch (Throwable ignored) {
        }
        return "NPC";
    }

    private static int getNPCTypeId(com.a.c.f.a.b.d.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 n) {
        try {
            if (n != null && n.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 != null
                    && n.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 != null) {
                return n.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75;
            }
        } catch (Throwable ignored) {
        }
        return 0;
    }

    // =========================================================================
    // AUTO LOGIN ENGINE
    // =========================================================================

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

        // Luu vao in-memory buffer phuc vu HTTP API /log (toi da 500 dong)
        synchronized (RECENT_LOGS) {
            if (RECENT_LOGS.size() >= 500) {
                RECENT_LOGS.remove(0);
            }
            RECENT_LOGS.add(formatted);
        }

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
        if (now - lastGuardCheckTime < 30_000L) {
            return;
        }
        lastGuardCheckTime = now;

        // 1. Memory Guard (Heap RAM)
        long freeMem = Runtime.getRuntime().freeMemory();
        long totalMem = Runtime.getRuntime().totalMemory();
        long maxMem = Runtime.getRuntime().maxMemory();
        long usedMem = totalMem - freeMem;
        if (maxMem > 0 && usedMem > (maxMem * 92 / 100)) {
            long usedMb = usedMem / (1024L * 1024L);
            long maxMb = maxMem / (1024L * 1024L);
            log("[MemoryGuard] Heap usage cao: " + usedMb + "MB / " + maxMb + "MB (>92%). Goi System.gc() thu hoi bo nho...");
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

        File testApple = new File("test_trigger_apple.txt");
        if (testApple.exists()) {
            testApple.delete();
            log("[Diagnostic] Nhan lenh test_trigger_apple.txt! Kich hoat triggerHarvestApple ngay lap tuc...");
            boolean ok = triggerHarvestApple();
            log("[Diagnostic] Ket qua triggerHarvestApple: " + ok);
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

    // =========================================================================
    // FEATURE 6: CHECK VERSION UPDATE REQUIREMENT
    // FEATURE 7: CHECK SERVER UNDER MAINTENANCE
    // =========================================================================

    /**
     * Feature 6: Kiem tra yeu cau cap nhat phien ban game.
     * Quet toan bo Stage / Dialog / Toast tren man hinh (Login Screen va Game Screen).
     * @return true neu phat hien yeu cau cap nhat phien ban, false neu khong co.
     */
    public static boolean isVersionUpdateRequired() {
        try {
            List<String> texts = new ArrayList<>();
            scanAllScreenTexts(texts);
            for (String t : texts) {
                if (matchesVersionUpdatePattern(t)) {
                    lastDetectedVersionUpdateMsg = t;
                    lastDetectedVersionUpdateTime = System.currentTimeMillis();
                    return true;
                }
            }
            List<Actor> dialogs = getActiveDialogRoots();
            for (Actor d : dialogs) {
                String fullText = getActorText(d);
                if (matchesVersionUpdatePattern(fullText)) {
                    lastDetectedVersionUpdateMsg = fullText;
                    lastDetectedVersionUpdateTime = System.currentTimeMillis();
                    return true;
                }
            }
        } catch (Throwable ignored) {
        }
        return false;
    }

    /**
     * Alias method cho isVersionUpdateRequired().
     */
    public static boolean checkVersionUpdateRequired() {
        return isVersionUpdateRequired();
    }

    /**
     * Tra ve noi dung thong bao yeu cau cap nhat phien ban gan nhat (neu co).
     */
    public static String getVersionUpdateMessage() {
        return lastDetectedVersionUpdateMsg;
    }

    /**
     * Feature 7: Kiem tra may chu game co dang trong trang thai bao tri hay khong.
     * Quet toan bo Stage / Dialog / Toast tren man hinh (Login Screen va Game Screen).
     * @return true neu may chu dang bao tri, false neu hoat dong binh thuong.
     */
    public static boolean isServerUnderMaintenance() {
        try {
            List<String> texts = new ArrayList<>();
            scanAllScreenTexts(texts);
            for (String t : texts) {
                if (matchesServerMaintenancePattern(t)) {
                    lastDetectedMaintenanceMsg = t;
                    lastDetectedMaintenanceTime = System.currentTimeMillis();
                    return true;
                }
            }
            List<Actor> dialogs = getActiveDialogRoots();
            for (Actor d : dialogs) {
                String fullText = getActorText(d);
                if (matchesServerMaintenancePattern(fullText)) {
                    lastDetectedMaintenanceMsg = fullText;
                    lastDetectedMaintenanceTime = System.currentTimeMillis();
                    return true;
                }
            }
        } catch (Throwable ignored) {
        }
        return false;
    }

    /**
     * Alias method cho isServerUnderMaintenance().
     */
    public static boolean checkServerUnderMaintenance() {
        return isServerUnderMaintenance();
    }

    /**
     * Tra ve noi dung thong bao bao tri may chu gan nhat (neu co).
     */
    public static String getServerMaintenanceMessage() {
        return lastDetectedMaintenanceMsg;
    }

    /**
     * Reset cac thong bao cap nhat phien ban va bao tri da luu.
     */
    public static void resetVersionAndUpdateStatus() {
        lastDetectedVersionUpdateMsg = "";
        lastDetectedVersionUpdateTime = 0L;
        lastDetectedMaintenanceMsg = "";
        lastDetectedMaintenanceTime = 0L;
    }

    private static boolean matchesVersionUpdatePattern(String rawText) {
        if (rawText == null || rawText.trim().isEmpty()) return false;
        String norm = normalizeText(rawText);
        if (norm.isEmpty()) return false;

        // Pattern 1: Chứa 'cap nhat' + ('phien ban' / 'ung dung' / 'game' / 'moi' / 'tai ve' / 'client')
        if (norm.contains("cap nhat") && (norm.contains("phien ban") || norm.contains("ung dung") || norm.contains("game") || norm.contains("moi") || norm.contains("client") || norm.contains("tai ve"))) {
            return true;
        }
        // Pattern 2: Chứa 'phien ban' + ('da cu' / 'khong phu hop' / 'khong hop le' / 'het han' / 'loi thoi' / 'moi nhat' / 'moi hon'))
        if (norm.contains("phien ban") && (norm.contains("da cu") || norm.contains("khong phu hop") || norm.contains("khong hop le") || norm.contains("het han") || norm.contains("loi thoi") || norm.contains("moi nhat") || norm.contains("moi hon"))) {
            return true;
        }
        // Pattern 3: Các cụm từ trực tiếp
        if (norm.contains("yeu cau cap nhat")
                || norm.contains("vui long cap nhat")
                || norm.contains("tai phien ban moi")
                || norm.contains("cai dat phien ban moi")
                || norm.contains("update version")
                || norm.contains("new version available")
                || norm.contains("please update")
                || norm.contains("client version out of date")) {
            return true;
        }
        return false;
    }

    private static boolean matchesServerMaintenancePattern(String rawText) {
        if (rawText == null || rawText.trim().isEmpty()) return false;
        String norm = normalizeText(rawText);
        if (norm.isEmpty()) return false;

        // Pattern 1: Cac cum tu bao tri may chu truc tiep
        if (norm.contains("may chu dang bao tri")
                || norm.contains("server dang bao tri")
                || norm.contains("he thong dang bao tri")
                || norm.contains("bao tri he thong")
                || norm.contains("bao tri dinh ky")
                || norm.contains("bao tri may chu")
                || norm.contains("may chu bao tri")
                || norm.contains("server bao tri")
                || norm.contains("server maintenance")
                || norm.contains("under maintenance")
                || norm.contains("system maintenance")) {
            return true;
        }
        // Pattern 2: Chua tu khoa 'bao tri' hoac 'maintenance'
        if (norm.contains("bao tri") || norm.contains("maintenance")) {
            return true;
        }
        return false;
    }

    private static void scanAllScreenTexts(List<String> outList) {
        if (outList == null) return;
        try {
            com.a.c.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75 game =
                    com.a.c.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75;
            if (game == null) return;
            Screen screen = game.getScreen();
            if (screen == null) return;

            // 1. Quet Stage goc cua Screen
            if (screen instanceof com.a.a.a.c.GirLKun75nEkLlilLiLlILwHATDOYouWaNtherEHIhIHIHAhahAHoHoHoHEheHegiRlkun75) {
                Stage stage = ((com.a.a.a.c.GirLKun75nEkLlilLiLlILwHATDOYouWaNtherEHIhIHIHAhahAHoHoHoHEheHegiRlkun75) screen).GIrLkUn75NEkIlillliLIIwhatDOYOUwaNThEREHIHihIHAHAHAHoHoHOHehEhEGIrLKuN75();
                if (stage != null && stage.getRoot() != null) {
                    collectAllActorTexts(stage.getRoot(), outList);
                }
            }

            // 2. Neu o man hinh LoginScreen, quet them overlay dialog
            if (screen instanceof com.a.c.f.c.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75) {
                com.a.c.f.c.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 loginScreen =
                        (com.a.c.f.c.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75) screen;
                if (loginScreen.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75 != null) {
                    collectAllActorTexts(loginScreen.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75, outList);
                }
            }

            // 3. Neu o in-game World, quet DialogManager va UIOverlay
            com.a.c.f.a.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 world =
                    game.gIrlKuN75NEKIlILIIiLlLWHatDOYouWanthereHihIhiHaHahAhOhoHOhEHEHEGIRLkun75();
            if (world != null) {
                com.a.c.f.a.b.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75 uiOverlay =
                        world.GIRLkuN75nEkLlLiiLIlLlwhATdoYouwaNtherEHiHiHihaHaHAHOHOHoHehEHeGIrlKun75;
                if (uiOverlay != null && uiOverlay.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75 != null) {
                    SnapshotArray<Actor> dialogs = uiOverlay.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75.getChildren();
                    if (dialogs != null) {
                        for (int i = 0; i < dialogs.size; i++) {
                            collectAllActorTexts(dialogs.get(i), outList);
                        }
                    }
                }
            }
        } catch (Throwable ignored) {
        }
    }

    private static boolean isActorConsideredVisible(Actor actor) {
        if (actor == null) return false;
        if (!actor.isVisible()) return false;
        try {
            if (actor.getColor() != null && actor.getColor().a < 0.05f) {
                return false;
            }
        } catch (Throwable ignored) {
        }
        return true;
    }

    private static void collectAllActorTexts(Actor actor, List<String> outList) {
        if (actor == null || !isActorConsideredVisible(actor)) return;
        try {
            String text = getDirectActorText(actor);
            if (text != null && !text.trim().isEmpty()) {
                outList.add(text.trim());
            }
            if (actor instanceof Group) {
                SnapshotArray<Actor> kids = ((Group) actor).getChildren();
                if (kids != null) {
                    for (int i = 0; i < kids.size; i++) {
                        collectAllActorTexts(kids.get(i), outList);
                    }
                }
            }
        } catch (Throwable ignored) {
        }
    }

    private static List<Actor> getActiveDialogRoots() {
        List<Actor> roots = new ArrayList<>();
        try {
            com.a.c.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75 game =
                    com.a.c.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75;
            if (game == null) return roots;
            Screen screen = game.getScreen();
            if (screen instanceof com.a.a.a.c.GirLKun75nEkLlilLiLlILwHATDOYouWaNtherEHIhIHIHAhahAHoHoHoHEheHegiRlkun75) {
                Stage stage = ((com.a.a.a.c.GirLKun75nEkLlilLiLlILwHATDOYouWaNtherEHIhIHIHAhahAHoHoHoHEheHegiRlkun75) screen).GIrLkUn75NEkIlillliLIIwhatDOYOUwaNThEREHIHihIHAHAHAHoHoHOHehEhEGIrLKuN75();
                if (stage != null && stage.getRoot() != null) {
                    SnapshotArray<Actor> stageKids = stage.getRoot().getChildren();
                    if (stageKids != null) {
                        for (int i = 0; i < stageKids.size; i++) {
                            Actor child = stageKids.get(i);
                            if (child != null && isActorConsideredVisible(child)) {
                                roots.add(child);
                            }
                        }
                    }
                }
            }
            com.a.c.f.a.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 world =
                    game.gIrlKuN75NEKIlILIIiLlLWHatDOYouWanthereHihIhiHaHahAhOhoHOhEHEHEGIRLkun75();
            if (world != null) {
                com.a.c.f.a.b.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75 uiOverlay =
                    world.GIRLkuN75nEkLlLiiLIlLlwhATdoYouwaNtherEHiHiHihaHaHAHOHOHoHehEHeGIrlKun75;
                if (uiOverlay != null && uiOverlay.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75 != null) {
                    SnapshotArray<Actor> dialogs = uiOverlay.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75.getChildren();
                    if (dialogs != null) {
                        for (int i = 0; i < dialogs.size; i++) {
                            Actor child = dialogs.get(i);
                            if (child != null && isActorConsideredVisible(child)) {
                                roots.add(child);
                            }
                        }
                    }
                }
            }
        } catch (Throwable ignored) {
        }
        return roots;
    }

    // =========================================================================
    // FEATURE 8: TU DONG QUAY LAI TOA DO KIET SUC (RETURN TO EXHAUSTION COORD)
    // =========================================================================

    public static boolean isAutoReturnToExhaustionEnabled() {
        if (new File("tat_auto_quay_lai.txt").exists() || new File("no_auto_return.txt").exists()) {
            return false;
        }
        return isAutoReturnToExhaustionEnabled;
    }

    public static void setAutoReturnToExhaustionEnabled(boolean enabled) {
        isAutoReturnToExhaustionEnabled = enabled;
        log("[AutoFarm-Return] Auto Return to Exhaustion da chuyen thanh: " + enabled);
    }

    public static boolean isReturningToExhaustion() {
        return isReturningToExhaustion;
    }

    public static synchronized void clearSavedExhaustionCoordinate() {
        lastSavedExhaustionCoord = null;
        isReturningToExhaustion = false;
        returnArrivalSamples = 0;
        returnStartTime = 0L;
        try {
            File propFile = new File(EXHAUSTION_STATE_FILE);
            if (propFile.exists()) {
                propFile.delete();
            }
            File txtFile = new File(EXHAUSTION_COORD_FILE);
            if (txtFile.exists()) {
                txtFile.delete();
            }
            log("[AutoFarm-Return] Da xoa trang thai va toa do kiet suc cu.");
        } catch (Throwable ignored) {
        }
    }

    /**
     * Dieu khien nhan vat di chuyen den mot toa do cu the (x, y) tren map hien tai.
     * Su dung Movement Controller goc cua nhan vat trong game LibGDX.
     */
    public static boolean moveTo(float targetX, float targetY) {
        try {
            com.a.c.f.a.b.j.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75 player =
                    com.a.c.f.a.b.j.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75.GiRLKUN75NEklliilLliIiwhATDOyOUWanTheREhIhIHiHAHahahOHOHOhEhEHeGiRLkuN75();
            if (player == null || player.girLKUn75nEkLiLLlIllLIWhAtdOyouWaNTHErehIHiHiHahAhAHOHoHohEhEHegirLkUN75 == null) {
                return false;
            }
            Object controller = player.girLKUn75nEkLiLLlIllLIWhAtdOyouWaNTHErehIHiHiHahAhAHOHoHohEhEHegirLkUN75;
            Gdx.app.postRunnable(() -> {
                try {
                    Class<?> callbackClass = Class.forName("com.a.c.f.a.b.j.a.GirlKun75NekIlliLiLIiiWhAtdOyOuwAnTHereHIhihiHahAHAHOHOHOhEHeHeGiRLKuN75$GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75");
                    Method moveMethod = controller.getClass().getMethod(
                            "GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75",
                            float.class, float.class, callbackClass
                    );
                    moveMethod.invoke(controller, targetX, targetY, null);
                } catch (Throwable t) {
                    log("[Movement] Loi khi di chuyen toi (" + targetX + ", " + targetY + "): " + t.getMessage());
                }
            });
            return true;
        } catch (Throwable t) {
            log("[Movement] Ngoai le trong moveTo: " + t.getMessage());
            return false;
        }
    }

    /**
     * Kiem tra hai map co phai la cung mot map khong (so sanh mapId hoac ten map chuan hoa).
     */
    private static boolean isSameMap(int id1, String name1, int id2, String name2) {
        if (id1 > 0 && id2 > 0 && id1 == id2) return true;
        if (name1 != null && name2 != null && !name1.trim().isEmpty() && !name2.trim().isEmpty()) {
            String n1 = normalizeText(name1);
            String n2 = normalizeText(name2);
            return n1.equals(n2) || n1.contains(n2) || n2.contains(n1);
        }
        return false;
    }

    /**
     * Xac dinh ID cua map tiep theo can di qua tu currentMapId de den duoc targetMapId (Map Routing Path).
     */
    private static int getNextHopMapId(int currentMapId, int targetMapId) {
        if (currentMapId == targetMapId) return targetMapId;

        int src = (currentMapId == 0) ? 2 : currentMapId;
        int dst = (targetMapId == 0) ? 2 : targetMapId;

        if (src == 5) {
            return 2; // Tu Nong trai luon phai ve Lang truoc
        }
        if (src == 2) {
            if (dst == 5) return 5;
            return 3; // Cac map ngoai Lang deu di qua Map 3 truoc
        }
        if (src == 3) {
            if (dst == 2 || dst == 5) return 2; // Ve Lang
            if (dst >= 4) return 4;             // Di tiep ra Thao nguyen mach gio
        }
        if (src == 4) {
            if (dst <= 3) return 3;             // Quay lai Thung lung co lau
            if (dst >= 6) return 6;             // Di tiep toi Doi ngan Sayari
        }
        if (src == 6) {
            if (dst <= 4) return 4;             // Quay lai Thao nguyen mach gio
            if (dst >= 7) return 7;             // Di tiep toi Rung co moc
        }
        if (src == 7) {
            if (dst <= 6) return 6;             // Quay ve Doi ngan Sayari
            if (dst >= 8) return 8;             // Di tiep toi Map 8
        }
        if (src > dst) {
            return src - 1; // Mac dinh di lui 1 map
        }
        if (src < dst) {
            return src + 1; // Mac dinh tien 1 map
        }

        return targetMapId;
    }

    /**
     * Tim cong Waypoint tren map hien tai de di tiep den targetMap.
     */
    public static com.a.c.f.a.b.e.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75 findWaypointToTargetMap(
            int currentMapId, String currentMapName, int targetMapId, String targetMapName) {
        Array<com.a.c.f.a.b.e.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75> waypoints = getCurrentMapWaypoints();
        if (waypoints == null || waypoints.size == 0) {
            return null;
        }

        String targetNorm = normalizeText(targetMapName);

        // 1. Uu tien 1: Tim cong truc tiep dan den targetMapId
        for (int i = 0; i < waypoints.size; i++) {
            com.a.c.f.a.b.e.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75 wp = waypoints.get(i);
            if (wp != null && wp.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 == targetMapId) {
                return wp;
            }
        }

        // 2. Uu tien 2: Tim cong co ten khop voi targetMapName
        if (!targetNorm.isEmpty()) {
            for (int i = 0; i < waypoints.size; i++) {
                com.a.c.f.a.b.e.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75 wp = waypoints.get(i);
                if (wp != null) {
                    String wpNorm = normalizeText(getWaypointName(wp));
                    if (!wpNorm.isEmpty() && (wpNorm.contains(targetNorm) || targetNorm.contains(wpNorm))) {
                        return wp;
                    }
                }
            }
        }

        // 3. Uu tien 3: Tim cong qua Routing Next-Hop (BFS)
        int nextHopId = getNextHopMapId(currentMapId, targetMapId);
        if (nextHopId != currentMapId) {
            for (int i = 0; i < waypoints.size; i++) {
                com.a.c.f.a.b.e.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75 wp = waypoints.get(i);
                if (wp != null) {
                    if (wp.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 == nextHopId) {
                        return wp;
                    }
                    if (nextHopId == 2 && (wp.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 == 0)) {
                        return wp;
                    }
                }
            }

            // Tim theo tu khoa pho bien cua nextHopId
            String hopKeyword = "";
            if (nextHopId == 2 || nextHopId == 0) hopKeyword = "lang";
            else if (nextHopId == 3) hopKeyword = "thung lung";
            else if (nextHopId == 4) hopKeyword = "thao nguyen";
            else if (nextHopId == 5) hopKeyword = "nong trai";
            else if (nextHopId == 6) hopKeyword = "doi ngan";
            else if (nextHopId == 7) hopKeyword = "rung co moc";

            if (!hopKeyword.isEmpty()) {
                com.a.c.f.a.b.e.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75 hopWp = findWaypointByName(hopKeyword);
                if (hopWp == null && nextHopId == 6) {
                    hopWp = findWaypointByName("sayari");
                }
                if (hopWp != null) return hopWp;
            }
        }

        // 4. Uu tien 4: Heuristic Tien Toi (Forward Routing) theo toa do X (Rightmost Portal) khi targetMapId > currentMapId
        if (targetMapId > currentMapId) {
            com.a.c.f.a.b.e.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75 bestFwd = null;
            float maxWpX = -1.0f;
            for (int i = 0; i < waypoints.size; i++) {
                com.a.c.f.a.b.e.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75 wp = waypoints.get(i);
                if (wp != null) {
                    Vector2 wpPos = wp.gIRLkuN75nEKliLILiiLiiWhAtDOYOUwAnTherehiHihIHAHAhaHOhohohEheHEgIRlKUN75();
                    float wx = (wpPos != null) ? wpPos.x : 0f;
                    if (wx > maxWpX) {
                        maxWpX = wx;
                        bestFwd = wp;
                    }
                }
            }
            if (bestFwd != null && maxWpX > 20.0f) {
                return bestFwd;
            }
        }

        // 5. Uu tien 5: Heuristic Lui Ve (Backward Routing) theo toa do X (Leftmost Portal) khi targetMapId < currentMapId
        if (targetMapId < currentMapId) {
            com.a.c.f.a.b.e.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75 bestBwd = null;
            float minWpX = Float.MAX_VALUE;
            for (int i = 0; i < waypoints.size; i++) {
                com.a.c.f.a.b.e.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75 wp = waypoints.get(i);
                if (wp != null) {
                    Vector2 wpPos = wp.gIRLkuN75nEKliLILiiLiiWhAtDOYOUwAnTherehiHihIHAHAhaHOhohohEheHEgIRlKUN75();
                    float wx = (wpPos != null) ? wpPos.x : 0f;
                    if (wx < minWpX) {
                        minWpX = wx;
                        bestBwd = wp;
                    }
                }
            }
            if (bestBwd != null && minWpX < 50.0f) {
                return bestBwd;
            }
        }

        // Fallback: neu o Nong trai va chi co 1 cong -> luon la cong ve Lang
        if (currentMapId == 5 && waypoints.size == 1) {
            return waypoints.get(0);
        }

        // In log chi tiet tat ca cac cong dang co tren map de theo doi
        StringBuilder allWpLog = new StringBuilder();
        for (int i = 0; i < waypoints.size; i++) {
            com.a.c.f.a.b.e.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75 wp = waypoints.get(i);
            if (wp != null) {
                if (allWpLog.length() > 0) allWpLog.append(", ");
                allWpLog.append("[").append(getWaypointName(wp))
                        .append(" (TargetID:").append(wp.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75).append(")]");
            }
        }
        log(String.format(Locale.ROOT, "[Waypoint-Routing] Khong tim duoc cong toi Map [%s - ID: %d]. Danh sach %d cong tren Map [%s - ID: %d]: %s",
                targetMapName, targetMapId, waypoints.size, currentMapName, currentMapId, allWpLog));

        return null;
    }

    /**
     * Ham chinh thuc hien quy trinh quay lai toa do kiet suc da luu truoc do:
     * - Neu dang o khac Map: Tim cong Waypoint va buoc vao chuyen map.
     * - Neu da o cung Map: Chay truc tiep toi toa do (saved.x, saved.y).
     * - Khi den dich: Dung nhan vat, xoa trang thai va log hoan tat.
     */
    public static synchronized boolean returnToExhaustionCoordinate() {
        long now = System.currentTimeMillis();
        SavedCoordinate saved = getSavedExhaustionCoordinate();
        if (saved == null) {
            saved = getLastFarmMap();
            if (saved == null) {
                return false;
            }
        }

        if (isPlayerExhausted() || isExhaustionDialogVisible()) {
            return false;
        }

        int currentMapId = getCurrentMapId();
        String currentMapName = getCurrentMapName();
        Vector2 currentPos = getPlayerPosition();
        if (currentMapId < 0 || currentPos == null) {
            return false;
        }

        // Anti-Stuck: Neu da di chuyen qua 180s ma khong den duoc
        if (returnStartTime > 0L && (now - returnStartTime > 180_000L)) {
            log("[AutoFarm-Return] CANH BAO: Qua 180s khong den duoc toa do kiet suc -> Reset chu trinh de chong ket!");
            clearSavedExhaustionCoordinate();
            return false;
        }

        // --- TRUONG HOP 1: Da toi dung Map kiet suc ---
        if (isSameMap(currentMapId, currentMapName, saved.mapId, saved.mapName)) {
            boolean hasSpecificCoord = (saved.x > 0f || saved.y > 0f);
            float dist = 0.0f;
            if (hasSpecificCoord) {
                float dx = saved.x - currentPos.x;
                float dy = saved.y - currentPos.y;
                dist = (float) Math.sqrt(dx * dx + dy * dy);
            }

            if (!hasSpecificCoord || dist <= ARRIVAL_RADIUS) {
                returnArrivalSamples++;
                if (returnArrivalSamples >= 2 || !hasSpecificCoord) {
                    com.a.c.f.a.b.j.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75 player =
                            com.a.c.f.a.b.j.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75.GiRLKUN75NEklliilLliIiwhATDOyOUWanTheREhIhIHiHAHahahOHOHOhEhEHeGiRLkuN75();
                    stopPlayerVelocity(player);
                    isReturningToExhaustion = false;
                    returnArrivalSamples = 0;
                    returnStartTime = 0L;
                    String distMsg = hasSpecificCoord ? String.format(Locale.ROOT, " [Khoang cach den diem cu: %.1fm]", dist) : "";
                    log(String.format(Locale.ROOT, "[AutoFarm-Return] >>> DA TOI MAP/TOA DO KIET SUC THANH CONG! <<< Map [%s - ID: %d] tai (X=%.1f, Y=%.1f)%s",
                            saved.mapName, saved.mapId, currentPos.x, currentPos.y, distMsg));
                    clearSavedExhaustionCoordinate();

                    // Feature 9: Tu dong Kich hoat Menu Auto Tan Cong sau khi quay lai vi tri kiet suc
                    if (isAutoAttackMenuEnabled()) {
                        log("[AutoFarm-Combat] Da quay lai vi tri kiet suc cu -> Kich hoat Menu Auto Tan Cong de tiep tuc danh quai...");
                        openAutoAttackMenu();
                    }
                    return true;
                }
            } else {
                returnArrivalSamples = 0;
                if (now - lastReturnActionTime >= 2000L) {
                    lastReturnActionTime = now;
                    isReturningToExhaustion = true;
                    if (returnStartTime == 0L) returnStartTime = now;
                    log(String.format(Locale.ROOT, "[AutoFarm-Return] Dang chay toi toa do kiet suc (X=%.1f, Y=%.1f) tren Map [%s - ID: %d]. Khoang cach con: %.1fm...",
                            saved.x, saved.y, saved.mapName, saved.mapId, dist));
                    moveTo(saved.x, saved.y);
                }
            }
            return true;
        }

        // --- TRUONG HOP 2: Dang o khac Map -> Tim cong de chuyen sang Map kiet suc ---
        if (now - lastReturnActionTime >= 3500L) {
            lastReturnActionTime = now;
            isReturningToExhaustion = true;
            if (returnStartTime == 0L) returnStartTime = now;

            com.a.c.f.a.b.e.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75 nextPortal =
                    findWaypointToTargetMap(currentMapId, currentMapName, saved.mapId, saved.mapName);

            if (nextPortal != null) {
                String wpName = getWaypointName(nextPortal);
                log(String.format(Locale.ROOT, "[AutoFarm-Return] Tim thay cong [%s] de di toi Map dich [%s - ID: %d]. Dang di chuyen vao cong...",
                        wpName, saved.mapName, saved.mapId));
                moveToWaypoint(nextPortal);
                return true;
            } else {
                log(String.format(Locale.ROOT, "[AutoFarm-Return] Chua tim thay cong di toi Map [%s - ID: %d] tu Map hien tai [%s - ID: %d].",
                        saved.mapName, saved.mapId, currentMapName, currentMapId));
            }
        }

        return false;
    }

    /**
     * Vong lap tu dong dieu huong trong Game Loop:
     * Chi kich hoat quay lai toa do kiet suc khi:
     * 1. Auto return dang bat.
     * 2. Co toa do kiet suc hop le trong bo nho.
     * 3. Khong dang chet va khong co popup kiet suc.
     * 4. Khong dang trong tien trinh hai tao (neu bat auto hai tao va dang o Lang / Nong trai chua hai tao xong -> de hai tao truoc).
     */
    private static void handleReturnToExhaustionNavigation(long now) {
        if (!isAutoReturnToExhaustionEnabled()) {
            return;
        }

        int curMapId = getCurrentMapId();
        String curMap = getCurrentMapName();

        SavedCoordinate saved = getSavedExhaustionCoordinate();
        if (saved == null) {
            saved = getLastFarmMap();
            if (saved == null) {
                return;
            }
            // Neu da o dung map train (khong co toa do cu the can den), khong can goi return nua
            if (isSameMap(curMapId, curMap, saved.mapId, saved.mapName)) {
                return;
            }
        }

        if (isPlayerExhausted() || isExhaustionDialogVisible()) {
            return;
        }

        if (isAppleHarvesting()) {
            return;
        }
        String normMap = normalizeText(curMap);
        boolean isFarm = (curMapId == 5) || normMap.contains("nong");
        boolean isVillage = (curMapId == 0 || curMapId == 2) || normMap.contains("lang");

        // Neu tinh nang hai tao dang bat, va nhan vat dang o Lang chua hai tao -> uu tien de hai tao truoc
        if (isAutoAppleHarvestEnabled() && isVillage && !hasHarvestedApple) {
            return;
        }

        // Neu dang o Nong trai ma chua hai tao xong -> de hai tao truoc
        if (isFarm && !hasHarvestedApple) {
            return;
        }

        // Kich hoat quay lai toa do kiet suc
        returnToExhaustionCoordinate();
    }

    // =========================================================================
    // FEATURE 9: MENU AUTO TAN CONG & CHIEN DAU (AUTO ATTACK MENU CONTROLLER)
    // =========================================================================

    public static boolean isAutoAttackMenuEnabled() {
        return isAutoAttackMenuEnabled;
    }

    public static void setAutoAttackMenuEnabled(boolean enabled) {
        isAutoAttackMenuEnabled = enabled;
        if (!enabled) {
            cancelAutoAttackAttempt("Auto Attack da bi tat.");
        }
        log("[AutoFarm-Combat] Trang thai Auto Attack Menu duoc dat thanh: " + enabled);
    }

    public static boolean isAutoAttackActive() {
        return isAutoAttackActive;
    }

    public static void setAutoAttackActive(boolean active) {
        isAutoAttackActive = active;
    }

    /**
     * Ham tim nut Auto Tan Cong tren cay Actor:
     * Quet cac tu khoa: "auto", "tu dong", "tu danh", "tan cong", "chien dau", "danh quai".
     */
    public static Actor findAutoAttackButton(Actor root) {
        if (root == null) return null;
        List<Actor> buttons = new ArrayList<>();
        findAllButtons(root, buttons, root);
        for (Actor btn : buttons) {
            String text = normalizeText(getActorText(btn));
            if (text.contains("auto") || text.contains("tu dong") || text.contains("tu danh")
                    || text.contains("tan cong") || text.contains("chien dau") || text.contains("danh quai")) {
                return btn;
            }
        }
        return null;
    }

    /**
     * Ham tim nut Menu tren cay Actor:
     * Quet cac tu khoa: "menu", "chuc nang", "tuy chon".
     */
    public static Actor findMenuButton(Actor root) {
        if (root == null) return null;
        List<Actor> buttons = new ArrayList<>();
        findAllButtons(root, buttons, root);
        for (Actor btn : buttons) {
            String text = normalizeText(getActorText(btn));
            if (text.equals("menu") || text.contains("chuc nang") || text.contains("tuy chon")) {
                return btn;
            }
        }
        return null;
    }

    /**
     * Ham tim nut Xac nhan / Bat dau tren popup cai dat auto (neu co):
     * Quet cac tu khoa: "bat dau", "bat", "xac nhan", "luu", "ap dung", "ok".
     */
    public static Actor findConfirmOrStartButton(Actor root) {
        if (root == null) return null;
        List<Actor> buttons = new ArrayList<>();
        findAllButtons(root, buttons, root);
        for (Actor btn : buttons) {
            String text = normalizeText(getActorText(btn));
            if (text.equals("bat") || text.equals("bat dau") || text.contains("xac nhan")
                    || text.equals("luu") || text.equals("ap dung") || text.equals("ok")) {
                return btn;
            }
        }
        return null;
    }

    // Schedule one non-blocking state-machine step. Scene2D access stays on the render thread.
    private static synchronized void scheduleAutoAttackRenderStep(long now) {
        if (!autoAttackAttemptPending || autoAttackRenderTaskQueued || now < autoAttackPhaseDueTime) {
            return;
        }
        if (Gdx.app == null) {
            failAutoAttackAttempt("LibGDX app khong san sang.");
            return;
        }
        autoAttackRenderTaskQueued = true;
        try {
            Gdx.app.postRunnable(() -> runAutoAttackRenderStep());
        } catch (Throwable t) {
            autoAttackRenderTaskQueued = false;
            failAutoAttackAttempt("Khong the xep lich thao tac tren render thread: " + t.getMessage());
        }
    }

    private static synchronized void completeAutoAttackAttempt(String source) {
        autoAttackAttemptPending = false;
        autoAttackRenderTaskQueued = false;
        autoAttackPhase = AUTO_ATTACK_PHASE_INITIAL;
        autoAttackLastClickedButton = null;
        setAutoAttackActive(true);
        log("[AutoFarm-Combat] Da xac nhan kich hoat auto tan cong qua " + source + ".");
    }

    private static synchronized void failAutoAttackAttempt(String reason) {
        autoAttackAttemptPending = false;
        autoAttackRenderTaskQueued = false;
        autoAttackPhase = AUTO_ATTACK_PHASE_INITIAL;
        autoAttackLastClickedButton = null;
        setAutoAttackActive(false);
        log("[AutoFarm-Combat] Kich hoat auto tan cong that bai: " + reason);
    }

    private static synchronized void cancelAutoAttackAttempt(String reason) {
        boolean hadState = autoAttackAttemptPending || autoAttackRenderTaskQueued || isAutoAttackActive;
        autoAttackAttemptPending = false;
        autoAttackRenderTaskQueued = false;
        autoAttackPhase = AUTO_ATTACK_PHASE_INITIAL;
        autoAttackLastClickedButton = null;
        setAutoAttackActive(false);
        if (hadState && reason != null && !reason.isEmpty()) {
            log("[AutoFarm-Combat] Huy luong auto tan cong: " + reason);
        }
    }

    private static synchronized void runAutoAttackRenderStep() {
        autoAttackRenderTaskQueued = false;
        if (!autoAttackAttemptPending) {
            return;
        }

        long now = System.currentTimeMillis();
        if (now - autoAttackAttemptStartTime > AUTO_ATTACK_ATTEMPT_TIMEOUT_MS) {
            failAutoAttackAttempt("Qua thoi gian cho thao tac UI/native.");
            return;
        }

        try {
            List<Actor> roots = getActiveDialogRoots();

            if (autoAttackPhase == AUTO_ATTACK_PHASE_INITIAL) {
                for (Actor root : roots) {
                    Actor autoBtn = findAutoAttackButton(root);
                    if (autoBtn != null) {
                        log("[AutoFarm-Combat] Tim thay nut Auto truc tiep: [" + getActorText(autoBtn) + "]. Dang click...");
                        if (clickActor(autoBtn)) {
                            autoAttackLastClickedButton = autoBtn;
                            autoAttackPhase = AUTO_ATTACK_PHASE_DIRECT_CONFIRM;
                            autoAttackPhaseStartTime = now;
                            autoAttackPhaseDueTime = now + AUTO_ATTACK_CONFIRM_DELAY_MS;
                            return;
                        }
                    }
                }

                for (Actor root : roots) {
                    Actor menuBtn = findMenuButton(root);
                    if (menuBtn != null) {
                        log("[AutoFarm-Combat] Tim thay nut Menu: [" + getActorText(menuBtn) + "]. Dang click...");
                        if (clickActor(menuBtn)) {
                            autoAttackLastClickedButton = menuBtn;
                            autoAttackPhase = AUTO_ATTACK_PHASE_MENU_ITEM;
                            autoAttackPhaseStartTime = now;
                            autoAttackPhaseDueTime = now + AUTO_ATTACK_MENU_DELAY_MS;
                            return;
                        }
                    }
                }

                log("[AutoFarm-Combat] Khong thay nut Auto tren UI -> Kich hoat native attack...");
                boolean nativeStarted = com.a.c.f.a.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75.gIrLkUn75nEkIliiIiIILiWHATdoYouWantHEREHIhihIhAhahahohoHoHEheHEGiRlkUn75();
                if (nativeStarted) {
                    completeAutoAttackAttempt("native engine");
                } else {
                    failAutoAttackAttempt("native engine khong tim thay muc tieu kha dung.");
                }
                return;
            }

            if (autoAttackPhase == AUTO_ATTACK_PHASE_MENU_ITEM) {
                for (Actor root : roots) {
                    Actor autoBtn = findAutoAttackButton(root);
                    if (autoBtn != null && autoBtn != autoAttackLastClickedButton) {
                        log("[AutoFarm-Combat] Tim thay muc Auto trong menu: [" + getActorText(autoBtn) + "]. Dang click...");
                        if (clickActor(autoBtn)) {
                            autoAttackLastClickedButton = autoBtn;
                            autoAttackPhase = AUTO_ATTACK_PHASE_MENU_CONFIRM;
                            autoAttackPhaseStartTime = now;
                            autoAttackPhaseDueTime = now + AUTO_ATTACK_CONFIRM_DELAY_MS;
                            return;
                        }
                    }
                }
                if (now - autoAttackPhaseStartTime > AUTO_ATTACK_ATTEMPT_TIMEOUT_MS) {
                    failAutoAttackAttempt("Khong tim thay muc Auto sau khi mo menu.");
                } else {
                    autoAttackPhaseDueTime = now + 200L;
                }
                return;
            }

            Actor confirmBtn = null;
            for (Actor root : roots) {
                Actor candidate = findConfirmOrStartButton(root);
                if (candidate != null && candidate != autoAttackLastClickedButton) {
                    confirmBtn = candidate;
                    break;
                }
            }
            if (confirmBtn != null) {
                log("[AutoFarm-Combat] Tim thay nut xac nhan auto: [" + getActorText(confirmBtn) + "]. Dang click...");
                if (clickActor(confirmBtn)) {
                    completeAutoAttackAttempt("popup confirmation");
                } else {
                    failAutoAttackAttempt("Khong click duoc nut xac nhan.");
                }
                return;
            }

            if (now - autoAttackPhaseStartTime >= AUTO_ATTACK_CONFIRM_TIMEOUT_MS) {
                completeAutoAttackAttempt("click UI khong co popup xac nhan");
            } else {
                autoAttackPhaseDueTime = now + 200L;
            }
        } catch (Throwable t) {
            failAutoAttackAttempt("Ngoai le tren render thread: " + t.getMessage());
        }
    }

    /**
     * Queue the auto-attack UI/native flow without touching Scene2D from the watcher thread.
     */
    public static synchronized boolean triggerAutoAttackMenu() {
        long now = System.currentTimeMillis();
        if (!isAutoAttackMenuEnabled() || autoAttackAttemptPending || now - lastAutoAttackTriggerTime < 2500L) {
            return false;
        }

        lastAutoAttackTriggerTime = now;
        autoAttackAttemptPending = true;
        autoAttackRenderTaskQueued = false;
        autoAttackPhase = AUTO_ATTACK_PHASE_INITIAL;
        autoAttackAttemptStartTime = now;
        autoAttackPhaseStartTime = now;
        autoAttackPhaseDueTime = now;
        autoAttackLastClickedButton = null;
        setAutoAttackActive(false);
        log("[AutoFarm-Combat] Bat dau quy trinh kich hoat Menu Auto Tan Cong...");
        scheduleAutoAttackRenderStep(now);
        return autoAttackAttemptPending;
    }

    /**
     * Ham ho tro mo Menu Auto Tan Cong de nguoi dung xem/tinh chinh thong so.
     */
    public static synchronized boolean openAutoAttackMenu() {
        return triggerAutoAttackMenu();
    }

    /**
     * Dieu phoi vong lap tu dong duy tri tan cong khi da o vi tri train quai:
     * - Chi kich hoat khi:
     *   1. Auto Attack Menu bat.
     *   2. Nhan vat dang o Map train (khong phai Lang va khong phai Nong trai).
     *   3. Nhan vat con song ($HP > 0$), khong co popup kiet suc.
     *   4. Khong dang chay ve vi tri kiet suc va khong dang hai tao.
     */
    private static void handleAutoAttackFlow(long now) {
        if (!isAutoAttackMenuEnabled()) {
            cancelAutoAttackAttempt("Auto Attack dang tat.");
            return;
        }

        if (isPlayerExhausted() || isExhaustionDialogVisible()) {
            cancelAutoAttackAttempt("Nhan vat dang kiet suc hoac co popup kiet suc.");
            return;
        }

        if (isAppleHarvesting()) {
            if (autoAttackAttemptPending) {
                cancelAutoAttackAttempt("Dang uu tien hai tao.");
            }
            return;
        }

        int curMapId = getCurrentMapId();
        String curMap = getCurrentMapName();
        String normMap = normalizeText(curMap);
        boolean isFarm = (curMapId == 5) || normMap.contains("nong");
        boolean isVillage = (curMapId == 0 || curMapId == 2) || normMap.contains("lang");

        if (isVillage || isFarm) {
            cancelAutoAttackAttempt("Dang o Lang hoac Nong trai.");
            return;
        }

        // Neu dang o khac Map so voi Map train da chi dinh -> UU TIEN 100% DI CHUYEN QUA CONG, KHONG DANH QUAI
        SavedCoordinate targetFarm = getSavedExhaustionCoordinate();
        if (targetFarm == null) {
            targetFarm = getLastFarmMap();
        }
        if (targetFarm != null && !isSameMap(curMapId, curMap, targetFarm.mapId, targetFarm.mapName)) {
            if (autoAttackAttemptPending) {
                cancelAutoAttackAttempt("Dang tren duong chay toi map train.");
            }
            return;
        } else {
            isReturningToExhaustion = false;
        }

        // --- 1. THEO DOI & GHI NHAN EXP TANG TRUONG ---
        long curExp = getPlayerExp();
        long maxExp = getPlayerMaxExp();
        float expPct = getPlayerExpPercent();
        if (lastRecordedExp < 0L) {
            lastRecordedExp = curExp;
            log(String.format(Locale.ROOT, "[AutoFarm-Combat] Khoi tao theo doi EXP nhan vat: %d/%d (%.2f%%)", curExp, maxExp, expPct));
        } else if (curExp > lastRecordedExp) {
            long diff = curExp - lastRecordedExp;
            lastRecordedExp = curExp;
            log(String.format(Locale.ROOT,
                    "[AutoFarm-Combat] 🌟🌟🌟 XAC NHAN QUAI BI HA GUC -> EXP TANG: +%d EXP! Hien tai: %d/%d (%.2f%%) 🌟🌟🌟",
                    diff, curExp, maxExp, expPct));
        } else if (curExp < lastRecordedExp) {
            long lost = lastRecordedExp - curExp;
            lastRecordedExp = curExp;
            log(String.format(Locale.ROOT,
                    "[AutoFarm-Combat] ⚠️ Canh bao: EXP bi giam (-%d EXP do bi quai danh kiet suc). Hien tai: %d/%d (%.2f%%)",
                    lost, curExp, maxExp, expPct));
        }

        // Dinh ky 30s log trang thai EXP 1 lan neu dang train
        if (now - lastExpLogTime > 30_000L) {
            lastExpLogTime = now;
            log(String.format(Locale.ROOT, "[AutoFarm-Combat] Tien do EXP hien tai: %d/%d (%.2f%%) tai Map [%s - ID: %d]",
                    curExp, maxExp, expPct, curMap, curMapId));
        }

        if (autoAttackAttemptPending) {
            if (now - autoAttackAttemptStartTime > AUTO_ATTACK_ATTEMPT_TIMEOUT_MS) {
                failAutoAttackAttempt("Attempt auto attack timeout.");
            } else {
                scheduleAutoAttackRenderStep(now);
            }
            return;
        }

        // --- 2. DONG BO & KICH HOAT CO AUTO NATIVE CUA GAME ---
        enableGameNativeAutoCombat();

        // --- 3. COMBAT SCAN & MONSTER ENGAGEMENT ENGINE ---
        if (now - lastCombatScanTime < 350L) {
            return;
        }
        lastCombatScanTime = now;

        Vector2 pos = getPlayerPosition();
        if (pos == null) {
            return;
        }

        // Portal Boundary Guard: Neu nhan vat dang dung qua sat mep cong (< 3.0m) thi buoc lui ra vung an toan
        Array<com.a.c.f.a.b.e.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75> currentWps = getCurrentMapWaypoints();
        if (currentWps != null) {
            for (int i = 0; i < currentWps.size; i++) {
                com.a.c.f.a.b.e.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75 wp = currentWps.get(i);
                if (wp != null) {
                    Vector2 wpPos = wp.gIRLkuN75nEKliLILiiLiiWhAtDOYOUwAnTherehiHihIHAHAhaHOhohohEheHEgIRlKUN75();
                    if (wpPos != null && pos.dst(wpPos) < 3.0f) {
                        if (now - lastCombatMoveTime >= 1500L) {
                            lastCombatMoveTime = now;
                            float safeX = (wpPos.x > 30.0f) ? (wpPos.x - 5.0f) : (wpPos.x + 5.0f);
                            log(String.format(Locale.ROOT,
                                    "[AutoFarm-Combat] ⚠️ Nhan vat dung qua sat cong (X=%.1f) cach %.1fm -> Lui ra khoi mep cong (X=%.1f)...",
                                    pos.x, pos.dst(wpPos), safeX));
                            moveTo(safeX, pos.y);
                        }
                        return;
                    }
                }
            }
        }

        // --- STICKY TARGETING ENGINE ---
        // Kiem tra muc tieu dang danh co con hop le va song sot khong (Uu tien danh dut diem 1 mob)
        com.a.c.f.a.b.g.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 activeTarget = null;
        if (currentCombatTarget != null) {
            if (isMonsterDead(currentCombatTarget)) {
                log(String.format(Locale.ROOT,
                        "[AutoFarm-Combat] ⚔️ Quai muc tieu [%s - ID: %d] DA BI HA GUC! Dang chon muc tieu tiep theo...",
                        getMonsterName(currentCombatTarget), currentCombatTargetId));
                currentCombatTarget = null;
                currentCombatTargetId = -1;
            } else {
                Vector2 curTargetPos = getMonsterPosition(currentCombatTarget);
                if (curTargetPos == null) {
                    currentCombatTarget = null;
                    currentCombatTargetId = -1;
                } else {
                    float distToTarget = pos.dst(curTargetPos);
                    if (now - currentTargetLockTime > TARGET_LOCK_TIMEOUT_MS) {
                        log(String.format(Locale.ROOT,
                                "[AutoFarm-Combat] ⏱️ Muc tieu [%s - ID: %d] qua 25s chua ha guc -> Reset de doi muc tieu khac...",
                                getMonsterName(currentCombatTarget), currentCombatTargetId));
                        currentCombatTarget = null;
                        currentCombatTargetId = -1;
                    } else if (distToTarget > 14.0f) {
                        log(String.format(Locale.ROOT,
                                "[AutoFarm-Combat] 🏃 Muc tieu [%s - ID: %d] di chuyen qua xa (%.1fm > 14m) -> Bo khoa de tim quai gan hon...",
                                getMonsterName(currentCombatTarget), currentCombatTargetId, distToTarget));
                        currentCombatTarget = null;
                        currentCombatTargetId = -1;
                    } else {
                        // Kiem tra quai co bi day vao mep cong khong
                        boolean targetNearPortal = false;
                        if (currentWps != null) {
                            for (int w = 0; w < currentWps.size; w++) {
                                com.a.c.f.a.b.e.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75 wp = currentWps.get(w);
                                if (wp != null) {
                                    Vector2 wpPos = wp.gIRLkuN75nEKliLILiiLiiWhAtDOYOUwAnTherehiHihIHAHAhaHOhohohEheHEgIRlKUN75();
                                    if (wpPos != null && curTargetPos.dst(wpPos) < 3.2f) {
                                        targetNearPortal = true;
                                        break;
                                    }
                                }
                            }
                        }
                        if (targetNearPortal) {
                            log(String.format(Locale.ROOT,
                                    "[AutoFarm-Combat] 🚪 Muc tieu [%s - ID: %d] dung qua sat cong (< 3.2m) -> Bo qua de tranh hut vao cong...",
                                    getMonsterName(currentCombatTarget), currentCombatTargetId));
                            currentCombatTarget = null;
                            currentCombatTargetId = -1;
                        } else {
                            // MUC TIEU HOP LE: Giu chat muc tieu nay!
                            activeTarget = currentCombatTarget;
                        }
                    }
                }
            }
        }

        // Neu chua co muc tieu hoac muc tieu cu da chet -> Tim quai moi
        if (activeTarget == null) {
            activeTarget = findNearestLivingMonster(pos);
            if (activeTarget != null) {
                currentCombatTarget = activeTarget;
                currentCombatTargetId = activeTarget.a_();
                currentTargetLockTime = now;
            }
        }

        if (activeTarget != null) {
            Vector2 mPos = getMonsterPosition(activeTarget);
            float dist = (mPos != null) ? pos.dst(mPos) : Float.MAX_VALUE;
            String mName = getMonsterName(activeTarget);
            int mId = activeTarget.a_();

            if (lastTargetLoggedId != mId) {
                lastTargetLoggedId = mId;
                long mHp = getMonsterHp(activeTarget);
                long mMaxHp = getMonsterMaxHp(activeTarget);
                log(String.format(Locale.ROOT,
                        "[AutoFarm-Combat] 🎯 Khoa muc tieu: [%s - ID: %d] [HP: %d/%d] cach %.1fm -> Tap trung danh dut diem!",
                        mName, mId, mHp, mMaxHp, dist));
            }

            if (dist > 2.8f) {
                // Nhan vat o ngoai tam danh -> Di chuyen ap sat muc tieu dang danh
                if (now - lastCombatMoveTime >= 800L && mPos != null) {
                    lastCombatMoveTime = now;
                    float targetX = mPos.x;
                    float targetY = mPos.y;

                    // Portal Boundary Guard: Khong di chuyen de vao khu vuc cong chuyen map
                    if (currentWps != null) {
                        for (int i = 0; i < currentWps.size; i++) {
                            com.a.c.f.a.b.e.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75 wp = currentWps.get(i);
                            if (wp != null) {
                                Vector2 wpPos = wp.gIRLkuN75nEKliLILiiLiiWhAtDOYOUwAnTherehiHihIHAHAhaHOhohohEheHEgIRlKUN75();
                                if (wpPos != null && wpPos.dst(targetX, targetY) < 4.0f) {
                                    if (wpPos.x > targetX) {
                                        targetX = Math.min(targetX, wpPos.x - 4.0f);
                                    } else {
                                        targetX = Math.max(targetX, wpPos.x + 4.0f);
                                    }
                                }
                            }
                        }
                    }

                    moveTo(targetX, targetY);
                }
            } else {
                // Trong tam danh (dist <= 2.8f):
                // 1. Khoa muc tieu vao entity cua game (Target Lock)
                try {
                    com.a.c.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75(activeTarget);
                } catch (Throwable ignored) {}

                // 2. Tung don danh / phan phoi skill vao DUNG activeTarget
                if (now - lastAttackExecuteTime >= 350L) {
                    lastAttackExecuteTime = now;
                    executeAttackOnTarget(activeTarget);
                }
            }
        } else {
            // Khong tim thay quai vat nao gan (hoac dang dung o cong vao map X < 10)
            if (pos.x < 10.0f) {
                if (now - lastCombatMoveTime >= 3000L) {
                    lastCombatMoveTime = now;
                    float targetX = 45.0f;
                    float targetY = (pos.y > 0.0f) ? pos.y : 5.5f;
                    log(String.format(Locale.ROOT,
                            "[AutoFarm-Combat] Nhan vat dang o cong vao (X=%.1f, Y=%.1f) chua thay quai -> Tien vao bai quai trung tam (X=%.1f, Y=%.1f)...",
                            pos.x, pos.y, targetX, targetY));
                    moveTo(targetX, targetY);
                }
            }
        }
    }

    // =========================================================================
    // FEATURE 11: POST-LOGIN AUTOMATION & COMBAT DISPATCHER
    // =========================================================================

    public static boolean isPostLoginDispatched() {
        return postLoginDispatched;
    }

    public static void resetPostLoginDispatch() {
        postLoginDispatched = false;
        currentCombatTarget = null;
        currentCombatTargetId = -1;
        lastTargetLoggedId = -1;
        log("[AutoLogin-Dispatch] Da reset trang thai Post-Login Dispatch.");
    }

    /**
     * Xu ly phan luong tu dong ngay sau khi Auto Login thanh cong vao the gioi game:
     * - TRUONG HOP 1: Nhan vat dung dung o Map vi tri kiet suc duoc luu truoc do (hoac dung map train)
     *                 -> Kich hoat Auto Tan Cong (triggerAutoAttackMenu()).
     * - TRUONG HOP 2: Nhan vat khong dung Map kiet suc (dang o Lang, Nong trai hoac map khac)
     *                 -> Tu dong chay lai Map kiet suc (returnToExhaustionCoordinate()),
     *                    va khi den noi se tu dong bat Auto Tan Cong.
     */
    public static synchronized void handlePostLoginDispatch(int curMapId, String curMap, Vector2 curPos) {
        log(String.format(Locale.ROOT,
                "[AutoLogin-Dispatch] Kiem tra vi tri nhan vat sau khi dang nhap: Map [%s - ID: %d] tai (X=%.1f, Y=%.1f)...",
                curMap, curMapId, curPos != null ? curPos.x : 0f, curPos != null ? curPos.y : 0f));

        SavedCoordinate saved = getSavedExhaustionCoordinate();
        if (saved == null) {
            saved = getLastFarmMap();
        }

        boolean isTargetMap = false;
        if (saved != null) {
            isTargetMap = isSameMap(curMapId, curMap, saved.mapId, saved.mapName);
        } else {
            // Neu chua co toa do luu, kiem tra neu dang o mot map chien dau ngoai lang
            String norm = normalizeText(curMap);
            boolean isVillage = (curMapId == 0 || curMapId == 2) || norm.contains("lang") || norm.contains("eldarah");
            boolean isFarm = (curMapId == 5) || norm.contains("nong");
            if (!isVillage && !isFarm && curMapId > 2) {
                isTargetMap = true;
            }
        }

        if (isTargetMap) {
            // =====================================================================
            // TRUONG HOP 1: DUNG MAP KIET SUC / BAI TRAIN
            // =====================================================================
            log(String.format(Locale.ROOT,
                    "[AutoLogin-Dispatch] >>> TRUONG HOP 1: Nhan vat dung dung Map kiem/kiet suc da luu [%s - ID: %d] <<<",
                    curMap, curMapId));

            // Neu co toa do cu the (x > 0, y > 0) va nhan vat dang dung cach xa vi tri do
            if (saved != null && (saved.x > 0f || saved.y > 0f) && curPos != null) {
                float dx = saved.x - curPos.x;
                float dy = saved.y - curPos.y;
                float dist = (float) Math.sqrt(dx * dx + dy * dy);
                if (dist > ARRIVAL_RADIUS) {
                    log(String.format(Locale.ROOT,
                            "[AutoLogin-Dispatch] Cach toa do cu %.1fm -> Di chuyen toi (X=%.1f, Y=%.1f) va bat dau tan cong...",
                            dist, saved.x, saved.y));
                    moveTo(saved.x, saved.y);
                }
            } else if (curPos != null && curPos.x < 10.0f) {
                float targetX = 45.0f;
                float targetY = (curPos.y > 0.0f) ? curPos.y : 5.5f;
                log(String.format(Locale.ROOT,
                        "[AutoLogin-Dispatch] Nhan vat dang o cong vao (X=%.1f) -> Tien vao bai quai trung tam (X=%.1f, Y=%.1f)...",
                        curPos.x, targetX, targetY));
                moveTo(targetX, targetY);
            }

            log("[AutoLogin-Dispatch] Kich hoat Auto Tan Cong ngay lap tuc...");
            setAutoAttackMenuEnabled(true);
            enableGameNativeAutoCombat();
            triggerAutoAttackMenu();
        } else {
            // =====================================================================
            // TRUONG HOP 2: KHAC MAP KIET SUC (O LANG / NONG TRAI / MAP KHAC)
            // =====================================================================
            String targetMapInfo = (saved != null)
                    ? String.format(Locale.ROOT, "[%s - ID: %d]", saved.mapName, saved.mapId)
                    : "Chua xac dinh";
            log(String.format(Locale.ROOT,
                    "[AutoLogin-Dispatch] >>> TRUONG HOP 2: Nhan vat o Map [%s - ID: %d] (KHAC voi Map kiet suc %s) <<<",
                    curMap, curMapId, targetMapInfo));

            if (saved != null) {
                lastSavedExhaustionCoord = saved;
                log(String.format(Locale.ROOT,
                        "[AutoLogin-Dispatch] Tien hanh chay lai Map kiet suc %s tai (X=%.1f, Y=%.1f)...",
                        targetMapInfo, saved.x, saved.y));

                // Dam bao co tu dong quay lai duoc bat
                setAutoReturnToExhaustionEnabled(true);
                setAutoAttackMenuEnabled(true);

                // Danh dau da qua buoc thu hoach tao de khong bi chan khi dang o Lang/Nong trai sau login
                hasHarvestedApple = true;

                // Goi tien trinh chay lai map va toa do kiet suc
                returnToExhaustionCoordinate();
            } else {
                log("[AutoLogin-Dispatch] Chua co du lieu Map kiet suc da luu. Bot se tiep tuc theo doi vi tri khi nhan vat di chuyen.");
            }
        }
    }

    // =========================================================================
    // FEATURE 10: LOCAL HTTP REST API SERVER (PORT 7654) FOR MCP BRIDGE
    // =========================================================================

    public static synchronized void startHttpApiServer() {
        if (httpApiServer != null) {
            return;
        }
        try {
            httpApiServer = HttpServer.create(new InetSocketAddress("127.0.0.1", HTTP_API_PORT), 0);

            // 1. GET /status
            httpApiServer.createContext("/status", exchange -> {
                if (handleCors(exchange)) return;
                try {
                    long now = System.currentTimeMillis();
                    long uptimeSec = (gameStartTime > 0) ? ((now - gameStartTime) / 1000L) : 0L;
                    String charName = getCharacterName();
                    int level = getCharacterLevel();
                    String mapName = getCurrentMapName();
                    int mapId = getCurrentMapId();
                    int zone = getCurrentZone();
                    Vector2 pos = getPlayerPosition();
                    float posX = (pos != null) ? pos.x : 0.0f;
                    float posY = (pos != null) ? pos.y : 0.0f;
                    long hp = getPlayerHp();
                    long maxHp = getPlayerMaxHp();
                    long mp = getPlayerMp();
                    long maxMp = getPlayerMaxMp();
                    long exp = getPlayerExp();
                    long maxExp = getPlayerMaxExp();
                    float expPct = getPlayerExpPercent();
                    boolean inGame = isPlayerInGame();
                    boolean exhausted = isPlayerExhausted();

                    SavedCoordinate savedCoord = getSavedExhaustionCoordinate();
                    String farmMap = (savedCoord != null) ? savedCoord.mapName : (lastKnownMapName != null ? lastKnownMapName : "");
                    int farmMapId = (savedCoord != null) ? savedCoord.mapId : lastKnownMapId;

                    StringBuilder sb = new StringBuilder();
                    sb.append("{");
                    sb.append("\"connected\":").append(inGame).append(",");
                    sb.append("\"name\":\"").append(escapeJson(charName)).append("\",");
                    sb.append("\"level\":").append(level).append(",");
                    sb.append("\"map\":\"").append(escapeJson(mapName)).append("\",");
                    sb.append("\"map_id\":").append(mapId).append(",");
                    sb.append("\"zone\":").append(zone).append(",");
                    sb.append("\"x\":").append(String.format(Locale.US, "%.1f", posX)).append(",");
                    sb.append("\"y\":").append(String.format(Locale.US, "%.1f", posY)).append(",");
                    sb.append("\"hp\":").append(hp).append(",");
                    sb.append("\"max_hp\":").append(maxHp).append(",");
                    sb.append("\"mp\":").append(mp).append(",");
                    sb.append("\"max_mp\":").append(maxMp).append(",");
                    sb.append("\"exp\":").append(exp).append(",");
                    sb.append("\"max_exp\":").append(maxExp).append(",");
                    sb.append("\"exp_pct\":").append(String.format(Locale.US, "%.2f", expPct)).append(",");
                    sb.append("\"the_luc\":100,");
                    sb.append("\"max_the_luc\":100,");
                    sb.append("\"bot\":{");
                    sb.append("\"version\":\"").append(escapeJson(VERSION)).append("\",");
                    sb.append("\"uptime_seconds\":").append(uptimeSec).append(",");
                    sb.append("\"reconnecting\":").append(isLoggingIn).append(",");
                    sb.append("\"returning_to_farm\":").append(isReturningToExhaustion()).append(",");
                    sb.append("\"harvesting_apple\":").append(isAppleHarvesting()).append(",");
                    sb.append("\"has_harvested_apple\":").append(hasHarvestedApple).append(",");
                    sb.append("\"is_auto_attack\":").append(isAutoAttackActive()).append(",");
                    sb.append("\"auto_attack_menu_enabled\":").append(isAutoAttackMenuEnabled()).append(",");
                    sb.append("\"is_exhausted\":").append(exhausted).append(",");
                    sb.append("\"farm_map\":\"").append(escapeJson(farmMap)).append("\",");
                    sb.append("\"farm_map_id\":").append(farmMapId).append(",");
                    sb.append("\"party\":\"").append(escapeJson(getPartyStatusInfo())).append("\",");
                    sb.append("\"auto_party_enabled\":").append(isAutoPartyEnabled).append(",");
                    sb.append("\"map_scan\":\"").append(escapeJson(getExhaustionMapScanInfo())).append("\",");
                    sb.append("\"is_at_exhaustion_map\":").append(isAtExhaustionMap()).append(",");
                    sb.append("\"auto_map_scan_enabled\":").append(isAutoMapScanEnabled).append(",");
                    sb.append("\"mushroom_count\":").append(lastScannedMushroomCount).append(",");
                    sb.append("\"auto_pickup_enabled\":").append(isAutoPickupMapItemsEnabled).append(",");
                    sb.append("\"total_picked_items\":").append(totalPickedItemCount).append(",");
                    sb.append("\"last_picked_item\":\"").append(escapeJson(lastPickedItemName)).append("\",");
                    sb.append("\"scanned_mushrooms\":[");
                    for (int mIdx = 0; mIdx < lastScannedMushrooms.size(); mIdx++) {
                        ScannedMushroom sm = lastScannedMushrooms.get(mIdx);
                        if (mIdx > 0) sb.append(",");
                        sb.append("{")
                          .append("\"id\":").append(sm.id).append(",")
                          .append("\"type_id\":").append(sm.typeId).append(",")
                          .append("\"type\":\"").append(escapeJson(sm.type)).append("\",")
                          .append("\"name\":\"").append(escapeJson(sm.name)).append("\",")
                          .append("\"x\":").append(String.format(Locale.ROOT, "%.2f", sm.x)).append(",")
                          .append("\"y\":").append(String.format(Locale.ROOT, "%.2f", sm.y)).append(",")
                          .append("\"distance\":").append(String.format(Locale.ROOT, "%.2f", sm.distance))
                          .append("}");
                    }
                    sb.append("],");
                    sb.append("\"gold\":").append(lastBagGold).append(",");
                    sb.append("\"gem\":").append(lastBagGem).append(",");
                    sb.append("\"dui_ga_count\":").append(lastDuiGaCount).append(",");
                    sb.append("\"bag_item_count\":").append(lastScannedBagCount).append(",");
                    sb.append("\"bag_total_qty\":").append(lastScannedBagTotalQty).append(",");
                    sb.append("\"bag_summary\":\"").append(escapeJson(getBagSummary())).append("\",");
                    sb.append("\"auto_bag_scan_enabled\":").append(isAutoBagScanEnabled).append(",");
                    sb.append("\"mushroom_in_bag\":").append(lastMushroomCountInBag).append(",");
                    sb.append("\"auto_use_mushroom_enabled\":").append(isAutoUseMushroomEnabled).append(",");
                    sb.append("\"mushroom_use_interval_ms\":").append(mushroomUseIntervalMs).append(",");
                    sb.append("\"last_mushroom_use_time\":").append(lastMushroomUseTime);
                    sb.append("}");
                    sb.append("}");
                    sendJsonResponse(exchange, 200, sb.toString());
                } catch (Throwable t) {
                    sendJsonResponse(exchange, 500, "{\"error\":\"" + escapeJson(t.getMessage()) + "\"}");
                }
            });

            // 2. GET /log
            httpApiServer.createContext("/log", exchange -> {
                if (handleCors(exchange)) return;
                try {
                    int n = 50;
                    String query = exchange.getRequestURI().getQuery();
                    if (query != null) {
                        for (String param : query.split("&")) {
                            String[] pair = param.split("=");
                            if (pair.length == 2 && ("n".equalsIgnoreCase(pair[0]) || "lines".equalsIgnoreCase(pair[0]))) {
                                try { n = Integer.parseInt(pair[1]); } catch (Throwable ignored) {}
                            }
                        }
                    }
                    if (n < 1) n = 1;
                    if (n > 500) n = 500;

                    List<String> lines = readRecentLogLines(n);
                    StringBuilder sb = new StringBuilder();
                    sb.append("{\"lines\":[");
                    for (int i = 0; i < lines.size(); i++) {
                        if (i > 0) sb.append(",");
                        sb.append("\"").append(escapeJson(lines.get(i))).append("\"");
                    }
                    sb.append("]}");
                    sendJsonResponse(exchange, 200, sb.toString());
                } catch (Throwable t) {
                    sendJsonResponse(exchange, 500, "{\"error\":\"" + escapeJson(t.getMessage()) + "\"}");
                }
            });

            // 3. POST /command
            httpApiServer.createContext("/command", exchange -> {
                if (handleCors(exchange)) return;
                try {
                    String cmd = "";
                    if ("POST".equalsIgnoreCase(exchange.getRequestMethod())) {
                        try (BufferedReader reader = new BufferedReader(new InputStreamReader(exchange.getRequestBody(), StandardCharsets.UTF_8))) {
                            StringBuilder body = new StringBuilder();
                            String line;
                            while ((line = reader.readLine()) != null) body.append(line);
                            String bodyStr = body.toString();
                            int idx = bodyStr.indexOf("\"cmd\"");
                            if (idx >= 0) {
                                int colon = bodyStr.indexOf(':', idx);
                                if (colon >= 0) {
                                    int startQuote = bodyStr.indexOf('"', colon);
                                    if (startQuote >= 0) {
                                        int endQuote = bodyStr.indexOf('"', startQuote + 1);
                                        if (endQuote >= 0) {
                                            cmd = bodyStr.substring(startQuote + 1, endQuote).trim();
                                        }
                                    }
                                }
                            }
                        } catch (Throwable ignored) {}
                    }
                    if (cmd.isEmpty() && exchange.getRequestURI().getQuery() != null) {
                        for (String param : exchange.getRequestURI().getQuery().split("&")) {
                            String[] pair = param.split("=");
                            if (pair.length == 2 && "cmd".equalsIgnoreCase(pair[0])) {
                                cmd = pair[1].trim();
                            }
                        }
                    }
                    cmd = cmd.toLowerCase(Locale.ROOT);
                    String result = executeBotCommand(cmd);
                    sendJsonResponse(exchange, 200, "{\"ok\":true,\"result\":\"" + escapeJson(result) + "\"}");
                } catch (Throwable t) {
                    sendJsonResponse(exchange, 500, "{\"ok\":false,\"error\":\"" + escapeJson(t.getMessage()) + "\"}");
                }
            });

            // 4. GET /bag - Feature 16: Quet Hanh Trang & Tui Do Nhan Vat tu dong
            httpApiServer.createContext("/bag", exchange -> {
                if (handleCors(exchange)) return;
                try {
                    List<BagItem> equips = new ArrayList<>(lastScannedEquipItems);
                    List<BagItem> items = new ArrayList<>(lastScannedBagItems);
                    StringBuilder sb = new StringBuilder();
                    sb.append("{\"ok\":true,");
                    sb.append("\"gold\":").append(lastBagGold).append(",");
                    sb.append("\"gem\":").append(lastBagGem).append(",");
                    sb.append("\"locked\":").append(lastBagLocked).append(",");
                    sb.append("\"equipped_count\":").append(equips.size()).append(",");
                    sb.append("\"equipped\":[");
                    for (int i = 0; i < equips.size(); i++) {
                        if (i > 0) sb.append(",");
                        BagItem it = equips.get(i);
                        sb.append("{");
                        sb.append("\"slot\":").append(it.slot).append(",");
                        sb.append("\"id\":").append(it.id).append(",");
                        sb.append("\"name\":\"").append(escapeJson(it.name)).append("\",");
                        sb.append("\"qty\":").append(it.qty).append(",");
                        sb.append("\"type\":").append(it.type).append(",");
                        sb.append("\"desc\":\"").append(escapeJson(it.description)).append("\"");
                        sb.append("}");
                    }
                    sb.append("],");
                    sb.append("\"total_slots\":").append(items.size()).append(",");
                    sb.append("\"bag_count\":").append(items.size()).append(",");
                    sb.append("\"total_qty\":").append(lastScannedBagTotalQty).append(",");
                    sb.append("\"dui_ga_count\":").append(lastDuiGaCount).append(",");
                    sb.append("\"mushroom_in_bag\":").append(lastMushroomCountInBag).append(",");
                    sb.append("\"auto_use_mushroom_enabled\":").append(isAutoUseMushroomEnabled).append(",");
                    sb.append("\"mushroom_use_interval_ms\":").append(mushroomUseIntervalMs).append(",");
                    sb.append("\"last_mushroom_use_result\":\"").append(escapeJson(lastMushroomUseResult)).append("\",");
                    sb.append("\"summary\":\"").append(escapeJson(getBagSummary())).append("\",");
                    sb.append("\"bag\":[");
                    for (int i = 0; i < items.size(); i++) {
                        if (i > 0) sb.append(",");
                        BagItem it = items.get(i);
                        sb.append("{");
                        sb.append("\"slot\":").append(it.slot).append(",");
                        sb.append("\"id\":").append(it.id).append(",");
                        sb.append("\"name\":\"").append(escapeJson(it.name)).append("\",");
                        sb.append("\"qty\":").append(it.qty).append(",");
                        sb.append("\"type\":").append(it.type).append(",");
                        sb.append("\"desc\":\"").append(escapeJson(it.description)).append("\"");
                        sb.append("}");
                    }
                    sb.append("],");
                    List<BagItem> boxes = new ArrayList<>(lastScannedBoxItems);
                    sb.append("\"box_count\":").append(boxes.size()).append(",");
                    sb.append("\"box\":[");
                    for (int i = 0; i < boxes.size(); i++) {
                        if (i > 0) sb.append(",");
                        BagItem it = boxes.get(i);
                        sb.append("{");
                        sb.append("\"slot\":").append(it.slot).append(",");
                        sb.append("\"id\":").append(it.id).append(",");
                        sb.append("\"name\":\"").append(escapeJson(it.name)).append("\",");
                        sb.append("\"qty\":").append(it.qty).append(",");
                        sb.append("\"type\":").append(it.type).append(",");
                        sb.append("\"desc\":\"").append(escapeJson(it.description)).append("\"");
                        sb.append("}");
                    }
                    sb.append("]}");
                    sendJsonResponse(exchange, 200, sb.toString());
                } catch (Throwable t) {
                    sendJsonResponse(exchange, 500, "{\"ok\":false,\"error\":\"" + escapeJson(t.getMessage()) + "\"}");
                }
            });

            // 4.1. GET /inspect_inv - Chi tiet toan bo 8 mang trong Inventory Manager (RAM)
            httpApiServer.createContext("/inspect_inv", exchange -> {
                if (handleCors(exchange)) return;
                try {
                    String detail = inspectAllInventoryArrays();
                    sendJsonResponse(exchange, 200, "{\"ok\":true,\"detail\":\"" + escapeJson(detail) + "\"}");
                } catch (Throwable t) {
                    sendJsonResponse(exchange, 500, "{\"ok\":false,\"error\":\"" + escapeJson(t.getMessage()) + "\"}");
                }
            });

            // 5. GET /quests
            httpApiServer.createContext("/quests", exchange -> {
                if (handleCors(exchange)) return;
                sendJsonResponse(exchange, 200, "{\"quests\":[],\"hardworking\":{\"score\":0,\"milestones\":[]}}");
            });

            httpApiServer.setExecutor(Executors.newFixedThreadPool(2));
            httpApiServer.start();
            log("[API] HTTP API server khoi dong thanh cong tai http://127.0.0.1:" + HTTP_API_PORT);
        } catch (Throwable t) {
            log("[API-Error] Khong the khoi dong HTTP API server: " + t.getMessage());
        }
    }

    private static boolean handleCors(HttpExchange exchange) {
        if ("OPTIONS".equalsIgnoreCase(exchange.getRequestMethod())) {
            try {
                exchange.getResponseHeaders().set("Access-Control-Allow-Origin", "*");
                exchange.getResponseHeaders().set("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
                exchange.getResponseHeaders().set("Access-Control-Allow-Headers", "Content-Type");
                exchange.sendResponseHeaders(204, -1);
                exchange.close();
            } catch (Throwable ignored) {}
            return true;
        }
        return false;
    }

    private static void sendJsonResponse(HttpExchange exchange, int statusCode, String jsonResponse) {
        try {
            byte[] bytes = jsonResponse.getBytes(StandardCharsets.UTF_8);
            exchange.getResponseHeaders().set("Content-Type", "application/json; charset=utf-8");
            exchange.getResponseHeaders().set("Access-Control-Allow-Origin", "*");
            exchange.getResponseHeaders().set("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
            exchange.getResponseHeaders().set("Access-Control-Allow-Headers", "Content-Type");
            exchange.sendResponseHeaders(statusCode, bytes.length);
            try (OutputStream os = exchange.getResponseBody()) {
                os.write(bytes);
            }
        } catch (Throwable ignored) {}
    }

    private static String escapeJson(String s) {
        if (s == null) return "";
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            switch (c) {
                case '"': sb.append("\\\""); break;
                case '\\': sb.append("\\\\"); break;
                case '\b': sb.append("\\b"); break;
                case '\f': sb.append("\\f"); break;
                case '\n': sb.append("\\n"); break;
                case '\r': sb.append("\\r"); break;
                case '\t': sb.append("\\t"); break;
                default:
                    if (c < ' ') {
                        sb.append(String.format("\\u%04x", (int) c));
                    } else {
                        sb.append(c);
                    }
            }
        }
        return sb.toString();
    }

    private static List<String> readRecentLogLines(int n) {
        List<String> list = new ArrayList<>();
        synchronized (RECENT_LOGS) {
            if (!RECENT_LOGS.isEmpty()) {
                int start = Math.max(0, RECENT_LOGS.size() - n);
                for (int i = start; i < RECENT_LOGS.size(); i++) {
                    list.add(RECENT_LOGS.get(i));
                }
                return list;
            }
        }
        // Fallback: Doc tu file autofarm_log.txt
        try {
            File f = new File("autofarm_log.txt");
            if (f.exists()) {
                List<String> allLines = new ArrayList<>();
                try (BufferedReader reader = new BufferedReader(new InputStreamReader(new FileInputStream(f), StandardCharsets.UTF_8))) {
                    String line;
                    while ((line = reader.readLine()) != null) {
                        if (!line.trim().isEmpty()) {
                            allLines.add(line);
                        }
                    }
                }
                int start = Math.max(0, allLines.size() - n);
                for (int i = start; i < allLines.size(); i++) {
                    list.add(allLines.get(i));
                }
            }
        } catch (Throwable ignored) {}
        return list;
    }

    public static String executeBotCommand(String cmd) {
        log("[API] Nhan lenh qua HTTP API: " + cmd);
        if ("f6".equals(cmd) || "harvest_apple".equals(cmd)) {
            hasHarvestedApple = false;
            triggerHarvestApple();
            return "Da kich hoat chu trinh thu hoach cay tao nong trai (F6).";
        }
        if ("f7".equals(cmd) || "eat".equals(cmd)) {
            return "Da ghi nhan lenh an do da ngoai (F7).";
        }
        if ("f8".equals(cmd) || "sync_quest".equals(cmd) || "welfare".equals(cmd) || "phucloi".equals(cmd)) {
            lastOnlineRewardCheckTime = 0L;
            lastOnlineRewardClaimTime = 0L;
            lastDailyCheckinCheckTime = 0L;
            handleWelfareLoop(System.currentTimeMillis());
            return "Da gui lenh quet va nhan Phuc Loi, Qua Online, Diem Danh (F8). Ngay diem danh: " + getTodayDate();
        }
        if ("checkin".equals(cmd) || "diemdanh".equals(cmd)) {
            lastDailyCheckinCheckTime = 0L;
            handleDailyCheckin(System.currentTimeMillis());
            return "Da kiem tra Diem Danh ngay: " + getTodayDate() + " (Da luu: " + lastCheckinDate + ")";
        }
        if ("online_gift".equals(cmd) || "quaonline".equals(cmd)) {
            lastOnlineRewardCheckTime = 0L;
            lastOnlineRewardClaimTime = 0L;
            handleOnlineReward(System.currentTimeMillis());
            return "Da kiem tra va gui packet nhan Thuong Online.";
        }
        if ("party".equals(cmd) || "todoi".equals(cmd) || "party_status".equals(cmd)) {
            lastPartyScanTime = 0L;
            handlePartyAutomation(System.currentTimeMillis());
            return "Trang thai: " + getPartyStatusInfo();
        }
        if ("create_party".equals(cmd) || "taotodoi".equals(cmd)) {
            lastPartyCreateTime = 0L;
            Gdx.app.postRunnable(() -> {
                try {
                    com.a.d.a.gIRLkuN75nEKliLILiiLiiWhAtDOYOUwAnTherehiHihIHAHAhaHOhohohEheHEgIRlKUN75 client =
                            com.a.d.a.gIRLkuN75nEKliLILiiLiiWhAtDOYOUwAnTherehiHihIHAHAhaHOhohohEheHEgIRlKUN75.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75();
                    if (client != null) {
                        client.GIRlkUn75nEkLLllLLLlLlwhATDoyOuWanTHEreHIHihihAHAhahoHOhohEHEhegirlKUN75();
                        log("[ToDoi] Da gui packet Tao To Doi theo yeu cau API.");
                    }
                } catch (Throwable t) {
                    log("[ToDoi] Loi tao to doi: " + t.getMessage());
                }
            });
            return "Da gui lenh tao to doi len server.";
        }
        if ("approve_party".equals(cmd) || "duyet_todoi".equals(cmd)) {
            lastPartyToggleApproveTime = 0L;
            lastApplicantApproveTime = 0L;
            handlePartyAutomation(System.currentTimeMillis());
            return "Da gui lenh kich hoat tu dong duyet va phe duyet thanh vien to doi.";
        }
        if ("toggle_party".equals(cmd)) {
            isAutoPartyEnabled = !isAutoPartyEnabled;
            return "Da doi trang thai Auto Party thanh: " + (isAutoPartyEnabled ? "BAT" : "TAT");
        }
        if ("scan_map".equals(cmd) || "quet_map".equals(cmd) || "map_scan".equals(cmd)
                || "scan_mushroom".equals(cmd) || "quet_nam".equals(cmd) || "nam_huong".equals(cmd)) {
            lastExhaustionMapScanTime = 0L;
            handleExhaustionMapScan(System.currentTimeMillis());
            return getExhaustionMapScanInfo();
        }
        if ("toggle_map_scan".equals(cmd)) {
            isAutoMapScanEnabled = !isAutoMapScanEnabled;
            return "Da doi trang thai Quet Map Kiet Suc thanh: " + (isAutoMapScanEnabled ? "BAT" : "TAT");
        }
        if ("pickup_item".equals(cmd) || "nhat_item".equals(cmd) || "pickup".equals(cmd)) {
            lastPickupAttemptTime = 0L;
            lastExhaustionMapScanTime = 0L;
            handleExhaustionMapScan(System.currentTimeMillis());
            return "Da kich hoat quet & nhat item tren map kiet suc: " + getExhaustionMapScanInfo();
        }
        if ("toggle_pickup".equals(cmd) || "toggle_auto_pickup".equals(cmd)) {
            isAutoPickupMapItemsEnabled = !isAutoPickupMapItemsEnabled;
            return "Da doi trang thai Tu dong nhat item map kiet suc thanh: " + (isAutoPickupMapItemsEnabled ? "BAT" : "TAT");
        }
        if ("scan_bag".equals(cmd) || "quet_tui".equals(cmd) || "tui_do".equals(cmd) || "bag".equals(cmd)
                || "hanh_trang".equals(cmd) || "trang_bi".equals(cmd) || "equip".equals(cmd)) {
            lastBagScanTime = 0L;
            handleBagScan(System.currentTimeMillis());
            return getBagSummary();
        }
        if ("inspect_inv".equals(cmd) || "inspect_bag".equals(cmd) || "soi_tui".equals(cmd) || "kiem_tra_kho".equals(cmd)) {
            lastBagScanTime = 0L;
            handleBagScan(System.currentTimeMillis());
            return inspectAllInventoryArrays();
        }
        if ("toggle_bag_scan".equals(cmd)) {
            isAutoBagScanEnabled = !isAutoBagScanEnabled;
            return "Da doi trang thai Quet Tui Do & Hanh Trang thanh: " + (isAutoBagScanEnabled ? "BAT" : "TAT");
        }
        if ("use_mushroom".equals(cmd) || "dung_nam".equals(cmd) || "eat_mushroom".equals(cmd)) {
            lastMushroomUseTime = 0L;
            return handleAutoUseMushroom(System.currentTimeMillis());
        }
        if ("set_mushroom_interval_30s".equals(cmd)) {
            mushroomUseIntervalMs = 30_000L;
            return "Da set chu ky dung Nam huong thanh 30 giay (Che do Test).";
        }
        if ("set_mushroom_interval_30m".equals(cmd)) {
            mushroomUseIntervalMs = 1_800_000L;
            return "Da set chu ky dung Nam huong thanh 30 phut (Che do Chinh thuc).";
        }
        if ("toggle_use_mushroom".equals(cmd)) {
            isAutoUseMushroomEnabled = !isAutoUseMushroomEnabled;
            return "Da doi trang thai Tu dong dung Nam huong thanh: " + (isAutoUseMushroomEnabled ? "BAT" : "TAT");
        }
        if ("toggle_auto".equals(cmd) || "auto".equals(cmd)) {
            boolean next = !isAutoAttackMenuEnabled();
            setAutoAttackMenuEnabled(next);
            if (next) triggerAutoAttackMenu();
            return "Da doi trang thai Auto Attack thanh: " + (next ? "BAT" : "TAT");
        }
        if ("return_village".equals(cmd)) {
            boolean ok = autoSelectReturnToVillage();
            return ok ? "Da chon Ve Lang thanh cong." : "Khong co dialog Ve Lang de chon.";
        }
        if ("goto_farm".equals(cmd) || "return_coord".equals(cmd)) {
            isAutoReturnToExhaustionEnabled = true;
            boolean ok = returnToExhaustionCoordinate();
            return ok ? "Dang di chuyen quay lai toa do train cu." : "Khong the bat dau quay lai toa do cu.";
        }
        if ("set_farm".equals(cmd)) {
            int mapId = getCurrentMapId();
            String mapName = getCurrentMapName();
            Vector2 pos = getPlayerPosition();
            float x = (pos != null) ? pos.x : 0f;
            float y = (pos != null) ? pos.y : 0f;
            SavedCoordinate c = new SavedCoordinate(mapId, mapName, getCurrentZone(), x, y, System.currentTimeMillis());
            lastSavedExhaustionCoord = c;
            persistExhaustionState(c);
            isAutoReturnToExhaustionEnabled = true;
            return "Da set map farm thanh: " + mapName + " (ID: " + mapId + ") tai (" + String.format(Locale.ROOT, "%.1f, %.1f", x, y) + ")";
        }
        if ("fight".equals(cmd) || "attack".equals(cmd)) {
            isReturningToExhaustion = false;
            setAutoAttackMenuEnabled(true);
            enableGameNativeAutoCombat();
            return "Da kich hoat chien dau tan cong tai map hien tai!";
        }
        if ("status".equals(cmd)) {
            return "Bot online. Map: " + getCurrentMapName() + " (ID: " + getCurrentMapId() + ", Khu: " + getCurrentZone() + ")";
        }
        if ("debug_combat".equals(cmd) || "monsters".equals(cmd)) {
            return getCombatDebugInfo();
        }
        if ("post_login".equals(cmd) || "dispatch".equals(cmd)) {
            postLoginDispatched = false;
            handlePostLoginDispatch(getCurrentMapId(), getCurrentMapName(), getPlayerPosition());
            return "Da kich hoat lai quy trinh Post-Login Dispatch (Auto Attack / Quay lai map kiet suc).";
        }
        return "Lenh hop le: harvest_apple, f6, eat, f7, sync_quest, f8, checkin, online_gift, party, create_party, approve_party, toggle_party, scan_map, toggle_map_scan, scan_bag, quet_tui, bag, toggle_bag_scan, use_mushroom, dung_nam, set_mushroom_interval_30s, set_mushroom_interval_30m, toggle_use_mushroom, toggle_auto, return_village, goto_farm, set_farm, post_login, dispatch, status, debug_combat, monsters.";
    }

    public static String getCharacterName() {
        try {
            com.a.c.f.a.b.j.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75 player =
                    com.a.c.f.a.b.j.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75.GiRLKUN75NEklliilLliIiwhATDOyOUWanTheREhIhIHiHAHahahOHOHOhEhEHeGiRLkuN75();
            if (player != null && player.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 != null) {
                String n = player.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75.gIRLkuN75nEKliLILiiLiiWhAtDOYOUwAnTherehiHihIHAHAhaHOhohohEheHEgIRlKUN75;
                if (n != null && !n.trim().isEmpty()) {
                    return n.trim();
                }
            }
        } catch (Throwable ignored) {}
        return (savedUsername != null) ? savedUsername : "";
    }

    public static int getCharacterLevel() {
        try {
            com.a.c.f.a.b.j.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75 player =
                    com.a.c.f.a.b.j.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75.GiRLKUN75NEklliilLliIiwhATDOyOUWanTheREhIhIHiHAHahahOHOHOhEhEHeGiRLkuN75();
            if (player != null && player.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 != null) {
                int lv = player.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75.girLKUn75nEkLiLLlIllLIWhAtdOyouWaNTHErehIHiHiHahAhAHOHoHohEhEHegirLkUN75;
                if (lv > 0) return lv;
                lv = player.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75;
                if (lv > 0) return lv;
                lv = player.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75.GIRlkUn75nEKiLiLLliLiLWhATdOyouwanThEREHiHIHIhAhahahohoHOHehEhEgiRlKuN75;
                if (lv > 0) return lv;
            }
        } catch (Throwable ignored) {}
        return 1;
    }

    public static long getPlayerExp() {
        try {
            com.a.c.f.a.b.j.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75 player =
                    com.a.c.f.a.b.j.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75.GiRLKUN75NEklliilLliIiwhATDOyOUWanTheREhIhIHiHAHahahOHOHOhEhEHeGiRLkuN75();
            if (player != null && player.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 != null) {
                return player.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75.GIrlkuN75nEKillILLIiiiwhaTdoYouWANTherEhihIHihAhAhahoHOHohEHehEGIRLkUN75;
            }
        } catch (Throwable ignored) {}
        return 0L;
    }

    public static long getPlayerMaxExp() {
        try {
            com.a.c.f.a.b.j.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75 player =
                    com.a.c.f.a.b.j.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75.GiRLKUN75NEklliilLliIiwhATDOyOUWanTheREhIhIHiHAHahahOHOHOhEhEHeGiRLkuN75();
            if (player != null && player.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 != null) {
                return player.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75.gIRlKun75NekLLllIlllIlwHAtDOYoUWaNThERehihiHihahahahOhohOhEHEHEGirlkun75;
            }
        } catch (Throwable ignored) {}
        return 0L;
    }

    public static float getPlayerExpPercent() {
        try {
            long cur = getPlayerExp();
            long max = getPlayerMaxExp();
            if (max > 0L) {
                return (float) ((double) cur / (double) max * 100.0);
            }
        } catch (Throwable ignored) {}
        return 0.0f;
    }

    public static long getPlayerMp() {
        try {
            com.a.c.f.a.b.j.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75 player =
                    com.a.c.f.a.b.j.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75.GiRLKUN75NEklliilLliIiwhATDOyOUWanTheREhIhIHiHAHahahOHOHOhEhEHeGiRLkuN75();
            if (player != null && player.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 != null) {
                return player.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75.gIrLKuN75NekllIIlIllLIWHatDoYoUWantHEReHIHIHihahAHAHOHohOhEHehEGirlKUn75;
            }
        } catch (Throwable ignored) {}
        return 0L;
    }

    public static long getPlayerMaxMp() {
        try {
            com.a.c.f.a.b.j.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75 player =
                    com.a.c.f.a.b.j.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75.GiRLKUN75NEklliilLliIiwhATDOyOUWanTheREhIhIHiHAHahahOHOHOhEhEHeGiRLkuN75();
            if (player != null && player.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 != null) {
                return player.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75.gIRlkUN75NEKLLILlLillLwHatDoYoUwanthErEhIHiHiHahAhaHoHohOhEhEhEGIrlkUN75;
            }
        } catch (Throwable ignored) {}
        return 0L;
    }

    /**
     * Lay HP hien tai cua quai vat thong qua cau truc Monster Stats.
     */
    public static long getMonsterHp(com.a.c.f.a.b.g.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 m) {
        if (m == null) return 0L;
        try {
            if (m.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 != null) {
                return m.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75;
            }
        } catch (Throwable ignored) {}
        return 0L;
    }

    /**
     * Lay Max HP cua quai vat thong qua cau truc Monster Stats.
     */
    public static long getMonsterMaxHp(com.a.c.f.a.b.g.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 m) {
        if (m == null) return 0L;
        try {
            if (m.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 != null) {
                return m.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75.GIrLkUn75NEkIlillliLIIwhatDOYOUwaNThEREHIHihIHAHAHAHoHoHOHehEhEGIrLKuN75;
            }
        } catch (Throwable ignored) {}
        return 0L;
    }

    /**
     * Kiem tra quai vat da chet chua (ket hop ca isDead flag goc va luong HP <= 0).
     */
    public static boolean isMonsterDead(com.a.c.f.a.b.g.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 m) {
        if (m == null) return true;
        try {
            if (m.gIrLkun75nEKiLliiliiLiWhATDOYouWAntHeReHiHihIhaHahAHoHohOHEHEheGIrlKUN75()) {
                return true;
            }
            if (m.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 != null) {
                long hp = m.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75;
                if (hp <= 0L) return true;
            }
        } catch (Throwable ignored) {}
        return false;
    }

    public static com.a.c.f.a.b.g.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 findNearestLivingMonster(Vector2 playerPos) {
        try {
            com.badlogic.gdx.utils.Array<com.a.c.f.a.b.g.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75> monsters =
                    com.a.c.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75.GiRLKUN75NEklliilLliIiwhATDOyOUWanTheREhIhIHiHAHahahOHOHOhEhEHeGiRLkuN75;
            if (monsters == null || monsters.size == 0) return null;

            com.a.c.f.a.b.g.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 best = null;
            float bestDist = Float.MAX_VALUE;

            Array<com.a.c.f.a.b.e.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75> wps = getCurrentMapWaypoints();

            for (int i = 0; i < monsters.size; i++) {
                com.a.c.f.a.b.g.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 m = monsters.get(i);
                if (m == null || isMonsterDead(m)) {
                    continue; // Da chet
                }
                Vector2 mPos = getMonsterPosition(m);
                if (mPos == null) continue;

                // Bo qua quai vat dung sat cong dich chuyen (< 3.2m) de khong bi vo tinh hut qua map khac
                boolean nearPortal = false;
                if (wps != null) {
                    for (int w = 0; w < wps.size; w++) {
                        com.a.c.f.a.b.e.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75 wp = wps.get(w);
                        if (wp != null) {
                            Vector2 wpPos = wp.gIRLkuN75nEKliLILiiLiiWhAtDOYOUwAnTherehiHihIHAHAhaHOhohohEheHEgIRlKUN75();
                            if (wpPos != null && mPos.dst(wpPos) < 3.2f) {
                                nearPortal = true;
                                break;
                            }
                        }
                    }
                }
                if (nearPortal) continue;

                float d = (playerPos != null) ? playerPos.dst(mPos) : 0f;
                // Uu tien quai da bi thuong trong pham vi 6.0m de ket lieu dut diem truoc (-3.0m khoang cach ao)
                long hp = getMonsterHp(m);
                long maxHp = getMonsterMaxHp(m);
                float effectiveDist = d;
                if (hp > 0 && maxHp > 0 && hp < maxHp && d <= 6.0f) {
                    effectiveDist = Math.max(0.1f, d - 3.0f);
                }

                if (effectiveDist < bestDist) {
                    bestDist = effectiveDist;
                    best = m;
                }
            }
            return best;
        } catch (Throwable ignored) {}
        return null;
    }

    public static Vector2 getMonsterPosition(com.a.c.f.a.b.g.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 m) {
        if (m == null) return null;
        try {
            Vector2 pos = m.gIRLkuN75nEKliLILiiLiiWhAtDOYOUwAnTherehiHihIHAHAhaHOhohohEheHEgIRlKUN75();
            if (pos != null && (pos.x != 0f || pos.y != 0f)) return pos;
            return m.GirlKun75NekIlliLiLIiiWhAtdOyOuwAnTHereHIhihiHahAHAHOHOHOhEHeHeGiRLKuN75();
        } catch (Throwable ignored) {}
        return null;
    }

    public static String getMonsterName(com.a.c.f.a.b.g.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 m) {
        if (m == null) return "Quai vat";
        try {
            if (m.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 != null
                    && m.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75 != null) {
                String name = m.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75;
                if (name != null && !name.trim().isEmpty()) return name.trim();
            }
        } catch (Throwable ignored) {}
        return "Quai vat";
    }

    public static void enableGameNativeAutoCombat() {
        try {
            // 1. Khong gioi han pham vi auto (0 = toan ban do) va bat toan bo skill flags qua Reflection
            try {
                Class<?> autoSettingCls = Class.forName("com.a.c.girLkUN75NekLiiiliILiiWhaTdOYOUwaNTHeReHihiHihahAhAHOhOHohEhEHEGiRlKUN75");
                for (java.lang.reflect.Field f : autoSettingCls.getDeclaredFields()) {
                    if (f.getType() == int.class) {
                        f.setAccessible(true);
                        f.setInt(null, 0); // radius = 0 (infinite)
                    } else if (f.getType() == boolean[].class) {
                        f.setAccessible(true);
                        boolean[] arr = (boolean[]) f.get(null);
                        if (arr != null) {
                            for (int i = 0; i < arr.length; i++) arr[i] = true;
                        }
                    }
                }
            } catch (Throwable ignored) {}

            // 2. Bat co auto native trong player controller & Player master flag
            com.a.c.f.a.b.j.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75 player =
                    com.a.c.f.a.b.j.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75.GiRLKUN75NEklliilLliIiwhATDOyOUWanTheREhIhIHiHAHahahOHOHOhEhEHeGiRLkuN75();
            if (player != null) {
                player.GirLKun75nEkLlilLiLlILwHATDOYouWaNtherEHIhIHIHAhahAHoHoHoHEheHegiRlkun75(true);
                if (player.gIrLkun75nEKiLliiliiLiWhATDOYouWAntHeReHiHihIhaHahAHoHohOHEHEheGIrlKUN75 != null) {
                    if (!player.gIrLkun75nEKiLliiliiLiWhATDOYouWAntHeReHiHihIhaHahAHoHohOHEHEheGIrlKUN75.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75) {
                        player.gIrLkun75nEKiLliiliiLiWhATDOYouWAntHeReHiHihIhaHahAHoHohOHEHEheGIrlKUN75.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 = true;
                        log("[AutoFarm-Combat] Da BAT Native Auto Combat cua Game!");
                    }
                }
            }
            isAutoAttackActive = true;
        } catch (Throwable t) {
            log("[AutoFarm-Combat] Loi khi kich hoat native auto: " + t.getMessage());
        }
    }

    public static void executeAttackOnTarget(com.a.c.f.a.b.g.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 target) {
        if (Gdx.app == null) return;
        Gdx.app.postRunnable(() -> {
            try {
                // 1. Khoa muc tieu (Target Lock)
                if (target != null) {
                    com.a.c.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75(target);
                }

                // 2. Thuc hien tan cong co ban qua Normal Attack Controller (false = che do tan cong muc tieu)
                com.a.c.f.a.b.j.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75 player =
                        com.a.c.f.a.b.j.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75.GiRLKUN75NEklliilLliIiwhATDOyOUWanTheREhIhIHiHAHahahOHOHOhEhEHeGiRLkuN75();
                if (player != null && player.GIrLkun75NEkIliiILiiliWhATDOYouwantherehihIHihaHaHAhOHOhOhEHeHeGIRlKuN75 != null) {
                    player.GIrLkun75NEkIliiILiiliWhATDOYouwantherehihIHihaHaHAhOHOhOhEHeHeGIRlKuN75.GirLKun75nEkLlilLiLlILwHATDOYouWaNtherEHIhIHIHAhahAHoHoHoHEheHegiRlkun75(false);
                }

                // 2b. Direct Attack Packet Fallback: Truyen truc tiep goi tin danh muc tieu len server
                try {
                    com.a.d.a.gIRLkuN75nEKliLILiiLiiWhAtDOYOUwAnTherehiHihIHAHAhaHOhohohEheHEgIRlKUN75 sender =
                            com.a.d.a.gIRLkuN75nEKliLILiiLiiWhAtDOYOUwAnTherehiHihIHAHAhaHOhohohEheHEgIRlKUN75.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75();
                    if (sender != null && target != null) {
                        sender.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75(0, -1, target.a_());
                    }
                } catch (Throwable ignored) {}

                // 3. Goi cac nut ky nang (SkillButtons) tren UI neu co san sang
                com.a.c.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75 game =
                        com.a.c.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75;
                if (game != null) {
                    com.a.c.f.a.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 world =
                            game.gIrlKuN75NEKIlILIIiLlLWHatDOYouWanthereHihIhiHaHahAhOhoHOhEHEHEGIRLkun75();
                    if (world != null && world.GIRLkuN75nEkLlLiiLIlLlwhATdoYouwaNtherEHiHiHihaHaHAHOHOHoHehEHeGIrlKun75 != null) {
                        com.a.c.f.a.b.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75 ui =
                                world.GIRLkuN75nEkLlLiiLIlLlwhATdoYouwaNtherEHiHiHihaHaHAHOHOHoHehEHeGIrlKun75;
                        if (ui.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 != null) {
                            com.a.c.f.e.a.GirLKun75nEkLlilLiLlILwHATDOYouWaNtherEHIhIHIHAhahAHoHoHoHEheHegiRlkun75 table =
                                    ui.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75;
                            if (table.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75 != null) {
                                Object btnsObj = table.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75;
                                for (java.lang.reflect.Field f : btnsObj.getClass().getDeclaredFields()) {
                                    if (f.getType().isArray()) {
                                        f.setAccessible(true);
                                        Object[] arr = (Object[]) f.get(btnsObj);
                                        if (arr != null) {
                                            for (Object btn : arr) {
                                                if (btn != null) {
                                                    try {
                                                        for (java.lang.reflect.Method clickM : btn.getClass().getMethods()) {
                                                            if (clickM.getName().equals("GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75")
                                                                    && clickM.getParameterCount() == 0) {
                                                                clickM.invoke(btn);
                                                                break;
                                                            }
                                                        }
                                                    } catch (Throwable ignored) {}
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            } catch (Throwable ignored) {}
        });
    }

    public static String getCombatDebugInfo() {
        try {
            com.badlogic.gdx.utils.Array<com.a.c.f.a.b.g.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75> monsters =
                    com.a.c.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75.GiRLKUN75NEklliilLliIiwhATDOyOUWanTheREhIhIHiHAHahahOHOHOhEhEHeGiRLkuN75;
            int total = (monsters != null) ? monsters.size : 0;
            int living = 0;
            Vector2 pos = getPlayerPosition();
            StringBuilder sb = new StringBuilder();
            sb.append("Map: ").append(getCurrentMapName()).append(" (ID: ").append(getCurrentMapId()).append(")");
            sb.append(", Pos: ").append(pos != null ? String.format(Locale.ROOT, "(%.1f, %.1f)", pos.x, pos.y) : "null");
            sb.append(", EXP: ").append(getPlayerExp()).append("/").append(getPlayerMaxExp()).append(" (").append(String.format(Locale.ROOT, "%.2f%%", getPlayerExpPercent())).append(")");
            sb.append(", Total: ").append(total);
            if (monsters != null) {
                for (int i = 0; i < monsters.size; i++) {
                    com.a.c.f.a.b.g.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 m = monsters.get(i);
                    if (m != null && !m.gIrLkun75nEKiLliiliiLiWhATDOYouWAntHeReHiHihIhaHahAHoHohOHEHEheGIrlKUN75()) {
                        living++;
                        if (living <= 5) {
                            Vector2 mp = getMonsterPosition(m);
                            sb.append(" [").append(getMonsterName(m)).append(" @ ").append(mp != null ? String.format(Locale.ROOT, "(%.1f, %.1f)", mp.x, mp.y) : "null").append("]");
                        }
                    }
                }
            }
            sb.append(", Living: ").append(living);
            return sb.toString();
        } catch (Throwable t) {
            return "Loi: " + t.getMessage();
        }
    }

    // =========================================================================
    // FEATURE 13: AUTO PHUC LOI, QUA ONLINE, DIEM DANH & DONG POPUP
    // =========================================================================

    public static boolean isAutoWelfareEnabled() {
        return isAutoWelfareEnabled;
    }

    public static void setAutoWelfareEnabled(boolean enabled) {
        isAutoWelfareEnabled = enabled;
    }

    public static String getTodayDate() {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd", Locale.ROOT);
        return sdf.format(new Date());
    }

    public static void loadCheckinDate() {
        try {
            File file = new File(CHECKIN_DATE_FILE);
            if (file.exists() && file.isFile()) {
                try (BufferedReader reader = new BufferedReader(new InputStreamReader(new FileInputStream(file), StandardCharsets.UTF_8))) {
                    String line = reader.readLine();
                    if (line != null && !line.trim().isEmpty()) {
                        lastCheckinDate = line.trim();
                        log("[PhucLoi-DiemDanh] Khoi phuc ngay diem danh da luu tu file: " + lastCheckinDate);
                    }
                }
            }
        } catch (Throwable ignored) {}
    }

    public static void saveCheckinDate(String date) {
        try {
            File file = new File(CHECKIN_DATE_FILE);
            try (OutputStreamWriter writer = new OutputStreamWriter(new FileOutputStream(file, false), StandardCharsets.UTF_8)) {
                writer.write(date);
            }
        } catch (Throwable ignored) {}
    }

    /**
     * Tu dong kiem tra va nhan Qua Online / Truc Tuyen (Welfare Tabs + Online Notification).
     */
    public static void handleOnlineReward(long now) {
        if (!isAutoWelfareEnabled) return;
        if (now - lastOnlineRewardCheckTime < 10_000L) return;
        lastOnlineRewardCheckTime = now;
        if (now - lastOnlineRewardClaimTime < 5_000L) return;

        try {
            // 1. Quet cac tab Qua Online trong Welfare Manager
            com.a.c.c.H.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 welfareMgr =
                    com.a.c.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75.girLkUN75nEKIlILlLlLIlWhATdOYOUwanThErEhIHihiHaHAHahOHoHoHehehegirLkUN75;
            if (welfareMgr != null && welfareMgr.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 != null) {
                for (int i = 0; i < welfareMgr.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75.size; i++) {
                    com.a.c.c.H.GirLKun75nEkLlilLiLlILwHATDOYouWaNtherEHIhIHIHAhahAHoHoHoHEheHegiRlkun75 tab =
                            welfareMgr.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75.get(i);
                    if (tab == null) continue;
                    String tabName = tab.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75;
                    if (tabName == null) continue;
                    String norm = normalizeText(tabName);
                    boolean isOnlineTab = norm.contains("online") || norm.contains("truc tuyen") || norm.contains("thoi gian");
                    if (isOnlineTab && tab.GIRLkuN75nEkLlLiiLIlLlwhATdoYouwaNtherEHiHiHihaHaHAHOHOHoHehEHeGIrlKun75 != null) {
                        for (com.a.c.c.H.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75 item : tab.GIRLkuN75nEkLlLiiLIlLlwhATdoYouwaNtherEHiHiHihaHaHAHOHOHoHehEHeGIrlKun75) {
                            if (item != null && item.GIRLkuN75nEkLlLiiLIlLlwhATdoYouwaNtherEHiHiHihaHaHAHOHOHoHehEHeGIrlKun75 == 1) { // 1 = san sang nhan
                                int tabId = tab.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75;
                                int itemId = item.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75;
                                String itemName = (item.GirLKun75nEkLlilLiLlILwHATDOYouWaNtherEHIhIHIHAhahAHoHoHoHEheHegiRlkun75 != null && !item.GirLKun75nEkLlilLiLlILwHATDOYouWaNtherEHIhIHIHAhahAHoHoHoHEheHegiRlkun75.trim().isEmpty())
                                        ? item.GirLKun75nEkLlilLiLlILwHATDOYouWaNtherEHIhIHIHAhahAHoHoHoHEheHegiRlkun75.trim() : "Qua Online";
                                item.GIRLkuN75nEkLlLiiLIlLlwhATdoYouwaNtherEHiHiHihaHaHAHOHOHoHehEHeGIrlKun75 = (byte) 2;
                                lastOnlineRewardClaimTime = now;
                                Gdx.app.postRunnable(() -> {
                                    try {
                                        com.a.d.a.gIRLkuN75nEKliLILiiLiiWhAtDOYOUwAnTherehiHihIHAHAhaHOhohohEheHEgIRlKUN75 client =
                                                com.a.d.a.gIRLkuN75nEKliLILiiLiiWhAtDOYOUwAnTherehiHihIHAHAhaHOhohohEheHEgIRlKUN75.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75();
                                        if (client != null) {
                                            client.gIrlKuN75NEKIlILIIiLlLWHatDOYouWanthereHihIhiHaHahAhOhoHOhEHEHEGIRLkun75(tabId, itemId);
                                            log("[PhucLoi-Online] Da gui lenh nhan Qua Online [" + itemName + "] (Tab: " + tabId + ", Item: " + itemId + ") len server!");
                                        }
                                    } catch (Throwable t) {
                                        log("[PhucLoi-Online] Loi gui lenh nhan qua online: " + t.getMessage());
                                    }
                                });
                                return;
                            }
                        }
                    }
                }
            }

            // 2. Kiem tra qua notification Online truc tuyen
            com.a.c.c.o.GirLKun75nEkLlilLiLlILwHATDOYouWaNtherEHIhIHIHAhahAHoHoHoHEheHegiRlkun75 onlineNotify =
                    com.a.c.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75.gIrLKuN75NekllIIlIllLIWHatDoYoUWantHEReHIHIHihahAHAHOHohOhEHehEGirlKUn75;
            if (onlineNotify != null) {
                boolean canClaim = onlineNotify.gIRLkun75NEKLILLLilLILWHaTDoyouWAnthEReHiHihIhAHAHaHOHOHOHEHeHeGiRLKuN75
                        || onlineNotify.girLkUN75nEKIlILlLlLIlWhATdOYOUwanThErEhIHihiHaHAHahOHoHoHehehegirLkUN75
                        || onlineNotify.gIRLkUn75NEkLlLillLiLiwhatDOyouWanthERehihihIHAHAhAhOhOHoheHEHEgirLkuN75;
                if (canClaim) {
                    lastOnlineRewardClaimTime = now;
                    onlineNotify.gIRLkun75NEKLILLLilLILWHaTDoyouWAnthEReHiHihIhAHAHaHOHOHOHEHeHeGiRLKuN75 = false;
                    onlineNotify.girLkUN75nEKIlILlLlLIlWhATdOYOUwanThErEhIHihiHaHAHahOHoHoHehehegirLkUN75 = false;
                    onlineNotify.gIRLkUn75NEkLlLillLiLiwhatDOyouWanthERehihihIHAHAhAhOhOHoheHEHEgirLkuN75 = false;
                    Gdx.app.postRunnable(() -> {
                        try {
                            com.a.d.a.gIRLkuN75nEKliLILiiLiiWhAtDOYOUwAnTherehiHihIHAHAhaHOhohohEheHEgIRlKUN75 client =
                                    com.a.d.a.gIRLkuN75nEKliLILiiLiiWhAtDOYOUwAnTherehiHihIHAHAhaHOhohohEheHEgIRlKUN75.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75();
                            if (client != null) {
                                client.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75();
                                log("[PhucLoi-Online] Da gui lenh nhan Thuong Online notification len server!");
                            }
                        } catch (Throwable t) {
                            log("[PhucLoi-Online] Loi gui packet nhan notification: " + t.getMessage());
                        }
                    });
                }
            }
        } catch (Throwable t) {
            log("[PhucLoi-Online] Ngoai le kiem tra Qua Online: " + t.getMessage());
        }
    }

    /**
     * Tu dong kiem tra va nhan Qua Diem Danh / Chuyen Can hang ngay.
     */
    public static void handleDailyCheckin(long now) {
        if (!isAutoWelfareEnabled) return;
        if (now - lastDailyCheckinCheckTime < 20_000L) return;
        lastDailyCheckinCheckTime = now;

        String today = getTodayDate();
        if (lastCheckinDate != null && lastCheckinDate.equals(today)) {
            return; // Hom nay da diem danh roi
        }

        try {
            com.a.c.c.H.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 welfareMgr =
                    com.a.c.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75.girLkUN75nEKIlILlLlLIlWhATdOYOUwanThErEhIHihiHaHAHahOHoHoHehehegirLkUN75;
            if (welfareMgr != null && welfareMgr.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 != null) {
                for (int i = 0; i < welfareMgr.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75.size; i++) {
                    com.a.c.c.H.GirLKun75nEkLlilLiLlILwHATDOYouWaNtherEHIhIHIHAhahAHoHoHoHEheHegiRlkun75 tab =
                            welfareMgr.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75.get(i);
                    if (tab == null) continue;
                    String tabName = tab.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75;
                    if (tabName == null) continue;
                    String norm = normalizeText(tabName);
                    boolean isCheckinTab = norm.contains("diem danh") || norm.contains("chuyen can") || norm.contains("checkin");
                    if (isCheckinTab && tab.GIRLkuN75nEkLlLiiLIlLlwhATdoYouwaNtherEHiHiHihaHaHAHOHOHoHehEHeGIrlKun75 != null) {
                        for (com.a.c.c.H.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75 item : tab.GIRLkuN75nEkLlLiiLIlLlwhATdoYouwaNtherEHiHiHihaHaHAHOHOHoHehEHeGIrlKun75) {
                            if (item != null && item.GIRLkuN75nEkLlLiiLIlLlwhATdoYouwaNtherEHiHiHihaHaHAHOHOHoHehEHeGIrlKun75 == 1) { // 1 = san sang nhan
                                int tabId = tab.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75;
                                int itemId = item.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75;
                                item.GIRLkuN75nEkLlLiiLIlLlwhATdoYouwaNtherEHiHiHihaHaHAHOHOHoHehEHeGIrlKun75 = (byte) 2;
                                lastCheckinDate = today;
                                saveCheckinDate(today);
                                Gdx.app.postRunnable(() -> {
                                    try {
                                        com.a.d.a.gIRLkuN75nEKliLILiiLiiWhAtDOYOUwAnTherehiHihIHAHAhaHOhohohEheHEgIRlKUN75 client =
                                                com.a.d.a.gIRLkuN75nEKliLILiiLiiWhAtDOYOUwAnTherehiHihIHAHAhaHOhohohEheHEgIRlKUN75.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75();
                                        if (client != null) {
                                            client.gIrlKuN75NEKIlILIIiLlLWHatDOYouWanthereHihIhiHaHahAhOhoHOhEHEHEGIRLkun75(tabId, itemId);
                                            log("[PhucLoi-DiemDanh] Da gui lenh Diem Danh (Tab: " + tabId + ", Item: " + itemId + ") len server thanh cong!");
                                        }
                                    } catch (Throwable t) {
                                        log("[PhucLoi-DiemDanh] Loi gui lenh Diem Danh: " + t.getMessage());
                                    }
                                });
                                return;
                            }
                        }
                    }
                }
            }
        } catch (Throwable t) {
            log("[PhucLoi-DiemDanh] Ngoai le kiem tra Diem Danh: " + t.getMessage());
        }
    }

    /**
     * Tu dong tat popup phan thuong khi game hien thong bao chuc mung / nhan thuong thanh cong.
     */
    public static void dismissRewardPopups(long now) {
        if (now - lastRewardPopupDismissTime < 2_000L) return;
        lastRewardPopupDismissTime = now;

        try {
            List<Actor> dialogs = getActiveDialogRoots();
            if (dialogs == null || dialogs.isEmpty()) return;

            for (Actor dlg : dialogs) {
                if (dlg == null || !isActorConsideredVisible(dlg)) continue;
                String raw = getActorText(dlg);
                if (raw == null || raw.isEmpty()) continue;
                String norm = normalizeText(raw);

                // Bo qua neu la dialog kiet suc hoac cay tao (de cac loop khac xu ly)
                if (norm.contains("kiet suc") || norm.contains("ve lang") || norm.contains("cay tao") || norm.contains("thu hoach")) {
                    continue;
                }

                boolean isRewardPopup = norm.contains("nhan thuong thanh cong")
                        || norm.contains("thuong online")
                        || norm.contains("diem danh thanh cong")
                        || norm.contains("da nhan phan thuong")
                        || (norm.contains("chuc mung") && (norm.contains("nhan duoc") || norm.contains("phan thuong")));

                if (isRewardPopup) {
                    List<Actor> buttons = new ArrayList<>();
                    findAllButtons(dlg, buttons, dlg);
                    boolean clicked = false;
                    for (Actor btn : buttons) {
                        String btnText = normalizeText(getActorText(btn));
                        if (btnText.equals("dong") || btnText.equals("ok") || btnText.equals("xac nhan")
                                || btnText.equals("nhan") || btnText.contains("tiep tuc") || btnText.equals("tat") || btnText.equals("close")) {
                            clickActor(btn);
                            log("[PhucLoi-Popup] Da tu dong tat popup phan thuong! (Nut: '" + getActorText(btn) + "')");
                            clicked = true;
                            break;
                        }
                    }
                    if (!clicked && buttons.size() == 1) {
                        clickActor(buttons.get(0));
                        log("[PhucLoi-Popup] Da tu dong tat popup phan thuong (1 nut duy nhat)!");
                    }
                }
            }
        } catch (Throwable ignored) {}
    }

    /**
     * Bo dieu phoi Loop Bo Sung cho Phuc Loi, Qua Online, Diem Danh & Dong Popup.
     */
    public static void handleWelfareLoop(long now) {
        if (!isAutoWelfareEnabled) return;
        handleOnlineReward(now);
        handleDailyCheckin(now);
        dismissRewardPopups(now);
    }

    // =========================================================================
    // FEATURE 14: LOOP BO SUNG - AUTO TO DOI (TAO TO DOI & PHE DUYET THANH VIEN)
    // =========================================================================

    public static boolean isAutoPartyEnabled() {
        return isAutoPartyEnabled;
    }

    public static void setAutoPartyEnabled(boolean enabled) {
        isAutoPartyEnabled = enabled;
    }

    public static String getPartyStatusInfo() {
        try {
            com.a.c.c.F.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75 party =
                    com.a.c.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75.gIRLkUn75NEkLlLillLiLiwhatDOyouWanthERehihihIHAHAhAhOhOHoheHEHEgirLkuN75;
            if (party == null) {
                return "Chua co to doi (AutoParty: " + (isAutoPartyEnabled ? "BAT" : "TAT") + ")";
            }
            int memberCount = (party.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75 != null)
                    ? party.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75.size : 0;
            int appCount = (party.GIrLkUn75NEkIlillliLIIwhatDOYOUwaNThEREHIHihIHAHAHAHoHoHOHehEhEGIrLKuN75 != null)
                    ? party.GIrLkUn75NEkIlillliLIIwhatDOYOUwaNThEREHIHihIHAHAHAHoHoHOHehEhEGIrLKuN75.size : 0;
            boolean autoApprove = party.girLkUN75NekLiiiliILiiWhaTdOYOUwaNTHeReHihiHihahAhAHOhOHohEhEHEGiRlKUN75;
            StringBuilder sb = new StringBuilder();
            sb.append("To doi ID: ").append(party.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75)
              .append(" [").append(party.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75 != null ? party.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75 : "")
              .append("] | TV: ").append(memberCount).append("/5")
              .append(" | Cho duyet: ").append(appCount)
              .append(" | Tu dong duyet: ").append(autoApprove ? "BAT" : "TAT");
            if (memberCount > 0 && party.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75 != null) {
                sb.append(" | Danh sach: [");
                for (int i = 0; i < memberCount; i++) {
                    com.a.c.c.F.GIRLkuN75nEkLlLiiLIlLlwhATdoYouwaNtherEHiHiHihaHaHAHOHOHoHehEHeGIrlKun75 m =
                            party.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75.get(i);
                    if (m != null) {
                        if (i > 0) sb.append(", ");
                        sb.append(m.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75);
                    }
                }
                sb.append("]");
            }
            return sb.toString();
        } catch (Throwable t) {
            return "Loi doc to doi: " + t.getMessage();
        }
    }

    /**
     * Tu dong dong hoac xac nhan cac popup / thong bao lien quan den to doi.
     */
    public static void dismissOrAcceptPartyDialogs(long now) {
        if (now - lastPartyDialogCheckTime < 2_000L) return;
        lastPartyDialogCheckTime = now;

        try {
            List<Actor> dialogs = getActiveDialogRoots();
            if (dialogs == null || dialogs.isEmpty()) return;

            for (Actor dlg : dialogs) {
                if (dlg == null || !isActorConsideredVisible(dlg)) continue;
                String raw = getActorText(dlg);
                if (raw == null || raw.isEmpty()) continue;
                String norm = normalizeText(raw);

                // Bo qua cac dialog quan trong khac cua bot
                if (norm.contains("kiet suc") || norm.contains("ve lang") || norm.contains("cay tao") || norm.contains("thu hoach")) {
                    continue;
                }

                boolean isPartyPopup = norm.contains("to doi") || norm.contains("nhom") || norm.contains("gia nhap");
                if (isPartyPopup) {
                    List<Actor> buttons = new ArrayList<>();
                    findAllButtons(dlg, buttons, dlg);
                    if (buttons.size() == 1) {
                        clickActor(buttons.get(0));
                        log("[ToDoi-Popup] Da dong popup thong bao to doi: '" + raw.trim() + "'");
                    }
                }
            }
        } catch (Throwable ignored) {}
    }

    /**
     * Bo xu ly Tu Dong To Doi:
     * 1. Neu chua co to doi -> Gui goi tin tao to doi.
     * 2. Neu da co to doi va la Truong Nhom:
     *    - Neu chua bat Tu dong phe duyet -> Gui lenh bat tu dong phe duyet len server.
     *    - Neu co danh sach xin vao (applicants) -> Duyet tung thanh vien.
     */
    public static void handlePartyAutomation(long now) {
        if (!isAutoPartyEnabled) return;
        if (!isPlayerInGame()) return;

        dismissOrAcceptPartyDialogs(now);

        if (now - lastPartyScanTime < 1_500L) return;
        lastPartyScanTime = now;

        try {
            com.a.c.c.F.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75 party =
                    com.a.c.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75.gIRLkUn75NEkLlLillLiLiwhatDOyouWanthERehihihIHAHAhAhOhOHoheHEHEgirLkuN75;

            // 1. CHUA CO TO DOI -> Tu dong tao to doi moi
            if (party == null) {
                if (now - lastPartyCreateTime > 5_000L) {
                    lastPartyCreateTime = now;
                    Gdx.app.postRunnable(() -> {
                        try {
                            com.a.d.a.gIRLkuN75nEKliLILiiLiiWhAtDOYOUwAnTherehiHihIHAHAhaHOhohohEheHEgIRlKUN75 client =
                                    com.a.d.a.gIRLkuN75nEKliLILiiLiiWhAtDOYOUwAnTherehiHihIHAHAhaHOhohohEheHEgIRlKUN75.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75();
                            if (client != null) {
                                client.GIRlkUn75nEkLLllLLLlLlwhATDoyOuWanTHEreHIHihihAHAhahoHOhohEHEhegirlKUN75();
                                log("[ToDoi] Nhan vat chua co to doi -> Da TU DONG gui goi tin TAO TO DOI len server!");
                            }
                        } catch (Throwable t) {
                            log("[ToDoi] Loi tao to doi: " + t.getMessage());
                        }
                    });
                }
                return;
            }

            // 2. DA CO TO DOI -> Kiem tra vai tro Truong Nhom
            boolean isLeader = true;
            try {
                com.a.c.f.a.b.j.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75 player =
                        com.a.c.f.a.b.j.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75.GiRLKUN75NEklliilLliIiwhATDOyOUWanTheREhIhIHiHAHahahOHOHOhEhEHeGiRLkuN75();
                if (player != null) {
                    int myCharId = player.a_();
                    Object role = party.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75(myCharId);
                    if (role instanceof Enum) {
                        isLeader = (((Enum<?>) role).ordinal() == 0);
                    }
                }
            } catch (Throwable ignored) {}

            if (!isLeader) {
                return; // Chi truong nhom moi co quyen duyet va bat tu dong duyet
            }

            // 2.1. Tu dong bat 'Tu dong phe duyet thanh vien' neu server dang tat
            if (!party.girLkUN75NekLiiiliILiiWhaTdOYOUwaNTHeReHihiHihahAhAHOhOHohEhEHEGiRlKUN75 && now - lastPartyToggleApproveTime > 3_000L) {
                lastPartyToggleApproveTime = now;
                Gdx.app.postRunnable(() -> {
                    try {
                        com.a.d.a.gIRLkuN75nEKliLILiiLiiWhAtDOYOUwAnTherehiHihIHAHAhaHOhohohEheHEgIRlKUN75 client =
                                com.a.d.a.gIRLkuN75nEKliLILiiLiiWhAtDOYOUwAnTherehiHihIHAHAhaHOhohohEheHEgIRlKUN75.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75();
                        if (client != null) {
                            client.gIRLkUn75NEkLlLillLiLiwhatDOyouWanthERehihihIHAHAhAhOhOHoheHEHEgirLkuN75();
                            log("[ToDoi] To doi chua bat 'Tu dong phe duyet' -> Da gui lenh BAT 'Tu dong phe duyet' len server!");
                        }
                    } catch (Throwable t) {
                        log("[ToDoi] Loi gui goi bat tu dong phe duyet: " + t.getMessage());
                    }
                });
            }

            // 2.2. Tu dong phe duyet danh sach nguoi cho duyet (applicants)
            com.badlogic.gdx.utils.Array<com.a.c.c.F.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75> applicants =
                    party.GIrLkUn75NEkIlillliLIIwhatDOYOUwaNThEREHIHihIHAHAHAHoHoHOHehEhEGIrLKuN75;
            if (applicants != null && applicants.size > 0 && now - lastApplicantApproveTime > 1_500L) {
                lastApplicantApproveTime = now;
                Gdx.app.postRunnable(() -> {
                    try {
                        com.a.c.c.F.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75 curParty =
                                com.a.c.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75.gIRLkUn75NEkLlLillLiLiwhatDOyouWanthERehihihIHAHAhAhOhOHoheHEHEgirLkuN75;
                        if (curParty == null) return;
                        com.badlogic.gdx.utils.Array<com.a.c.c.F.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75> curApplicants =
                                curParty.GIrLkUn75NEkIlillliLIIwhatDOYOUwaNThEREHIHihIHAHAHAHoHoHOHehEhEGIrLKuN75;
                        if (curApplicants == null || curApplicants.size <= 0) return;

                        com.a.d.a.gIRLkuN75nEKliLILiiLiiWhAtDOYOUwAnTherehiHihIHAHAhaHOhohohEheHEgIRlKUN75 client =
                                com.a.d.a.gIRLkuN75nEKliLILiiLiiWhAtDOYOUwAnTherehiHihIHAHAhaHOhohohEheHEgIRlKUN75.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75();
                        if (client != null) {
                            for (int i = 0; i < curApplicants.size; i++) {
                                com.a.c.c.F.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 app = curApplicants.get(i);
                                if (app == null) continue;
                                int appId = app.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75;
                                String appName = (app.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75 != null)
                                        ? app.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75.trim() : ("ID:" + appId);
                                client.GiRlKun75neklIiLliILliWHatdOyOUwANThEREHihiHIHAHAhahoHOhOhEHeHeGiRlkUN75(appId);
                                log("[ToDoi] Da PHE DUYET thanh vien: [" + appName + "] (ID: " + appId + ") vao to doi!");
                            }
                        }
                    } catch (Throwable t) {
                        log("[ToDoi] Loi phe duyet thanh vien: " + t.getMessage());
                    }
                });
            }
        } catch (Throwable t) {
            log("[ToDoi] Ngoai le xu ly to doi: " + t.getMessage());
        }
    }

    // =========================================================================
    // FEATURE 15: LOOP BO SUNG - QUET MAP TAI MAP KIET SUC
    // =========================================================================

    public static boolean isAutoMapScanEnabled() {
        return isAutoMapScanEnabled;
    }

    public static void setAutoMapScanEnabled(boolean enabled) {
        isAutoMapScanEnabled = enabled;
    }

    /**
     * Kiem tra nhan vat co dang dung dung tai Map kiet suc (bai train quai) khong.
     * Tra ve false neu dang o Lang, Nong trai hoac dang tren duong quay lai.
     */
    public static boolean isAtExhaustionMap() {
        if (!isPlayerInGame()) return false;
        if (isReturningToExhaustion()) return false;

        String curMap = getCurrentMapName();
        int curMapId = getCurrentMapId();
        if (curMap == null || curMap.trim().isEmpty()) return false;

        String norm = normalizeText(curMap);
        boolean isVillage = (curMapId == 0 || curMapId == 2) || norm.contains("lang") || norm.contains("eldarah");
        boolean isFarm = (curMapId == 5) || norm.contains("nong");
        if (isVillage || isFarm) {
            return false;
        }

        SavedCoordinate sc = getSavedExhaustionCoordinate();
        if (sc != null && sc.mapId >= 0) {
            if (curMapId == sc.mapId) return true;
            if (sc.mapName != null && !sc.mapName.isEmpty()) {
                String scNorm = normalizeText(sc.mapName);
                if (norm.contains(scNorm) || scNorm.contains(norm)) return true;
            }
        }

        return curMapId > 2;
    }

    public static class ScannedMushroom {
        public final int id;
        public final String type;
        public final String name;
        public final float x;
        public final float y;
        public final float distance;
        public final long detectedTime;
        public final int typeId;

        public ScannedMushroom(int id, String type, String name, float x, float y, float distance, long detectedTime) {
            this(id, type, name, x, y, distance, detectedTime, 0);
        }

        public ScannedMushroom(int id, String type, String name, float x, float y, float distance, long detectedTime, int typeId) {
            this.id = id;
            this.type = type;
            this.name = name;
            this.x = x;
            this.y = y;
            this.distance = distance;
            this.detectedTime = detectedTime;
            this.typeId = typeId;
        }

        @Override
        public String toString() {
            return String.format(Locale.ROOT, "[%s: %s (ID:%d, Type:%d) tai (%.1f, %.1f) - %.1fm]", type, name, id, typeId, x, y, distance);
        }
    }

    /**
     * Bo loc vat the duoc spawn random tren map theo yeu cau:
     * 1. Nam huong (nấm hương)
     * 2. Qua mong (quả mọng)
     * 3. Co hoi sinh (cỏ hồi sinh)
     */
    public static boolean isTargetSpawnItemName(String raw) {
        if (raw == null || raw.trim().isEmpty()) return false;
        String norm = normalizeText(raw);
        if (norm.isEmpty()) return false;
        // 1. Nam huong (nấm hương)
        if (norm.contains("nam huong") || (norm.contains("nam") && norm.contains("huong"))) return true;
        // 2. Qua mong (quả mọng)
        if (norm.contains("qua mong") || (norm.contains("qua") && norm.contains("mong"))) return true;
        // 3. Co hoi sinh (cỏ hồi sinh)
        if (norm.contains("co hoi sinh") || (norm.contains("co") && norm.contains("hoi sinh"))) return true;
        return false;
    }

    public static boolean isMushroomName(String raw) {
        if (raw == null || raw.trim().isEmpty()) return false;
        String norm = normalizeText(raw);
        return norm.contains("nam huong") || (norm.contains("nam") && norm.contains("huong"));
    }

    public static String getGroundItemName(com.a.c.f.a.b.a.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 item) {
        if (item == null) return "";
        try {
            com.a.c.c.f.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 data =
                    item.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75;
            if (data != null) {
                com.a.c.c.f.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75 tmpl =
                        data.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75;
                if (tmpl == null && data.GirLKun75nEkLlilLiLlILwHATDOYouWaNtherEHIhIHIHAhahAHoHoHoHEheHegiRlkun75 > 0) {
                    tmpl = com.a.c.c.f.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75(
                            data.GirLKun75nEkLlilLiLlILwHATDOYouWaNtherEHIhIHIHAhahAHoHoHoHEheHegiRlkun75);
                }
                if (tmpl != null) {
                    if (tmpl.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 != null
                            && !tmpl.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75.trim().isEmpty()) {
                        return tmpl.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75.trim();
                    }
                    if (tmpl.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75 != null
                            && !tmpl.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75.trim().isEmpty()) {
                        return tmpl.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75.trim();
                    }
                }
            }
        } catch (Throwable ignored) {}
        return inspectAnyEntityName(item);
    }

    public static String getResourceNodeName(com.a.c.f.a.b.h.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 node) {
        if (node == null) return "";
        try {
            String name = node.GiRLKUN75NEklliilLliIiwhATDOyOUWanTheREhIhIHiHAHahahOHOHOhEhEHeGiRLkuN75();
            if (name != null && !name.trim().isEmpty()) return name.trim();
        } catch (Throwable ignored) {}
        try {
            if (node.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 != null
                    && node.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 != null) {
                String tmplName = node.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75;
                if (tmplName != null && !tmplName.trim().isEmpty()) {
                    return tmplName.trim();
                }
            }
        } catch (Throwable ignored) {}
        return inspectAnyEntityName(node);
    }

    public static String getMapObjectName(com.a.c.f.a.b.d.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 obj) {
        if (obj == null) return "";
        try {
            if (obj.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 != null
                    && obj.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 != null) {
                String n = obj.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75.GIRLkuN75nEkLlLiiLIlLlwhATdoYouwaNtherEHiHiHihaHaHAHOHOHoHehEHeGIrlKun75;
                if (n != null && !n.trim().isEmpty()) return n.trim();
            }
        } catch (Throwable ignored) {}
        return inspectAnyEntityName(obj);
    }

    public static String inspectAnyEntityName(Object entity) {
        if (entity == null) return "";
        try {
            for (Field f : entity.getClass().getDeclaredFields()) {
                if (Modifier.isStatic(f.getModifiers())) continue;
                f.setAccessible(true);
                Object val = f.get(entity);
                if (val instanceof String) {
                    String s = (String) val;
                    if (!s.trim().isEmpty() && s.length() < 60) {
                        return s.trim();
                    }
                } else if (val != null && !f.getType().isPrimitive() && !f.getType().getName().startsWith("java.lang")) {
                    for (Field subF : val.getClass().getDeclaredFields()) {
                        if (Modifier.isStatic(subF.getModifiers())) continue;
                        if (subF.getType() == String.class) {
                            subF.setAccessible(true);
                            Object subVal = subF.get(val);
                            if (subVal instanceof String) {
                                String s = (String) subVal;
                                if (!s.trim().isEmpty() && s.length() < 60) {
                                    return s.trim();
                                }
                            }
                        }
                    }
                }
            }
        } catch (Throwable ignored) {}
        return "";
    }

    public static Vector2 getMapEntityPosition(com.a.a.a.a.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 entity) {
        if (entity == null) return null;
        try {
            return entity.gIRLkuN75nEKliLILiiLiiWhAtDOYOUwAnTherehiHihIHAHAhaHOhohohEheHEgIRlKUN75();
        } catch (Throwable ignored) {}
        return null;
    }

    public static String getExhaustionMapScanInfo() {
        boolean atExhaustion = isAtExhaustionMap();
        String map = getCurrentMapName();
        int mapId = getCurrentMapId();
        if (!atExhaustion) {
            return "Khong o Map kiet suc (Hien tai: " + map + " - ID: " + mapId + ")";
        }
        if (lastScannedMushrooms.isEmpty()) {
            return "Map kiet suc: [" + map + " - ID: " + mapId + "] | Item spawn: 0 | Da nhat: " + totalPickedItemCount;
        }
        StringBuilder sb = new StringBuilder();
        sb.append("Map kiet suc: [").append(map).append(" - ID: ").append(mapId).append("] | Item spawn (").append(lastScannedMushrooms.size()).append("): ");
        for (int i = 0; i < lastScannedMushrooms.size(); i++) {
            if (i > 0) sb.append(", ");
            sb.append(lastScannedMushrooms.get(i).toString());
        }
        sb.append(" | Da nhat: ").append(totalPickedItemCount);
        return sb.toString();
    }

    public static boolean isAutoPickupMapItemsEnabled() {
        return isAutoPickupMapItemsEnabled;
    }

    public static void setAutoPickupMapItemsEnabled(boolean enabled) {
        isAutoPickupMapItemsEnabled = enabled;
    }

    public static int getTotalPickedItemCount() {
        return totalPickedItemCount;
    }

    public static String getLastPickedItemName() {
        return lastPickedItemName;
    }

    /**
     * Ham quet map trong Loop Bo Sung:
     * - RANG BUOC COT LOI: Chi hoat dong khi nhan vat o dung Map kiet suc (isAtExhaustionMap() == true).
     * - LOC CAC VAT PHAM DUOC SPAWN RANDOM O TREN MAP: Nam huong, Qua mong, Co hoi sinh.
     * - Quet qua toan bo danh sach Vat pham roi, Tai nguyen thu thap, Quai vat va Doi tuong tren map.
     * - Ghi nhan chi tiet toa do (X, Y), khoang cach, ID va TypeID cua tung vat the phat hien duoc.
     * - Tu dong tiep can va nhat item qua ham handlePickupTargetMapItems neu isAutoPickupMapItemsEnabled == true.
     */
    public static void handleExhaustionMapScan(long now) {
        if (!isAutoMapScanEnabled) return;
        if (!isPlayerInGame()) return;

        // DIEU KIEN COT LOI: Chi hoat dong o Map kiet suc
        if (!isAtExhaustionMap()) return;

        if (now - lastExhaustionMapScanTime < 1_000L) return;
        lastExhaustionMapScanTime = now;

        try {
            Vector2 playerPos = getPlayerPosition();
            List<ScannedMushroom> foundList = new ArrayList<>();

            // 1. Loc Vat pham roi tren map (Ground Items)
            com.badlogic.gdx.utils.Array<com.a.c.f.a.b.a.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75> items =
                    com.a.c.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75.gIRlKun75NekLLllIlllIlwHAtDOYoUWaNThERehihiHihahahahOhohOhEHEHEGirlkun75;
            if (items != null) {
                for (int i = 0; i < items.size; i++) {
                    com.a.c.f.a.b.a.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 item = items.get(i);
                    if (item == null) continue;
                    String name = getGroundItemName(item);
                    if (isTargetSpawnItemName(name)) {
                        Vector2 pos = getMapEntityPosition(item);
                        float x = (pos != null) ? pos.x : 0f;
                        float y = (pos != null) ? pos.y : 0f;
                        float dist = (pos != null && playerPos != null) ? playerPos.dst(pos) : 0f;
                        foundList.add(new ScannedMushroom(item.a_(), "Vat pham", name, x, y, dist, now, 0));
                    }
                }
            }

            // 2. Loc Tai nguyen / Thu thap / Cay coi / Khoang thach (Resource Nodes)
            com.badlogic.gdx.utils.Array<com.a.c.f.a.b.h.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75> resources =
                    com.a.c.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75.gIRlkUn75nEKiilIIIILilwhatDoYOuwaNtherEhiHiHihAHahAhoHOhoHeheheGirlKUN75;
            if (resources != null) {
                for (int i = 0; i < resources.size; i++) {
                    com.a.c.f.a.b.h.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 res = resources.get(i);
                    if (res == null) continue;
                    String name = getResourceNodeName(res);
                    if (isTargetSpawnItemName(name)) {
                        Vector2 pos = getMapEntityPosition(res);
                        float x = (pos != null) ? pos.x : 0f;
                        float y = (pos != null) ? pos.y : 0f;
                        float dist = (pos != null && playerPos != null) ? playerPos.dst(pos) : 0f;
                        int typeId = getEntityHTypeId(res);
                        foundList.add(new ScannedMushroom(res.a_(), "Thu thap", name, x, y, dist, now, typeId));
                    }
                }
            }

            // 3. Loc Quai vat tren map (Monsters / Mobs)
            com.badlogic.gdx.utils.Array<com.a.c.f.a.b.g.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75> monsters =
                    com.a.c.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75.GiRLKUN75NEklliilLliIiwhATDOyOUWanTheREhIhIHiHAHahahOHOHOhEhEHeGiRLkuN75;
            if (monsters != null) {
                for (int i = 0; i < monsters.size; i++) {
                    com.a.c.f.a.b.g.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 m = monsters.get(i);
                    if (m == null || isMonsterDead(m)) continue;
                    String name = getMonsterName(m);
                    if (isTargetSpawnItemName(name)) {
                        Vector2 pos = getMapEntityPosition(m);
                        float x = (pos != null) ? pos.x : 0f;
                        float y = (pos != null) ? pos.y : 0f;
                        float dist = (pos != null && playerPos != null) ? playerPos.dst(pos) : 0f;
                        foundList.add(new ScannedMushroom(m.a_(), "Quai vat", name, x, y, dist, now, 0));
                    }
                }
            }

            // 4. Loc Vat the tuong tac / Special Entities (Map Objects)
            com.badlogic.gdx.utils.Array<com.a.c.f.a.b.d.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75> objects =
                    com.a.c.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75.GIrlkuN75nEKillILLIiiiwhaTdoYouWANTherEhihIHihAhAhahoHOHohEHehEGIRLkUN75;
            if (objects != null) {
                for (int i = 0; i < objects.size; i++) {
                    com.a.c.f.a.b.d.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75 obj = objects.get(i);
                    if (obj == null) continue;
                    String name = getMapObjectName(obj);
                    if (isTargetSpawnItemName(name)) {
                        Vector2 pos = getMapEntityPosition(obj);
                        float x = (pos != null) ? pos.x : 0f;
                        float y = (pos != null) ? pos.y : 0f;
                        float dist = (pos != null && playerPos != null) ? playerPos.dst(pos) : 0f;
                        foundList.add(new ScannedMushroom(obj.a_(), "Vat the", name, x, y, dist, now, 0));
                    }
                }
            }

            // 5. Kiem tra su thay doi hoac phat hien moi
            int prevCount = lastScannedMushroomCount;
            lastScannedMushrooms.clear();
            lastScannedMushrooms.addAll(foundList);
            lastScannedMushroomCount = foundList.size();

            if (foundList.size() > 0 && prevCount != foundList.size()) {
                for (ScannedMushroom sm : foundList) {
                    log(String.format(Locale.ROOT,
                            "[QuetMap] >>> PHAT HIEN ITEM SPAWN [%s] (Loai: %s, ID: %d) tai (X=%.1f, Y=%.1f) cach %.1fm tren map kiet suc! <<<",
                            sm.name, sm.type, sm.id, sm.x, sm.y, sm.distance));
                }
            }

            // 6. Log dinh ky moi 25s tai map kiet suc
            if (now - lastExhaustionMapScanLogTime > 25_000L) {
                lastExhaustionMapScanLogTime = now;
                String mapName = getCurrentMapName();
                int mapId = getCurrentMapId();
                if (foundList.size() > 0) {
                    log("[QuetMap] Map kiet suc [" + mapName + " - ID: " + mapId + "]: Da loc duoc "
                            + foundList.size() + " vat the spawn random (Nam huong / Qua mong / Co hoi sinh): " + foundList);
                } else {
                    log("[QuetMap] Map kiet suc [" + mapName + " - ID: " + mapId + "]: Khong co vat the spawn random nao (0 vat the). Da nhat tong cong: " + totalPickedItemCount);
                }
            }

            // 7. Feature 18: Tu dong tiep can & Nhat/Thu thap cac item muc tieu da loc tren map kiet suc
            if (isAutoPickupMapItemsEnabled && !foundList.isEmpty()) {
                handlePickupTargetMapItems(now, foundList);
            }
        } catch (Throwable t) {
            log("[QuetMap] Ngoai le loc vat the spawn random tren map: " + t.getMessage());
        }
    }

    /**
     * Feature 18: Tu dong tiep can & Nhat/Thu thap vat pham spawn ngau nhien tren Map Kiet Suc
     * (Nam huong / Qua mong / Co hoi sinh).
     * RANG BUOC COT LOI:
     * - Chi hoat dong khi o dung Map kiet suc (isAtExhaustionMap() == true).
     * - Khi phat hien vat pham hop le:
     *   + Neu khoang cach > 1.2m: Di chuyen tiep can vat pham (moveTo).
     *   + Neu khoang cach <= 1.2m: Dung van toc, gui packet nhat vat pham / thu thap len server.
     *   + Co che Anti-Stuck: Neu thu nhat 1 vat the qua 4 lan khong thanh cong, tam bo qua 30s de khong bi ket.
     */
    public static void handlePickupTargetMapItems(long now, List<ScannedMushroom> items) {
        if (!isAutoPickupMapItemsEnabled) return;
        if (!isPlayerInGame()) return;
        if (!isAtExhaustionMap()) return;
        if (items == null || items.isEmpty()) return;

        // Don dep cache ignored items qua 30s
        for (java.util.Iterator<Map.Entry<Integer, Long>> it = ignoredPickupItems.entrySet().iterator(); it.hasNext(); ) {
            Map.Entry<Integer, Long> entry = it.next();
            if (now - entry.getValue() > 30_000L) {
                it.remove();
                pickupAttemptCounts.remove(entry.getKey());
            }
        }

        // Tim item gan nhat chua bi ignore
        ScannedMushroom target = null;
        float minDist = Float.MAX_VALUE;
        for (ScannedMushroom sm : items) {
            if (sm == null) continue;
            if (ignoredPickupItems.containsKey(sm.id)) continue;
            if (sm.distance < minDist) {
                minDist = sm.distance;
                target = sm;
            }
        }

        if (target == null) return;

        com.a.c.f.a.b.j.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75 player =
                com.a.c.f.a.b.j.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75.GiRLKUN75NEklliilLliIiwhATDOyOUWanTheREhIhIHiHAHahahOHOHOhEhEHeGiRLkuN75();
        if (player == null) return;

        Vector2 playerPos = getPlayerPosition();
        float currentDist = (playerPos != null) ? playerPos.dst(target.x, target.y) : target.distance;

        // Chang 1: Tiep can neu khoang cach > 1.2m
        if (currentDist > 1.2f) {
            if (now - lastPickupMoveTime >= 800L) {
                lastPickupMoveTime = now;
                log(String.format(Locale.ROOT,
                        "[NhatItem] 🏃 Dang tiep can [%s] (Loai: %s, ID: %d) tai (X=%.1f, Y=%.1f) cach %.1fm tren map kiet suc de nhat...",
                        target.name, target.type, target.id, target.x, target.y, currentDist));
                moveTo(target.x, target.y);
            }
            return;
        }

        // Chang 2: Da tiep can trong pham vi nhat (<= 1.2m) -> Dung van toc va gui packet
        if (now - lastPickupAttemptTime < 1_200L) return;
        lastPickupAttemptTime = now;

        final ScannedMushroom finalTarget = target;
        final int targetId = target.id;
        final int targetTypeId = target.typeId;
        final String targetType = target.type;
        final String targetName = target.name;

        // Tang dem so lan thu nhat
        int attempts = pickupAttemptCounts.getOrDefault(targetId, 0) + 1;
        pickupAttemptCounts.put(targetId, attempts);
        if (attempts >= 4) {
            log(String.format(Locale.ROOT,
                    "[NhatItem] ⚠️ Vat the [%s - ID: %d] da thu nhat %d lan -> Tam thoi bo qua 30s de tranh ket bot.",
                    targetName, targetId, attempts));
            ignoredPickupItems.put(targetId, now);
        }

        Gdx.app.postRunnable(() -> {
            try {
                // 1. Dung van toc nhan vat
                stopPlayerVelocity(player);
                if (player.girLKUn75nEkLiLLlIllLIWhAtdOyouWaNTHErehIHiHiHahAhAHOHoHohEhEHegirLkUN75 != null) {
                    player.girLKUn75nEkLiLLlIllLIWhAtdOyouWaNTHErehIHiHiHahAhAHOHoHohEhEHegirLkUN75.GirLKun75nEkLlilLiLlILwHATDOYouWaNtherEHIhIHIHAhahAHoHoHoHEheHegiRlkun75(false);
                }

                // 2. Gui packet nhat tuong ung theo loai doi tuong
                com.a.d.a.gIRLkuN75nEKliLILiiLiiWhAtDOYOUwAnTherehiHihIHAHAhaHOhohohEheHEgIRlKUN75 client =
                        com.a.d.a.gIRLkuN75nEKliLILiiLiiWhAtDOYOUwAnTherehiHihIHAHAhaHOhohohEheHEgIRlKUN75.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75();
                if (client != null) {
                    if ("Vat pham".equals(targetType)) {
                        // Ground item pickup packet
                        client.GIRLKun75NEkIllLLIilIlwHATdoYOUWaNTHErEHiHiHIHaHAHahoHohOhehEHegIRlKun75(targetId);
                        if (targetTypeId > 0) {
                            client.GirLKun75nEkLlilLiLlILwHATDOYouWaNtherEHIhIHIHAhahAHoHoHoHEheHegiRlkun75(targetId, targetTypeId);
                        }
                    } else if ("Thu thap".equals(targetType)) {
                        // Resource node collection packet (Opcode 24)
                        client.GirLKun75nEkLlilLiLlILwHATDOYouWaNtherEHIhIHIHAhahAHoHoHoHEheHegiRlkun75(targetId, targetTypeId);
                    } else if ("Vat the".equals(targetType)) {
                        // Map object interact packet
                        client.GIrlkuN75nEKillILLIiiiwhaTdoYouWANTherEhihIHihAhAhahoHOHohEHehEGIRLkUN75(targetId);
                    } else {
                        // Fallback
                        client.GIRLKun75NEkIllLLIilIlwHATdoYOUWaNTHErEHiHiHIHaHAHahoHohOhehEHegIRlKun75(targetId);
                        client.GirLKun75nEkLlilLiLlILwHATDOYouWaNtherEHIhIHIHAhahAHoHoHoHEheHegiRlkun75(targetId, targetTypeId);
                    }

                    totalPickedItemCount++;
                    lastPickedItemName = targetName;
                    log(String.format(Locale.ROOT,
                            "[NhatItem] 🎯 >>> DA GUI PACKET NHAT/THU THAP [%s - Loai: %s, ID: %d, TypeId: %d] TAI (X=%.1f, Y=%.1f) TREN MAP KIET SUC! (Tong da nhat: %d) <<<",
                            targetName, targetType, targetId, targetTypeId, finalTarget.x, finalTarget.y, totalPickedItemCount));
                }
            } catch (Throwable t) {
                log("[NhatItem] Loi khi gui goi tin nhat item: " + t.getMessage());
            }
        });
    }

    // =========================================================================
    // Feature 16: Loop Bo Sung: Quet Tui Do Nhan Vat (Character Bag Scanner)
    // =========================================================================
    public static class BagItem {
        public final int slot;
        public final int id;
        public final String name;
        public final long qty;
        public final int type;
        public final String description;

        public BagItem(int slot, int id, String name, long qty, int type, String description) {
            this.slot = slot;
            this.id = id;
            this.name = (name != null) ? name : "";
            this.qty = qty;
            this.type = type;
            this.description = (description != null) ? description : "";
        }

        @Override
        public String toString() {
            return String.format(Locale.ROOT, "[Slot %d] %s x%d (ID: %d)", slot, name, qty, id);
        }
    }

    public static boolean isAutoBagScanEnabled() {
        return isAutoBagScanEnabled;
    }

    public static void setAutoBagScanEnabled(boolean enabled) {
        isAutoBagScanEnabled = enabled;
    }

    public static List<BagItem> getEquipItems() {
        return java.util.Collections.unmodifiableList(new ArrayList<>(lastScannedEquipItems));
    }

    public static int getEquipCount() {
        return lastScannedEquipCount;
    }

    public static List<BagItem> getBagItems() {
        return java.util.Collections.unmodifiableList(new ArrayList<>(lastScannedBagItems));
    }

    public static int getDuiGaCount() {
        return lastDuiGaCount;
    }

    public static int getBagItemCount() {
        return lastScannedBagCount;
    }

    public static long getBagTotalQty() {
        return lastScannedBagTotalQty;
    }

    public static long getBagGold() {
        return lastBagGold;
    }

    public static long getBagGem() {
        return lastBagGem;
    }

    public static long getBagLocked() {
        return lastBagLocked;
    }

    public static String getBagSummary() {
        if (!wasInGame) {
            return "Chua vao game de doc tui do.";
        }
        StringBuilder sb = new StringBuilder();
        // 1. Hanh Trang / Trang Bi tren nguoi (Equipped Gear)
        sb.append(String.format(Locale.ROOT, "[Hanh Trang / Trang Bi] %d mon: ", lastScannedEquipCount));
        if (lastScannedEquipItems.isEmpty()) {
            sb.append("(Chua co trang bi)");
        } else {
            for (int i = 0; i < lastScannedEquipItems.size(); i++) {
                if (i > 0) sb.append(", ");
                BagItem it = lastScannedEquipItems.get(i);
                sb.append(it.name).append("x").append(it.qty);
            }
        }

        // 2. Tui Do (Vat pham / Tieu hao)
        sb.append(String.format(Locale.ROOT, " | [Tui Do] %d o (Tong %d mon, Vang: %d, Ngoc: %d, Dui ga: %d): ",
                lastScannedBagCount, lastScannedBagTotalQty, lastBagGold, lastBagGem, lastDuiGaCount));
        if (lastScannedBagItems.isEmpty()) {
            sb.append("(Trong - chua co vat pham)");
        } else {
            int limit = Math.min(10, lastScannedBagItems.size());
            for (int i = 0; i < limit; i++) {
                if (i > 0) sb.append(", ");
                BagItem it = lastScannedBagItems.get(i);
                sb.append(it.name).append("x").append(it.qty);
            }
            if (lastScannedBagItems.size() > limit) {
                sb.append(", ... (+").append(lastScannedBagItems.size() - limit).append(" o nua)");
            }
        }
        // 3. Ruong Do / Kho Luu Tru
        sb.append(String.format(Locale.ROOT, " | [Ruong Do] %d o: ", lastScannedBoxCount));
        if (lastScannedBoxItems.isEmpty()) {
            sb.append("(Trong)");
        } else {
            int limit = Math.min(8, lastScannedBoxItems.size());
            for (int i = 0; i < limit; i++) {
                if (i > 0) sb.append(", ");
                BagItem it = lastScannedBoxItems.get(i);
                sb.append(it.name).append("x").append(it.qty);
            }
            if (lastScannedBoxItems.size() > limit) {
                sb.append(", ... (+").append(lastScannedBoxItems.size() - limit).append(" o nua)");
            }
        }
        return sb.toString();
    }

    private static List<BagItem> parseItemArray(com.badlogic.gdx.utils.Array<com.a.c.c.j.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75> arr) {
        List<BagItem> list = new ArrayList<>();
        if (arr == null) return list;
        int size = arr.size;
        for (int i = 0; i < size; i++) {
            com.a.c.c.j.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75 item = arr.get(i);
            if (item == null) continue;

            int id = item.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75;
            com.a.c.c.j.GIRLkuN75nEkLlLiiLIlLlwhATdoYouwaNtherEHiHiHihaHaHAHOHOHoHehEHeGIrlKun75 tmpl =
                    item.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75;

            String name = "";
            String desc = "";
            int type = 0;
            if (tmpl != null) {
                if (tmpl.GIRLkuN75nEkLlLiiLIlLlwhATdoYouwaNtherEHiHiHihaHaHAHOHOHoHehEHeGIrlKun75 != null) {
                    name = tmpl.GIRLkuN75nEkLlLiiLIlLlwhATdoYouwaNtherEHiHiHihaHaHAHOHOHoHehEHeGIrlKun75.trim();
                }
                if (tmpl.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75 != null) {
                    desc = tmpl.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75.trim();
                }
                type = tmpl.GIRlkUn75nEkLLllLLLlLlwhATDoyOuWanTHEreHIHihihAHAhahoHOhohEHEhegirlKUN75;
            }
            if (name.isEmpty()) {
                name = "Vat pham #" + id;
            }

            long qty = item.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75;
            if (qty <= 0) {
                qty = 1L;
            }

            list.add(new BagItem(i, id, name, qty, type, desc));
        }
        return list;
    }

    /**
     * Soi toan bo cac mang du lieu trong Inventory Manager (RAM Game).
     */
    public static String inspectAllInventoryArrays() {
        if (!wasInGame) {
            return "Chua vao game de inspect inventory.";
        }
        try {
            com.a.c.c.t.GirLKun75nEkLlilLiLlILwHATDOYouWaNtherEHIhIHIHAhahAHoHoHoHEheHegiRlkun75 inv =
                    com.a.c.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75.GIRlkUn75nEkLLllLLLlLlwhATDoyOuWanTHEreHIHihihAHAhahoHOhohEHEhegirlKUN75;
            if (inv == null) {
                return "inv == null trong bo nho game.";
            }

            StringBuilder sb = new StringBuilder();
            sb.append("=== CHI TIET CAC MANG TRONG INVENTORY (RAM GAME) ===\n");
            sb.append(String.format(Locale.ROOT, "Vang: %d | Ngoc: %d | Khoa: %d\n",
                    inv.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75,
                    inv.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75,
                    inv.GirLKun75nEkLlilLiLlILwHATDOYouWaNtherEHIhIHIHAhahAHoHoHoHEheHegiRlkun75));

            appendArrayInspect(sb, "Mang 1 (Equipped - Hanh Trang/Trang Bi)", inv.gIrlKuN75NEKIlILIIiLlLWHatDOYouWanthereHihIhiHaHahAhOhoHOhEHEHEGIRLkun75);
            appendArrayInspect(sb, "Mang 2 (GIRlkUn75...)", inv.GIRlkUn75nEkLLllLLLlLlwhATDoyOuWanTHEreHIHihihAHAhahoHOhohEHEhegirlKUN75);
            appendArrayInspect(sb, "Mang 3 (girLkUN75...)", inv.girLkUN75NekLiiiliILiiWhaTdOYOUwaNTHeReHihiHihahAhAHOhOHohEhEHEGiRlKUN75);
            appendArrayInspect(sb, "Mang 4 (GIRlkUn75...)", inv.GIRlkUn75nEKiLiLLliLiLWhATdOyouwanThEREHiHIHIhAhahahohoHOHehEhEgiRlKuN75);
            appendArrayInspect(sb, "Mang 5 (gIRLkuN75...)", inv.gIRLkuN75nEKliLILiiLiiWhAtDOYOUwAnTherehiHihIHAHAhaHOhohohEheHEgIRlKUN75);
            appendArrayInspect(sb, "Mang 6 (gIRLkUn75 - UI Grid Tui Do)", inv.gIRLkUn75NEkLlLillLiLiwhatDOyouWanthERehihihIHAHAhAhOhOHoheHEHEgirLkuN75);
            appendArrayInspect(sb, "Mang 7 (GirlKun75...)", inv.GirlKun75NekIlliLiLIiiWhAtdOyOuwAnTHereHIhihiHahAHAHOHOHOhEHeHeGiRLKuN75);
            appendArrayInspect(sb, "Mang 8 (girLkUN75...)", inv.girLkUN75nEKIlILlLlLIlWhATdOYOUwanThErEhIHihiHaHAHahOHoHoHehehegirLkUN75);

            return sb.toString();
        } catch (Throwable t) {
            return "Loi khi inspect inventory: " + t.getMessage();
        }
    }

    private static void appendArrayInspect(StringBuilder sb, String label, com.badlogic.gdx.utils.Array<com.a.c.c.j.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75> arr) {
        if (arr == null) {
            sb.append(label).append(": NULL\n");
            return;
        }
        sb.append(label).append(": size=").append(arr.size);
        if (arr.size > 0) {
            sb.append(" [");
            for (int i = 0; i < arr.size; i++) {
                if (i > 0) sb.append(", ");
                com.a.c.c.j.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75 it = arr.get(i);
                if (it == null) {
                    sb.append("null");
                    continue;
                }
                String name = "";
                if (it.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75 != null &&
                    it.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75.GIRLkuN75nEkLlLiiLIlLlwhATdoYouwaNtherEHiHiHihaHaHAHOHOHoHehEHeGIrlKun75 != null) {
                    name = it.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75.GIRLkuN75nEkLlLiiLIlLlwhATdoYouwaNtherEHiHiHihaHaHAHOHOHoHehEHeGIrlKun75.trim();
                }
                int qty = it.GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75;
                if (qty <= 0) qty = 1;
                sb.append(name.isEmpty() ? ("#" + it.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75) : name).append("x").append(qty);
            }
            sb.append("]");
        }
        sb.append("\n");
    }

    /**
     * Call-site hook: Injected into Loop Bo Sung inside tick()
     * Quet toan bo o chua do trong Hanh Trang & Tui Do nhan vat tu bo nho game LibGDX.
     */
    public static void handleBagScan(long now) {
        if (!isAutoBagScanEnabled) {
            return;
        }

        if (!wasInGame || !isPlayerInGame()) {
            return;
        }

        // Quet moi 4 giay mot lan de giam tai CPU
        if (now - lastBagScanTime < 4_000L) {
            return;
        }
        lastBagScanTime = now;

        try {
            com.a.c.c.t.GirLKun75nEkLlilLiLlILwHATDOYouWaNtherEHIhIHIHAhahAHoHoHoHEheHegiRlkun75 inv =
                    com.a.c.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75.GIRlkUn75nEkLLllLLLlLlwhATDoyOuWanTHEreHIHihihAHAhahoHOhohEHEhegirlKUN75;
            if (inv == null) {
                return;
            }

            lastBagGold = inv.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75;
            lastBagGem = inv.GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75;
            lastBagLocked = inv.GirLKun75nEkLlilLiLlILwHATDOYouWaNtherEHIhIHIHAhahAHoHoHoHEheHegiRlkun75;

            // 1. Quet Hanh Trang / Trang Bi Dang Mac (Equipped Items) tu Mang 1
            List<BagItem> equips = parseItemArray(inv.gIrlKuN75NEKIlILIIiLlLWHatDOYouWanthereHihIhiHaHahAhOhoHOhEHEHEGIRLkun75);
            lastScannedEquipItems.clear();
            lastScannedEquipItems.addAll(equips);
            lastScannedEquipCount = equips.size();

            // 2. Quet Tui Do (Inventory Bag Items):
            // Mang 7 (inv.GirlKun75NekIlliLiLIiiWhAtdOyOuwAnTHereHIhihiHahAHAHOHOHOhEHeHeGiRLKuN75) la kho luu tru chinh thuc cua Tui Do
            List<BagItem> bagList = new ArrayList<>();
            if (inv.GirlKun75NekIlliLiLIiiWhAtdOyOuwAnTHereHIhihiHahAHAHOHOHOhEHeHeGiRLKuN75 != null &&
                !inv.GirlKun75NekIlliLiLIiiWhAtdOyOuwAnTHereHIhihiHahAHAHOHOHOhEHeHeGiRLKuN75.isEmpty()) {
                bagList.addAll(parseItemArray(inv.GirlKun75NekIlliLiLIiiWhAtdOyOuwAnTHereHIhihiHahAHAHOHOHOhEHeHeGiRLKuN75));
            } else if (inv.gIRLkUn75NEkLlLillLiLiwhatDOyouWanthERehihihIHAHAhAhOhOHoheHEHEgirLkuN75 != null &&
                !inv.gIRLkUn75NEkLlLillLiLiwhatDOyouWanthERehihihIHAHAhAhOhOHoheHEHEgirLkuN75.isEmpty()) {
                bagList.addAll(parseItemArray(inv.gIRLkUn75NEkLlLillLiLiwhatDOyouWanthERehihihIHAHAhAhOhOHoheHEHEgirLkuN75));
            }

            // 3. Quet Ruong Do / Kho Do (Storage Box Items) tu Mang 8
            List<BagItem> boxList = new ArrayList<>();
            if (inv.girLkUN75nEKIlILlLlLIlWhATdOYOUwanThErEhIHihiHaHAHahOHoHoHehehegirLkUN75 != null &&
                !inv.girLkUN75nEKIlILlLlLIlWhATdOYOUwanThErEhIHihiHaHAHahOHoHoHehehegirLkUN75.isEmpty()) {
                boxList.addAll(parseItemArray(inv.girLkUN75nEKIlILlLlLIlWhATdOYOUwanThErEhIHihiHaHAHahOHoHoHehehegirLkUN75));
            }
            lastScannedBoxItems.clear();
            lastScannedBoxItems.addAll(boxList);
            lastScannedBoxCount = boxList.size();

            long totalQty = 0L;
            int duiGa = 0;
            for (BagItem it : bagList) {
                totalQty += it.qty;
                String lower = it.name.toLowerCase(Locale.ROOT);
                if (lower.contains("dui ga") || lower.contains("đùi gà") || lower.contains("duiga")) {
                    duiGa += (int) Math.min(it.qty, (long) Integer.MAX_VALUE);
                }
            }

            int prevCount = lastScannedBagCount;
            long prevTotalQty = lastScannedBagTotalQty;

            lastScannedBagItems.clear();
            lastScannedBagItems.addAll(bagList);
            lastScannedBagCount = bagList.size();
            lastScannedBagTotalQty = totalQty;
            lastDuiGaCount = duiGa;

            // Log ngay lap tuc neu so luong item hoac tong so mon thay doi (nhat duoc do, an do)
            if (prevCount != lastScannedBagCount || prevTotalQty != lastScannedBagTotalQty) {
                log(String.format(Locale.ROOT,
                        "[QuetTuiDo] >>> CAP NHAT TUI DO: %d o vat pham (Tong: %d mon, Vang: %d, Ngoc: %d, Dui ga: %d) <<<",
                        lastScannedBagCount, lastScannedBagTotalQty, lastBagGold, lastBagGem, lastDuiGaCount));
            }

            // Log dinh ky moi 30 giay trong Loop Bo Sung
            if (now - lastBagScanLogTime > 30_000L) {
                lastBagScanLogTime = now;
                log(String.format(Locale.ROOT,
                        "[QuetTuiDo] %s", getBagSummary()));
            }

            // Feature 17: Tu dong su dung vat pham 'Nam huong' trong tui do neu co
            handleAutoUseMushroom(now);
        } catch (Throwable t) {
            log("[QuetTuiDo] Ngoai le khi quet tui do: " + t.getMessage());
        }
    }

    // =========================================================================
    // Feature 17: Loop Bo Sung: Tu Dong Dung Vat Pham 'Nam Huong' Trong Tui Do
    // =========================================================================
    public static boolean isAutoUseMushroomEnabled() {
        return isAutoUseMushroomEnabled;
    }

    public static void setAutoUseMushroomEnabled(boolean enabled) {
        isAutoUseMushroomEnabled = enabled;
    }

    public static long getMushroomUseIntervalMs() {
        return mushroomUseIntervalMs;
    }

    public static void setMushroomUseIntervalMs(long intervalMs) {
        mushroomUseIntervalMs = intervalMs;
    }

    public static int getMushroomCountInBag() {
        return lastMushroomCountInBag;
    }

    /**
     * Ham tu dong dung vat pham 'Nam huong' trong tui do theo chu ky dinh san.
     * Quy trinh: Quet tui -> Tim item Nam huong -> Kiem tra so luong > 0 -> Gui packet su dung len server.
     */
    public static String handleAutoUseMushroom(long now) {
        if (!isAutoUseMushroomEnabled) {
            return "Tu dong dung Nam huong dang TAT.";
        }
        if (!wasInGame || !isPlayerInGame()) {
            return "Chua vao game de dung Nam huong.";
        }

        // 1. Quet tim vat pham 'Nam huong' trong tui do
        BagItem mushroomItem = null;
        int totalMushroom = 0;
        for (BagItem it : lastScannedBagItems) {
            if (it != null && isMushroomName(it.name)) {
                mushroomItem = it;
                totalMushroom += (int) Math.min(it.qty, (long) Integer.MAX_VALUE);
            }
        }

        lastMushroomCountInBag = totalMushroom;

        if (mushroomItem == null || totalMushroom <= 0) {
            lastMushroomUseResult = "Tui do khong co vat pham Nam huong nao (SL: 0).";
            return lastMushroomUseResult;
        }

        // 2. Kiem tra chu ky su dung (30s test mode hoac 30 phut production mode)
        long elapsed = now - lastMushroomUseTime;
        if (lastMushroomUseTime != 0L && elapsed < mushroomUseIntervalMs) {
            long remainSec = Math.max(1L, (mushroomUseIntervalMs - elapsed) / 1000L);
            return String.format(Locale.ROOT,
                    "Nam huong co trong tui: %d cai. Dang cho hoi chu ky su dung (con %ds / %ds).",
                    totalMushroom, remainSec, mushroomUseIntervalMs / 1000L);
        }

        // 3. Co vat pham Nam huong -> Thuc hien su dung qua Game Client
        final int targetId = mushroomItem.id;
        final String targetName = mushroomItem.name;
        final int curQty = totalMushroom;

        Gdx.app.postRunnable(() -> {
            try {
                com.a.d.a.gIRLkuN75nEKliLILiiLiiWhAtDOYOUwAnTherehiHihIHAHAhaHOhohohEheHEgIRlKUN75 client =
                        com.a.d.a.gIRLkuN75nEKliLILiiLiiWhAtDOYOUwAnTherehiHihIHAHAhaHOhohohEheHEgIRlKUN75.GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75();
                if (client != null) {
                    client.GIRlkUn75nEKiLiLLliLiLWhATdOyouwanThEREHiHIHIhAhahahohoHOHehEhEgiRlKuN75(targetId);
                    log(String.format(Locale.ROOT,
                            "[DungNamHuong] >>> DA GUI PACKET SU DUNG [%s - ID: %d] (So luong con: %d) LEN GAME SERVER! Chu ky tiep theo: %ds <<<",
                            targetName, targetId, curQty, mushroomUseIntervalMs / 1000L));
                }
            } catch (Throwable t) {
                log("[DungNamHuong] Loi khi gui goi tin dung vat pham: " + t.getMessage());
            }
        });

        lastMushroomUseTime = now;
        lastMushroomUseResult = String.format(Locale.ROOT,
                "Da gui lenh su dung Nam huong (ID: %d, SL: %d). Chu ky: %ds.",
                targetId, curQty, mushroomUseIntervalMs / 1000L);
        return lastMushroomUseResult;
    }

    public static boolean isPlayerInGame() {
        return wasInGame && (getCurrentMapId() >= 0 || !getCurrentMapName().isEmpty());
    }
}
