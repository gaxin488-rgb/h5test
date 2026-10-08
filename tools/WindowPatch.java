import java.io.InputStream;
import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Enumeration;
import java.util.jar.JarEntry;
import java.util.jar.JarFile;
import java.util.jar.JarOutputStream;
import java.util.jar.Manifest;

import jdk.internal.org.objectweb.asm.ClassReader;
import jdk.internal.org.objectweb.asm.ClassVisitor;
import jdk.internal.org.objectweb.asm.ClassWriter;
import jdk.internal.org.objectweb.asm.MethodVisitor;
import jdk.internal.org.objectweb.asm.Opcodes;

public final class WindowPatch {
    private static final String GAME_ENTRY =
            "com/a/c/GIRLKUn75NEkLIilIiLLLLwHaTdOyOuWAntHERehiHiHIHAHAhAHohohoheheHegirlkUN75.class";
    private static final String LAUNCHER_ENTRY = "com/girlkun/DesktopLauncher.class";
    private static final String GRAPHICS_OWNER = "com/badlogic/gdx/Graphics";
    private static final String WINDOW_CONFIGURATION_OWNER =
            "com/badlogic/gdx/backends/lwjgl3/Lwjgl3WindowConfiguration";
    private static final String APPLICATION_CONFIGURATION_OWNER =
            "com/badlogic/gdx/backends/lwjgl3/Lwjgl3ApplicationConfiguration";
    private static final String APPLICATION_OWNER =
            "com/badlogic/gdx/backends/lwjgl3/Lwjgl3Application";
    private static final String GL_PROFILER_OWNER =
            "com/badlogic/gdx/graphics/profiling/GLProfiler";

    private static final class PatchResult {
        private final byte[] bytes;
        private final int windowedCalls;
        private final int fullscreenCalls;

        private PatchResult(byte[] bytes, int windowedCalls, int fullscreenCalls) {
            this.bytes = bytes;
            this.windowedCalls = windowedCalls;
            this.fullscreenCalls = fullscreenCalls;
        }
    }

    private static PatchResult patchGame(byte[] original, final int width, final int height) {
        final int[] windowedCalls = {0};
        final int[] fullscreenCalls = {0};
        ClassReader reader = new ClassReader(original);
        ClassWriter writer = new ClassWriter(reader, ClassWriter.COMPUTE_MAXS);
        ClassVisitor visitor = new ClassVisitor(Opcodes.ASM8, writer) {
            @Override
            public MethodVisitor visitMethod(int access, String name, String descriptor,
                                              String signature, String[] exceptions) {
                MethodVisitor next = super.visitMethod(access, name, descriptor, signature, exceptions);
                return new MethodVisitor(Opcodes.ASM8, next) {
                    @Override
                    public void visitMethodInsn(int opcode, String owner, String methodName,
                                                String methodDescriptor, boolean isInterface) {
                        if (opcode == Opcodes.INVOKEINTERFACE
                                && GRAPHICS_OWNER.equals(owner)
                                && "setWindowedMode".equals(methodName)
                                && "(II)Z".equals(methodDescriptor)) {
                            super.visitInsn(Opcodes.POP2);
                            super.visitIntInsn(Opcodes.SIPUSH, width);
                            super.visitIntInsn(Opcodes.SIPUSH, height);
                            windowedCalls[0]++;
                            super.visitMethodInsn(opcode, owner, methodName, methodDescriptor, isInterface);
                            return;
                        }
                        if (opcode == Opcodes.INVOKEINTERFACE
                                && GRAPHICS_OWNER.equals(owner)
                                && "setFullscreenMode".equals(methodName)
                                && "(Lcom/badlogic/gdx/Graphics$DisplayMode;)Z".equals(methodDescriptor)) {
                            super.visitInsn(Opcodes.POP2);
                            super.visitInsn(Opcodes.ICONST_1);
                            fullscreenCalls[0]++;
                            return;
                        }
                        if (opcode == Opcodes.INVOKEINTERFACE
                                && GRAPHICS_OWNER.equals(owner)
                                && "setVSync".equals(methodName)
                                && "(Z)V".equals(methodDescriptor)) {
                            // Disable the game's later VSync request so the 15 FPS cap is effective.
                            super.visitInsn(Opcodes.POP);
                            super.visitInsn(Opcodes.ICONST_0);
                            super.visitMethodInsn(opcode, owner, methodName, methodDescriptor, isInterface);
                            return;
                        }
                        if (GL_PROFILER_OWNER.equals(owner)
                                && ("enable".equals(methodName) || "reset".equals(methodName))
                                && "()V".equals(methodDescriptor)) {
                            super.visitInsn(Opcodes.POP);
                            return;
                        }
                        super.visitMethodInsn(opcode, owner, methodName, methodDescriptor, isInterface);
                    }

                };
            }
        };
        reader.accept(visitor, 0);
        return new PatchResult(writer.toByteArray(), windowedCalls[0], fullscreenCalls[0]);
    }

