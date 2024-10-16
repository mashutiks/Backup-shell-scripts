@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: Проверка на наличие необходимых аргументов
if "%~1"=="" (
    echo Не указан путь к базовому скрипту.
    exit /b 1
)

if "%~2"=="" (
    echo Не указан путь к папке для создания файлов.
    exit /b 1
)

if "%~3"=="" (
    echo Не указан путь для архивации.
    exit /b 1
)

:: Путь к базовому скрипту
set "base_script=%~1"
:: Путь к папке для создания тестовых файлов
set "test_folder=%~2"
:: Путь для архивации
set "backup_folder=%~3"

:: Проверка на существование папки для тестовых файлов
if not exist "%test_folder%" (
    echo Указанная папка для тестовых файлов не существует, создаем её...
    mkdir "%test_folder%"
)

:: Проверка на существование папки для архивации
if not exist "%backup_folder%" (
    echo Указанная папка для архивации не существует, создаем её...
    mkdir "%backup_folder%"
)

:: Генерация тестовых файлов до достижения общего размера более 0.5 ГБ
set /a total_size=0
set /a min_file_size=10485760   :: 1 MB
set /a max_file_size=52428800   :: 50 MB

:generate_files
set /a file_size=!random! %% %max_file_size% + %min_file_size%
set /a total_size+=file_size

:: Генерация файла с указанным размером
fsutil file createnew "%test_folder%\file_!total_size!.bin" !file_size!

:: Проверка, достигнут ли общий размер более 1 ГБ
if !total_size! lss 1073741824 (
    goto generate_files
)

echo Создано файлов на общую сумму: !total_size! байт

:: Запуск тестов
for /L %%i in (1,1,5) do (
    echo Запуск теста %%i...

    :: Случайные параметры
    set /a maxSizeGB=1
    set /a maxPercent=!random! %% 100 + 1  :: случайный процент от 1 до 100
    set /a M=!random! %% 10 + 1  :: случайное количество файлов для архивирования от 1 до 10

    echo Запуск: %base_script% "%test_folder%" !maxSizeGB! !maxPercent! !M! "%backup_folder%"

    :: Запуск базового скрипта с случайными параметрами
    call "%base_script%" "%test_folder%" !maxSizeGB! !maxPercent! !M! "%backup_folder%"

    :: Проверка размера папки после архивирования
    for /f "delims=" %%a in ('powershell -command "(Get-ChildItem -Recurse -File -Path '%test_folder%' | Measure-Object -Property Length -Sum).Sum"') do set folderSize=%%a

    echo Размер папки после архивирования: !folderSize! байт

    :: Если размер меньше 1 ГБ, начинаем снова
    if !folderSize! lss 1073741824 (
        echo Размер папки меньше 1 ГБ, начинаем заново...
        goto generate_files
    )

    echo Тест %%i завершен.
)

echo Все тесты завершены.
endlocal
pause
