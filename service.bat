@echo off
setlocal EnableDelayedExpansion

set SRVCNAME=W-DPI
set BAT_NAME=general.bat

:: Проверка прав администратора
if "%1"=="admin" (
    echo Running with admin rights
) else (
    echo Requesting admin rights...
    powershell -Command "Start-Process 'cmd.exe' -ArgumentList '/c \"\"%~f0\" admin\"' -Verb RunAs"
    exit /b
)

:: Главное меню
:menu
cls
echo ========================
echo     SERVICE MANAGER
echo ========================
echo 1. Install Service (using %BAT_NAME%)
echo 2. Remove Services
echo 3. Check Status
echo 4. Start Service
echo 5. Stop Service
echo 6. Restart Service
echo 0. Exit
echo.

choice /c 1234560 /n /m "Enter choice: "

if %errorlevel% equ 1 goto service_install
if %errorlevel% equ 2 goto service_remove
if %errorlevel% equ 3 goto service_status
if %errorlevel% equ 4 goto service_start
if %errorlevel% equ 5 goto service_stop
if %errorlevel% equ 6 goto service_restart
if %errorlevel% equ 4 exit /b
goto menu

:: Установка службы с использованием general.bat
:service_install
cls

call :check_service_exist "%SRVCNAME%"
if !errorlevel! equ 0 (
    echo Service %SRVCNAME% already exists.
    pause    

    goto menu
    
    :: Получаем статус службы
    call :get_service_status "%SRVCNAME%"
    
    if "!service_status!"=="RUNNING" (
        echo Service is currently RUNNING.
        echo Stopping service...
        net stop %SRVCNAME% >nul 2>&1
        if !errorlevel! equ 0 (
            echo Service stopped successfully.
        ) else (
            echo Failed to stop service! Please stop it manually.
            pause
            goto menu
        )
    ) else (
        echo Service is currently STOPPED.
    )
    
    echo Removing existing service...
    sc delete %SRVCNAME% >nul 2>&1
    if !errorlevel! equ 0 (
        echo Service removed successfully.
    ) else (
        echo Failed to remove existing service!
        pause
        goto menu
    )
    echo.
) else (
    echo Service %SRVCNAME% not found, proceeding with installation.
)

set "selectedFile=%~dp0\%BAT_NAME%"

if not exist "%selectedFile%" (
    echo Error: %BAT_NAME% not found in current directory.
    pause
    goto menu
)

echo Using configuration: %selectedFile%
echo -----------------------------

:: Полный путь к исполняемому файлу
set "APP_PATH=%~dp0app\"
set "EXECUTABLE=\"%APP_PATH%winws.exe\""

:: Чтение и обработка параметров из general.bat
set "all_args="
set "in_params=0"
set "skip_next=0"

for /f "usebackq tokens=*" %%a in ("%selectedFile%") do (
    set "line=%%a"
    
    :: Пропуск пустых строк и комментариев
    if not "!line!"=="" if not "!line:~0,1!"=="@" (
        :: Пропуск строки с exit
        if /i "!line!"=="exit" (
            set "skip_next=1"
        ) else if !skip_next! equ 0 (
            :: Начинаем захват после winws.exe
            if "!line:winws.exe=!" neq "!line!" (
                set "in_params=1"
                :: Полностью удаляем путь до winws.exe
                set "line=!line:*winws.exe=!"
            )
            
            if !in_params! equ 1 (
                :: Удаление символа продолжения строки (^)
                set "line=!line:^=!"
                :: Удаление кавычек
                set "line=!line:"=!"
                :: Замена плейсхолдеров на реальные пути
                set "line=!line:%%DIR%%=%~dp0!"
                
                :: Удаление начальных пробелов
                for /f "tokens=* delims= " %%l in ("!line!") do set "line=%%l"
                
                :: Добавление обработанной строки к аргументам
                set "all_args=!all_args! !line!"
            )
        ) else (
            set "skip_next=0"
        )
    )
)

:: Удаление начального пробела
if defined all_args set "all_args=!all_args:~1!"

:: Создание службы
echo Installing service: %SRVCNAME%
echo Command line: %EXECUTABLE% %all_args%

sc create %SRVCNAME% binPath= "%EXECUTABLE% %all_args%" DisplayName= "%SRVCNAME%" start= auto
sc description %SRVCNAME% "DPI bypass service"
sc start %SRVCNAME%

echo Service installed successfully
pause
goto menu

:: Удаление служб
:service_remove
cls
echo Removing services...
echo --------------------

