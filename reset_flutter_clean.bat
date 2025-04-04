@echo off
echo === RESETTING FLUTTER PROJECT TO CLEAN STATE ===
echo This will clear all gradle caches and temporary files

echo Performing Flutter clean...
flutter clean

echo Removing Gradle directories...
rmdir /s /q "%USERPROFILE%\.gradle\wrapper\dists\gradle-8.13-all"
rmdir /s /q "%USERPROFILE%\.gradle\caches"
rmdir /s /q "%USERPROFILE%\.gradle\daemon"
rmdir /s /q "%USERPROFILE%\.gradle\native"

echo Cleaning project-level Gradle files...
rmdir /s /q "android\.gradle"
rmdir /s /q "android\app\build"
del "android\local.properties"

echo Removing temporary Flutter files...
rmdir /s /q ".dart_tool"
rmdir /s /q "build"
rmdir /s /q ".flutter-plugins"
rmdir /s /q ".flutter-plugins-dependencies"

echo Resetting custom Gradle properties...
if exist "%USERPROFILE%\.gradle\gradle.properties" del "%USERPROFILE%\.gradle\gradle.properties"

echo Restoring original Gradle wrapper...
flutter pub get

echo.
echo =============================================
echo PROJECT RESET COMPLETE
echo.
echo To start fresh:
echo 1. Close and reopen VS Code/Android Studio
echo 2. Run: flutter pub get
echo 3. Run: flutter run
echo =============================================

pause