    private static byte[] patchLauncher(byte[] original, final int[] windowedCalls,
                                        final int width, final int height) {
        ClassReader reader = new ClassReader(original);
        ClassWriter writer = new ClassWriter(reader, ClassWriter.COMPUTE_MAXS);
        ClassVisitor visitor = new ClassVisitor(Opcodes.ASM8, writer) {
            @Override
            public MethodVisitor visitMethod(int access, String name, String descriptor,
                                              String signature, String[] exceptions) {
                MethodVisitor next = super.visitMethod(access, name, descriptor, signature, exceptions);
                return new MethodVisitor(Opcodes.ASM8, next) {
                    @Override
                    public void visitCode() {
                        super.visitCode();
                        if (!"main".equals(name) || !"([Ljava/lang/String;)V".equals(descriptor)) {
                            return;
                        }
                        setSystemProperty("org.lwjgl.opengl.libname", "opengl32");
                        setSystemProperty("org.lwjgl.glfw.libname", "glfw");
                        setSystemProperty("sun.java2d.opengl", "false");
                        setSystemProperty("sun.java2d.d3d", "false");
                        setSystemProperty("sun.java2d.noddraw", "true");
                    }

                    private void setSystemProperty(String key, String value) {
                        super.visitLdcInsn(key);
                        super.visitLdcInsn(value);
                        super.visitMethodInsn(Opcodes.INVOKESTATIC, "java/lang/System", "setProperty",
                                "(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;", false);
                        super.visitInsn(Opcodes.POP);
                    }

                    @Override
                    public void visitIntInsn(int opcode, int operand) {
                        if ("main".equals(name) && "([Ljava/lang/String;)V".equals(descriptor)
                                && (opcode == Opcodes.BIPUSH || opcode == Opcodes.SIPUSH) && operand == 120) {
                            super.visitIntInsn(opcode, 15);
                            return;
                        }
                        super.visitIntInsn(opcode, operand);
                    }

                    @Override
                    public void visitMethodInsn(int opcode, String owner, String methodName,
                                                String methodDescriptor, boolean isInterface) {
                        if (APPLICATION_CONFIGURATION_OWNER.equals(owner)
                                && "<init>".equals(methodName)
                                && "()V".equals(methodDescriptor)) {
                            super.visitMethodInsn(opcode, owner, methodName, methodDescriptor, isInterface);
                            super.visitInsn(Opcodes.DUP);
                            super.visitInsn(Opcodes.ICONST_1);
                            super.visitMethodInsn(Opcodes.INVOKEVIRTUAL, APPLICATION_CONFIGURATION_OWNER,
                                    "disableAudio", "(Z)V", false);
                            super.visitInsn(Opcodes.DUP);
                            super.visitInsn(Opcodes.ICONST_1);
                            super.visitMethodInsn(Opcodes.INVOKEVIRTUAL, APPLICATION_CONFIGURATION_OWNER,
                                    "setMaxNetThreads", "(I)V", false);
                            return;
                        }
                        if ((WINDOW_CONFIGURATION_OWNER.equals(owner)
                                || APPLICATION_CONFIGURATION_OWNER.equals(owner))
                                && "setWindowedMode".equals(methodName)
                                && "(II)V".equals(methodDescriptor)) {
                            super.visitInsn(Opcodes.POP2);
                            super.visitIntInsn(Opcodes.SIPUSH, width);
                            super.visitIntInsn(Opcodes.SIPUSH, height);
                            windowedCalls[0]++;
                        }
                        super.visitMethodInsn(opcode, owner, methodName, methodDescriptor, isInterface);
                        if (APPLICATION_OWNER.equals(owner)
                                && "<init>".equals(methodName)
                                && "(Lcom/badlogic/gdx/ApplicationListener;Lcom/badlogic/gdx/backends/lwjgl3/Lwjgl3ApplicationConfiguration;)V"
                                .equals(methodDescriptor)) {
                            super.visitMethodInsn(Opcodes.INVOKESTATIC, "com/a/d/AutoReconnect",
                                    "startWatcher", "()V", false);
                        }
                    }

                };
            }
        };
        reader.accept(visitor, 0);
        return writer.toByteArray();
    }