:: Проверка и удаление службы W-DPI
call :check_service_exist "%SRVCNAME%"
if !errorlevel! equ 0 (
    echo Stopping %SRVCNAME% service...
    net stop %SRVCNAME% >nul 2>&1
    if !errorlevel! equ 0 (
        echo Service %SRVCNAME% stopped successfully.
    ) else (
        echo Could not stop %SRVCNAME% service, attempting to delete anyway.
    )
    
    echo Deleting %SRVCNAME% service...
    sc delete %SRVCNAME% >nul 2>&1
    if !errorlevel! equ 0 (
        echo Service %SRVCNAME% deleted successfully.
    ) else (
        echo Failed to delete %SRVCNAME% service.
    )
) else (
    echo Service %SRVCNAME% not found.
)

echo.
echo Removal process completed.
pause
goto menu

:: Функция проверки существования службы
:check_service_exist
set "service=%~1"
sc query %service% >nul 2>&1
exit /b %errorlevel%

:: Проверка статуса
:service_status
cls
echo Service Status:
echo ---------------

tasklist /FI "IMAGENAME eq winws.exe" | find /I "winws.exe" > nul
if !errorlevel! equ 0 (
    echo Bypass process: [RUNNING]
) else (
    echo Bypass process: [STOPPED]
)

pause
goto menu

:: Запуск службы
:service_start
cls
echo Starting %SRVCNAME% service...
echo ----------------------------

:: Проверка существования службы
call :check_service_exist "%SRVCNAME%"
if !errorlevel! neq 0 (
    echo Service %SRVCNAME% not found. Please install first.
    pause
    goto menu
)

:: Проверка текущего статуса
call :get_service_status "%SRVCNAME%"
if "!service_status!"=="RUNNING" (
    echo Service %SRVCNAME% is already running.
    pause
    goto menu
)

:: Запуск службы
sc start %SRVCNAME%
if !errorlevel! equ 0 (
    echo Service %SRVCNAME% started successfully.
) else (
    echo Failed to start service! Error code: !errorlevel!

    :: Показать подробный статус службы
    sc query %SRVCNAME%
)

pause
goto menu

:: Остановка службы
:service_stop
cls
echo Stopping %SRVCNAME% service...
echo ----------------------------

call :check_service_exist "%SRVCNAME%"
if !errorlevel! neq 0 (
    echo Service %SRVCNAME% not found.
    pause
    goto menu
)

call :get_service_status "%SRVCNAME%"
if "!service_status!"=="STOPPED" (
    echo Service %SRVCNAME% is already stopped.
    pause
    goto menu
)

net stop %SRVCNAME%
if !errorlevel! equ 0 (
    echo Service %SRVCNAME% stopped successfully.
) else (
    echo Failed to stop service! Error code: !errorlevel!
    sc query %SRVCNAME%
)

pause
goto menu

:: Перезапуск службы
:service_restart
cls
echo [Restarting Service: %SRVCNAME%]
echo -------------------------------

:: Остановка службы
call :service_stop_no_pause

:: Небольшая задержка
timeout /t 3 /nobreak >nul

:: Запуск службы
call :service_start_no_pause

pause
goto menu

:: Внутренняя функция остановки (без паузы)
:service_stop_no_pause
sc query %SRVCNAME% >nul 2>&1 || exit /b
for /f "tokens=3" %%s in ('sc query %SRVCNAME% ^| findstr STATE') do set "status=%%s"
set "status=%status: =%"
if "%status%"=="RUNNING" (
    net stop %SRVCNAME% >nul || taskkill /F /FI "SERVICES eq %SRVCNAME%" >nul
)
exit /b

:: Внутренняя функция запуска (без паузы)
:service_start_no_pause
sc query %SRVCNAME% >nul 2>&1 || exit /b
for /f "tokens=3" %%s in ('sc query %SRVCNAME% ^| findstr STATE') do set "status=%%s"
set "status=%status: =%"
if not "%status%"=="RUNNING" sc start %SRVCNAME% >nul
exit /b

:: Функция для получения статуса службы
:get_service_status
setlocal
set "service=%~1"
set "status=NOT_FOUND"

for /f "tokens=3" %%s in ('sc query %service% ^| findstr STATE 2^>nul') do (
    if "%%s"=="RUNNING" set "status=RUNNING"
    if "%%s"=="STOPPED" set "status=STOPPED"
)

endlocal & set "service_status=%status%"
exit /b
