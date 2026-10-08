import jdk.internal.org.objectweb.asm.ClassReader;
import jdk.internal.org.objectweb.asm.ClassWriter;
import jdk.internal.org.objectweb.asm.commons.ClassRemapper;
import jdk.internal.org.objectweb.asm.commons.Remapper;

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Enumeration;
import java.util.HashSet;
import java.util.Set;
import java.util.jar.JarEntry;
import java.util.jar.JarFile;
import java.util.jar.JarOutputStream;

public final class RenameAutoReconnect {
    private static final String OLD_OWNER = "com/a/d/AutoReconnect";
    private static final String NEW_OWNER = "com/a/d/AutoReconnectBase";

    private RenameAutoReconnect() {
    }

    public static void main(String[] args) throws Exception {
        if (args.length != 2) {
            throw new IllegalArgumentException("Usage: RenameAutoReconnect <input.jar> <output.jar>");
        }
        Path input = Paths.get(args[0]);
        Path output = Paths.get(args[1]);
        Files.deleteIfExists(output);
        Set<String> emitted = new HashSet<String>();
        try (JarFile source = new JarFile(input.toFile());
             OutputStream fileOut = new FileOutputStream(output.toFile());
             JarOutputStream target = new JarOutputStream(fileOut)) {
            Enumeration<JarEntry> entries = source.entries();
            while (entries.hasMoreElements()) {
                JarEntry entry = entries.nextElement();
                String targetName = renameEntry(entry.getName());
                if (!emitted.add(targetName)) {
                    continue;
                }
                byte[] bytes;
                try (InputStream in = source.getInputStream(entry)) {
                    bytes = in.readAllBytes();
                }
                if (entry.getName().startsWith(OLD_OWNER) && entry.getName().endsWith(".class")) {
                    bytes = remapClass(bytes);
                }
                JarEntry replacement = new JarEntry(targetName);
                replacement.setTime(entry.getTime());
                target.putNextEntry(replacement);
                target.write(bytes);
                target.closeEntry();
            }
        }
        System.out.println("Renamed AutoReconnect bytecode to AutoReconnectBase.");
    }

    private static String renameEntry(String name) {
        if (name.startsWith(OLD_OWNER) && name.endsWith(".class")) {
            return NEW_OWNER + name.substring(OLD_OWNER.length());
        }
        return name;
    }

    private static byte[] remapClass(byte[] bytes) {
        ClassReader reader = new ClassReader(bytes);
        ClassWriter writer = new ClassWriter(reader, 0);
        ClassRemapper remapper = new ClassRemapper(writer, new Remapper() {
            @Override
            public String map(String internalName) {
                if (internalName != null && (internalName.equals(OLD_OWNER) || internalName.startsWith(OLD_OWNER + "$"))) {
                    return NEW_OWNER + internalName.substring(OLD_OWNER.length());
                }
                return internalName;
            }
        });
        reader.accept(remapper, 0);
        return writer.toByteArray();
    }
}
