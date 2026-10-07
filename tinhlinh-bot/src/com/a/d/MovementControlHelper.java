package com.a.d;

import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.math.Vector2;
import com.badlogic.gdx.physics.box2d.Body;
import java.lang.reflect.Method;

public class MovementControlHelper {
    public static final int MOVE_NORMAL = 0;
    public static final int MOVE_JUMP = 1;
    public static final int MOVE_PHASE_STEP = 2;
    public static final int MOVE_PORTAL = 3;
    public static final int MOVE_STOP = 4;

    public static volatile long externalControlUntilMs = 0L;
    private static Method logMethod = null;

    public static void log(String msg) {
        try {
            if (logMethod == null) {
                logMethod = AutoReconnect.class.getDeclaredMethod("log", new Class[]{String.class});
                logMethod.setAccessible(true);
            }
            logMethod.invoke(null, new Object[]{msg});
        } catch (Throwable t) {
            System.out.println(msg);
        }
    }

    public static boolean isExternalMovementControlActive() {
        int mode = AutoReconnect.movementMode;
        if (mode == MOVE_JUMP || mode == MOVE_PHASE_STEP) {
            long now = System.currentTimeMillis();
            if (now < externalControlUntilMs) {
                return true;
            }
            AutoReconnect.movementMode = MOVE_NORMAL;
        }
        return false;
    }

    public static long newMovementCommand(int mode) {
        if (mode == MOVE_NORMAL) {
            if (isExternalMovementControlActive()) {
                // External control (Jump / Phase Step) dang giu quyen, khong cho phep normal command ghi de
                return AutoReconnect.movementCommandId.get();
            }
        }
        if (mode == MOVE_JUMP) {
            externalControlUntilMs = System.currentTimeMillis() + 650L;
        } else if (mode == MOVE_PHASE_STEP) {
            externalControlUntilMs = System.currentTimeMillis() + 900L;
        }
        AutoReconnect.movementMode = mode;
        return AutoReconnect.movementCommandId.incrementAndGet();
    }

    public static boolean isMovementCommandValid(long commandId, int mode) {
        return AutoReconnect.movementCommandId.get() == commandId && AutoReconnect.movementMode == mode;
    }

    public static void scheduleJumpSample(final long cmdId, final Object playerObj) {
        Thread t = new Thread(new Runnable() {
            public void run() {
                try {
                    Thread.sleep(650L);
                } catch (InterruptedException ignored) {}

                if (AutoReconnect.movementCommandId.get() != cmdId) {
                    return;
                }

                Gdx.app.postRunnable(new Runnable() {
                    public void run() {
                        try {
                            if (AutoReconnect.movementCommandId.get() != cmdId) {
                                return;
                            }
                            Body b = AutoReconnect.getPlayerBody(playerObj);
                            if (b != null) {
                                Vector2 pos = b.getPosition();
                                Vector2 vel = b.getLinearVelocity();
                                log("[MoveDebug] JUMP_SAMPLE cmdId=" + cmdId 
                                    + " pos=(" + String.format("%.2f,%.2f", new Object[]{Float.valueOf(pos.x), Float.valueOf(pos.y)}) 
                                    + ") vel=(" + String.format("%.2f,%.2f", new Object[]{Float.valueOf(vel.x), Float.valueOf(vel.y)}) 
                                    + ") -> End Jump Control Window (650ms), Return Navigator");
                            }
                        } catch (Throwable t) {
                            log("[MoveDebug] JUMP_SAMPLE error: " + t.getMessage());
                        } finally {
                            if (AutoReconnect.movementCommandId.get() == cmdId) {
                                AutoReconnect.movementMode = MOVE_NORMAL;
                            }
                        }
                    }
                });
            }
        }, "Jump-Sample-Thread");
        t.setDaemon(true);
        t.start();
    }

    public static void schedulePhaseStepSample(final long cmdId, final Object playerObj) {
        Thread t = new Thread(new Runnable() {
            public void run() {
                try {
                    Thread.sleep(900L);
                } catch (InterruptedException ignored) {}

                if (AutoReconnect.movementCommandId.get() != cmdId) {
                    return;
                }

                Gdx.app.postRunnable(new Runnable() {
                    public void run() {
                        try {
                            if (AutoReconnect.movementCommandId.get() != cmdId) {
                                return;
                            }
                            Body b = AutoReconnect.getPlayerBody(playerObj);
                            if (b != null) {
                                Vector2 pos = b.getPosition();
                                Vector2 vel = b.getLinearVelocity();
                                log("[MoveDebug] PHASE_STEP_SAMPLE cmdId=" + cmdId 
                                    + " pos=(" + String.format("%.2f,%.2f", new Object[]{Float.valueOf(pos.x), Float.valueOf(pos.y)}) 
                                    + ") vel=(" + String.format("%.2f,%.2f", new Object[]{Float.valueOf(vel.x), Float.valueOf(vel.y)}) 
                                    + ") -> End Phase Step Control Window (900ms), Return Navigator");
                            }
                        } catch (Throwable t) {
                            log("[MoveDebug] PHASE_STEP_SAMPLE error: " + t.getMessage());
                        } finally {
                            if (AutoReconnect.movementCommandId.get() == cmdId) {
                                AutoReconnect.movementMode = MOVE_NORMAL;
                            }
                        }
                    }
                });
            }
        }, "PhaseStep-Sample-Thread");
        t.setDaemon(true);
        t.start();
    }
}
