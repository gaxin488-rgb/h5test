@echo off
setlocal
title TinhLinh CPU-only 260x160

if not exist "%~dp0TinhLinh-CPU-Only-260x160.jar" (
    echo [STOP] CPU-only JAR not found:
    echo %~dp0TinhLinh-CPU-Only-260x160.jar
    exit /b 2
)

set "LIBGL_ALWAYS_SOFTWARE=1"
set "MESA_LOADER_DRIVER_OVERRIDE=llvmpipe"
set "GALLIUM_DRIVER=llvmpipe"
cd /d "%~dp0"
echo [INFO] Starting CPU-only profile at 15 FPS...
java -Xms16m -Xmx64m -Xss256k -XX:+UseSerialGC -XX:ActiveProcessorCount=1 -XX:MaxMetaspaceSize=48m -XX:ReservedCodeCacheSize=16m -XX:MaxDirectMemorySize=32m -Dfile.encoding=UTF-8 -Dorg.lwjgl.opengl.libname=opengl32 -Dorg.lwjgl.glfw.libname=glfw -jar "%~dp0TinhLinh-CPU-Only-260x160.jar"
set "EXIT_CODE=%ERRORLEVEL%"
echo [INFO] JAR exited with code %EXIT_CODE%.
endlocal & exit /b %EXIT_CODE%
