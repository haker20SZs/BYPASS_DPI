@echo off

(
echo Set objShell = CreateObject^("Shell.Application"^)
echo Set WshShell = CreateObject^("WScript.Shell"^)
echo Set fso = CreateObject^("Scripting.FileSystemObject"^)
echo.
echo scriptPath = fso.GetParentFolderName^(WScript.ScriptFullName^)
echo.
echo exePath = """" ^& scriptPath ^& "\app\sing-box.exe"""
echo configPath = """" ^& scriptPath ^& "\list\config.json"""
echo arguments = "run -c " ^& configPath
echo.
echo objShell.ShellExecute exePath, arguments, "", "runas", 0
) > "tun-start.vbs"

chcp 65001 >nul
setlocal enabledelayedexpansion

:: Проверка прав администратора
if "%1"=="admin" (
    echo Running with admin rights
) else (
    echo Requesting admin rights...
    powershell -Command "Start-Process 'cmd.exe' -ArgumentList '/c \"\"%~f0\" admin\"' -Verb RunAs"
    exit /b
)

:menu
cls
echo ========================================
echo         Менеджер TunTun
echo ========================================
echo.
echo  1 - Проверить статус
echo  2 - Добавить в автозагрузку и запустить
echo  3 - Остановить и удалить из автозагрузки
echo  0 - Выход
echo.
echo ========================================
set /p choice="Выберите действие [0-5]: "

if "%choice%"=="1" goto check
if "%choice%"=="2" goto install
if "%choice%"=="3" goto remove_all
if "%choice%"=="0" exit
goto menu

:check
cls
echo ========================================
echo   Проверка автозагрузки TunTun
echo ========================================

echo Проверка записи в реестре...
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "TunStart" >nul 2>&1
if errorlevel 1 (
    echo [НЕТ] Не в автозагрузке
) else (
    echo [ДА] В автозагрузке
)

echo.
echo Проверка запущенных процессов...
tasklist | findstr /i "sing-box.exe" >nul 2>&1
if errorlevel 1 (
    echo [НЕТ] Процесс не запущен
) else (
    echo [ДА] Процесс запущен
)

echo.
pause
goto menu

:install
cls
echo ========================================
echo   Установка TunTun
echo ========================================

set "vbs_path=%~dp0tun-start.vbs"
if not exist "%vbs_path%" (
    echo ОШИБКА: Файл tun-start.vbs не найден!
    pause
    goto menu
)

echo Добавление в автозагрузку...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "TunStart" /t REG_SZ /d "wscript.exe \"%vbs_path%\"" /f

echo.
echo Запуск tun-start.vbs...
start "" wscript.exe "%vbs_path%"

echo.
echo Установка завершена!
pause
goto menu

:remove_all
cls
echo ========================================
echo   Полное удаление TunTun
echo ========================================

echo Остановка процесса...
taskkill /F /IM sing-box.exe >nul 2>&1
if errorlevel 1 (
    echo [ИНФО] Процесс не найден
) else (
    echo [OK] Процесс остановлен
)

echo.
echo Удаление из автозагрузки...
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "TunStart" /f >nul 2>&1
if errorlevel 1 (
    echo [ИНФО] Запись не найдена
) else (
    echo [OK] Удалено из автозагрузки
)

echo.
pause
goto menu