    public static void main(String[] args) throws Exception {
        if (args.length != 4) {
            throw new IllegalArgumentException("Usage: WindowPatch <input.jar> <output.jar> <width> <height>");
        }

        Path input = Paths.get(args[0]);
        Path output = Paths.get(args[1]);
        int width = Integer.parseInt(args[2]);
        int height = Integer.parseInt(args[3]);
        if (width <= 0 || height <= 0 || width > 4096 || height > 4096) {
            throw new IllegalArgumentException("Window dimensions must be between 1 and 4096 pixels");
        }
        Files.deleteIfExists(output);

        int windowedCalls = 0;
        int fullscreenCalls = 0;
        int[] launcherWindowedCalls = {0};
        try (JarFile source = new JarFile(input.toFile())) {
            Manifest manifest = source.getManifest();
            try (OutputStream fileOut = Files.newOutputStream(output);
                 JarOutputStream target = manifest == null
                         ? new JarOutputStream(fileOut)
                         : new JarOutputStream(fileOut, manifest)) {
                Enumeration<JarEntry> entries = source.entries();
                while (entries.hasMoreElements()) {
                    JarEntry entry = entries.nextElement();
                    if (manifest != null && "META-INF/MANIFEST.MF".equalsIgnoreCase(entry.getName())) {
                        continue;
                    }
                    byte[] bytes;
                    if (GAME_ENTRY.equals(entry.getName())) {
                        try (InputStream in = source.getInputStream(entry)) {
                            PatchResult result = patchGame(in.readAllBytes(), width, height);
                            bytes = result.bytes;
                            windowedCalls = result.windowedCalls;
                            fullscreenCalls = result.fullscreenCalls;
                        }
                    } else if (LAUNCHER_ENTRY.equals(entry.getName())) {
                        try (InputStream in = source.getInputStream(entry)) {
                            bytes = patchLauncher(in.readAllBytes(), launcherWindowedCalls, width, height);
                        }
                    } else {
                        try (InputStream in = source.getInputStream(entry)) {
                            bytes = in.readAllBytes();
                        }
                    }
                    JarEntry replacement = new JarEntry(entry.getName());
                    replacement.setTime(entry.getTime());
                    target.putNextEntry(replacement);
                    target.write(bytes);
                    target.closeEntry();
                }
            }
        }

        if (windowedCalls == 0 || fullscreenCalls == 0 || launcherWindowedCalls[0] == 0) {
            Files.deleteIfExists(output);
            throw new IllegalStateException("Window patch incomplete: launcherSetWindowedMode="
                    + launcherWindowedCalls[0] + ", gameSetWindowedMode=" + windowedCalls
                    + ", gameSetFullscreenMode=" + fullscreenCalls);
        }
        System.out.println("Window size: " + width + "x" + height);
        System.out.println("Patched launcher setWindowedMode calls: " + launcherWindowedCalls[0]);
        System.out.println("Patched setWindowedMode calls: " + windowedCalls);
        System.out.println("Blocked setFullscreenMode calls: " + fullscreenCalls);
        System.out.println("Output: " + output.toAbsolutePath());
    }
}
