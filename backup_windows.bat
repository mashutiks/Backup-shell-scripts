@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: Проверка на наличие необходимых аргументов
if "%~1"=="" (
    echo Не указан путь к исходной папке.
    exit /b 1
)

if "%~2"=="" (
    echo Не указан максимальный размер папки в ГБ.
    exit /b 1
)

if "%~3"=="" (
    echo Не указан максимальный процент заполненности папки.
    exit /b 1
)

if "%~4"=="" (
    echo Не указано количество файлов для архивирования.
    exit /b 1
)

if "%~5"=="" (
    echo Не указан путь к папке назначения для архивов.
    exit /b 1
)

:: Путь к исходной папке
set "logDir=%~1"

:: Максимальный размер в байтах с использованием PowerShell
for /f %%a in ('powershell -command "%~2 * 1073741824"') do set maxSizeBytes=%%a

:: Максимальный процент заполненности
set "maxPercent=%~3"

:: Количество файлов для архивирования
set "M=%~4"

:: Путь к папке для архивации
set "backupDir=%~5"

:: Проверка на существование исходной папки
if not exist "%logDir%" (
    echo Указанная папка не существует!
    exit /b 1
)

:: Проверка на существование папки для архивации
if not exist "%backupDir%" (
    echo Указанная папка для архивации не существует, создаем её...
    mkdir "%backupDir%"
)

:: Подсчет текущего размера папки с использованием PowerShell
for /f "delims=" %%a in ('powershell -command "(Get-ChildItem -Recurse -File -Path \"%logDir%\" | Measure-Object -Property Length -Sum).Sum"') do set folderSize=%%a

:: Проверка на случай, если папка пуста
if "%folderSize%"=="" (
    echo Папка пуста.
    exit /b 0
)

:: Вычисляем процент заполненности с использованием PowerShell для точности
for /f %%a in ('powershell -command "[math]::Round((%folderSize% / %maxSizeBytes%) * 100, 2)"') do set usage=%%a

:: Заменяем запятую на точку для корректного сравнения
set usage=!usage:,=.!

:: Преобразуем процент заполняемости и максимальный процент в целые числа для корректного сравнения
for /f %%a in ('powershell -command "[math]::Floor(%usage%)"') do set usageInt=%%a
for /f %%a in ('powershell -command "[math]::Floor(%maxPercent%)"') do set maxPercentInt=%%a

:: Выводим результат
echo Размер папки: !folderSize! байт
echo Максимальный размер: !maxSizeBytes! байт
echo Заполненность папки: !usage!%%

:: Если заполненность превышает указанный процент, архивируем файлы
if !usageInt! geq !maxPercentInt! (
    echo Заполненность превышает !maxPercent!%%. Начинаем архивирование...

    :: Начинаем архивирование M самых старых файлов
    for /L %%i in (1,1,!M!) do (
        rem Получаем имя самого старого файла
        for /f "delims=" %%f in ('powershell -command "Get-ChildItem -Path '%logDir%' -File | Sort-Object LastWriteTime | Select-Object -First 1 | ForEach-Object { $_.FullName }"') do (
            set "oldestFile=%%f"
            if defined oldestFile (
                echo Архивируем файл: !oldestFile!

                :: Генерация имени архива в формате YYYYMMDD_HHMMSS
                for /f "delims=" %%j in ('powershell -command "Get-Date -Format 'yyyyMMdd_HHmmss'"') do set "zip_file=archive_%%j_%%i.7z"

                :: Создание архива с помощью 7-Zip, архивируем самый старый файл
                pushd "!logDir!"
                "C:\Program Files\7-Zip\7z.exe" a "!backupDir!\!zip_file!" "!oldestFile!"
                popd

                :: Удаление самого старого файла из исходной папки
                del "!oldestFile!"

                echo Файл !oldestFile! заархивирован в !zip_file! и удалён из исходной папки.
            )
        )
    )
) else (
    echo Заполненность папки не превышает !maxPercent!%%, архивирование не требуется.
)

endlocal
pause
