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
        return mode == MOVE_JUMP || mode == MOVE_PHASE_STEP;
    }

    public static long newMovementCommand(int mode) {
        if (mode == MOVE_NORMAL) {
            if (isExternalMovementControlActive()) {
                // External control (Jump / Phase Step) dang giu quyen, khong cho phep normal command ghi de
                return AutoReconnect.movementCommandId.get();
            }
        }
        AutoReconnect.movementMode = mode;
        return AutoReconnect.movementCommandId.incrementAndGet();
    }

    public static boolean isMovementCommandValid(long commandId, int mode) {
        return AutoReconnect.movementCommandId.get() == commandId && AutoReconnect.movementMode == mode;
    }

    public static void logMovementSources(Object playerObj) {
        if (playerObj == null) {
            log("[MoveSync] player=null");
            return;
        }
        try {
            Method getPosMethod = playerObj.getClass().getMethod("gIRLkuN75nEKliLILiiLiiWhAtDOYOUwAnTherehiHihIHAHAhaHOhohohEheHEgIRlKUN75");
            Vector2 logical = (Vector2) getPosMethod.invoke(playerObj);
            Body body = AutoReconnect.getPlayerBody(playerObj);
            Vector2 bodyPos = body != null ? body.getPosition() : null;
            Vector2 bodyVel = body != null ? body.getLinearVelocity() : null;
            log("[MoveSync] logical=(" 
                + (logical != null ? String.format("%.2f,%.2f", Float.valueOf(logical.x), Float.valueOf(logical.y)) : "NaN,NaN") 
                + ") body=(" 
                + (bodyPos != null ? String.format("%.2f,%.2f", Float.valueOf(bodyPos.x), Float.valueOf(bodyPos.y)) : "NaN,NaN") 
                + ") vel=(" 
                + (bodyVel != null ? String.format("%.2f,%.2f", Float.valueOf(bodyVel.x), Float.valueOf(bodyVel.y)) : "NaN,NaN") 
                + ")");
        } catch (Throwable t) {
            log("[MoveSync] ERROR: " + t.getMessage());
        }
    }

    public static void sendMovementState(boolean isMoving) {
        try {
            Class<?> netClientClass = Class.forName("com.a.d.a.gIRLkuN75nEKliLILiiLiiWhAtDOYOUwAnTherehiHihIHAHAhaHOhohohEheHEgIRlKUN75");
            Method getNetClient = netClientClass.getDeclaredMethod("GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75", new Class[0]);
            Object netClient = getNetClient.invoke(null, new Object[0]);
            if (netClient != null) {
                Method sendMoveMethod = netClientClass.getDeclaredMethod("gIrlKuN75NEKIlILIIiLlLWHatDOYouWanthereHihIhiHaHahAhOhoHOhEHEHEGIRLkun75", new Class[]{boolean.class});
                sendMoveMethod.setAccessible(true);
                sendMoveMethod.invoke(netClient, new Object[]{Boolean.valueOf(isMoving)});
            }
        } catch (Throwable t) {
            log("[MoveDebug] sendMovementState error: " + t.getMessage());
        }
    }

    public static void syncPlayerPositionAndPacket(Object playerObj, Vector2 pos, boolean isMoving) {
        if (playerObj == null || pos == null) return;
        try {
            // 1. Update Player internal position Vector2 & transform
            Method setPosMethod = null;
            Class<?> pClass = playerObj.getClass();
            while (pClass != null && setPosMethod == null) {
                try {
                    setPosMethod = pClass.getDeclaredMethod("GirlkUn75NeKiiILIiiiILwHaTDoYOuwAntHErEHIHIhIHAhAhAHohOhOHeHEHeGiRLkUN75", new Class[]{float.class, float.class});
                } catch (NoSuchMethodException e) {
                    pClass = pClass.getSuperclass();
                }
            }
            if (setPosMethod != null) {
                setPosMethod.setAccessible(true);
                setPosMethod.invoke(playerObj, new Object[]{Float.valueOf(pos.x), Float.valueOf(pos.y)});
            }

            // Direct in-place update of Player internal Vector2
            try {
                Method getPosMethod = playerObj.getClass().getMethod("gIRLkuN75nEKliLILiiLiiWhAtDOYOUwAnTherehiHihIHAHAhaHOhohohEheHEgIRlKUN75");
                Vector2 pVec = (Vector2) getPosMethod.invoke(playerObj);
                if (pVec != null) {
                    pVec.set(pos.x, pos.y);
                }
            } catch (Throwable ignored) {}

            // 2. Sync to Server via NetworkClient
            Class<?> netClientClass = Class.forName("com.a.d.a.gIRLkuN75nEKliLILiiLiiWhAtDOYOUwAnTherehiHihIHAHAhaHOhohohEheHEgIRlKUN75");
            Method getNetClient = netClientClass.getDeclaredMethod("GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75", new Class[0]);
            Object netClient = getNetClient.invoke(null, new Object[0]);
            if (netClient != null) {
                Method sendPosMethod = netClientClass.getDeclaredMethod("GIrlKUn75NEKLiIILilLiLwhAtdOYOuWAntheRehIHIHihAHAHAHohohohEHeHEgiRlkUn75", new Class[]{float.class, float.class});
                sendPosMethod.setAccessible(true);
                sendPosMethod.invoke(netClient, new Object[]{Float.valueOf(pos.x), Float.valueOf(pos.y)});

                Method sendMoveMethod = netClientClass.getDeclaredMethod("gIrlKuN75NEKIlILIIiLlLWHatDOYouWanthereHihIhiHaHahAhOhoHOhEHEHEGIRLkun75", new Class[]{boolean.class});
                sendMoveMethod.setAccessible(true);
                sendMoveMethod.invoke(netClient, new Object[]{Boolean.valueOf(isMoving)});
            }
        } catch (Throwable t) {
            log("[MoveDebug] syncPlayerPositionAndPacket error: " + t.getMessage());
        }
    }

    public static void scheduleJumpSample(final long cmdId, final Object playerObj) {
        Thread t = new Thread(new Runnable() {
            public void run() {
                try {
                    Thread.sleep(250L);
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
                                syncPlayerPositionAndPacket(playerObj, new Vector2(pos), false);

                                Vector2 verify = null;
                                try {
                                    Method getPosMethod = playerObj.getClass().getMethod("gIRLkuN75nEKliLILiiLiiWhAtDOYOUwAnTherehiHihIHAHAhaHOhohohEheHEgIRlKUN75");
                                    Object verifyObj = getPosMethod.invoke(playerObj);
                                    if (verifyObj instanceof Vector2) {
                                        verify = (Vector2) verifyObj;
                                    }
                                } catch (Throwable ignored) {}

                                log("[MoveSync] AFTER_SYNC body=(" + String.format("%.2f,%.2f", Float.valueOf(pos.x), Float.valueOf(pos.y)) + ") "
                                    + "logical=(" + (verify != null ? String.format("%.2f,%.2f", Float.valueOf(verify.x), Float.valueOf(verify.y)) : "NaN,NaN") + ")");

                                log("[MoveDebug] JUMP_SAMPLE cmdId=" + cmdId 
                                    + " pos=(" + String.format("%.2f,%.2f", new Object[]{Float.valueOf(pos.x), Float.valueOf(pos.y)}) 
                                    + ") vel=(" + String.format("%.2f,%.2f", new Object[]{Float.valueOf(vel.x), Float.valueOf(vel.y)}) 
                                    + ") -> Synced Player & Server Anchor (250ms), Return Navigator");
                            }
                        } catch (Throwable t) {
                            log("[MoveDebug] JUMP_SAMPLE error: " + t.getMessage());
                        } finally {
                            if (AutoReconnect.movementCommandId.get() == cmdId && AutoReconnect.movementMode == MOVE_JUMP) {
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
                    Thread.sleep(300L);
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
                                syncPlayerPositionAndPacket(playerObj, new Vector2(pos), false);

                                Vector2 verify = null;
                                try {
                                    Method getPosMethod = playerObj.getClass().getMethod("gIRLkuN75nEKliLILiiLiiWhAtDOYOUwAnTherehiHihIHAHAhaHOhohohEheHEgIRlKUN75");
                                    Object verifyObj = getPosMethod.invoke(playerObj);
                                    if (verifyObj instanceof Vector2) {
                                        verify = (Vector2) verifyObj;
                                    }
                                } catch (Throwable ignored) {}

                                log("[MoveSync] AFTER_SYNC body=(" + String.format("%.2f,%.2f", Float.valueOf(pos.x), Float.valueOf(pos.y)) + ") "
                                    + "logical=(" + (verify != null ? String.format("%.2f,%.2f", Float.valueOf(verify.x), Float.valueOf(verify.y)) : "NaN,NaN") + ")");

                                log("[MoveDebug] PHASE_STEP_SAMPLE cmdId=" + cmdId 
                                    + " pos=(" + String.format("%.2f,%.2f", new Object[]{Float.valueOf(pos.x), Float.valueOf(pos.y)}) 
                                    + ") vel=(" + String.format("%.2f,%.2f", new Object[]{Float.valueOf(vel.x), Float.valueOf(vel.y)}) 
                                    + ") -> Synced Player & Server Anchor (300ms), Return Navigator");
                            }
                        } catch (Throwable t) {
                            log("[MoveDebug] PHASE_STEP_SAMPLE error: " + t.getMessage());
                        } finally {
                            if (AutoReconnect.movementCommandId.get() == cmdId && AutoReconnect.movementMode == MOVE_PHASE_STEP) {
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

    public static void logMovementSources(Object player) {
        try {
            if (player == null) {
                log("[MoveSync] player=null");
                return;
            }

            Vector2 logical = null;
            try {
                Method getPosMethod = player.getClass().getMethod("gIRLkuN75nEKliLILiiLiiWhAtDOYOUwAnTherehiHihIHAHAhaHOhohohEheHEgIRlKUN75");
                Object obj = getPosMethod.invoke(player);
                if (obj instanceof Vector2) {
                    logical = (Vector2) obj;
                }
            } catch (Throwable ignored) {}

            Body body = AutoReconnect.getPlayerBody(player);
            Vector2 bodyPos = body != null ? body.getPosition() : null;
            Vector2 bodyVel = body != null ? body.getLinearVelocity() : null;

            log(
                "[MoveSync] "
                + "logical=("
                + (logical != null ? String.format("%.2f,%.2f", Float.valueOf(logical.x), Float.valueOf(logical.y)) : "NaN,NaN")
                + ") "
                + "body=("
                + (bodyPos != null ? String.format("%.2f,%.2f", Float.valueOf(bodyPos.x), Float.valueOf(bodyPos.y)) : "NaN,NaN")
                + ") "
                + "vel=("
                + (bodyVel != null ? String.format("%.2f,%.2f", Float.valueOf(bodyVel.x), Float.valueOf(bodyVel.y)) : "NaN,NaN")
                + ")"
            );
        } catch (Throwable t) {
            log("[MoveSync] ERROR: " + t);
        }
    }
}
