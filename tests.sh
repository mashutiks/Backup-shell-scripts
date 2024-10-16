#!/usr/bin/env bash
# Очистка старых данных перед началом тестов
initialize_directories() {
    local folderPath="$1"
    local backupDir="$2"
    echo "Проверка и создание папок $folderPath и $backupDir, если их нет..."
    mkdir -p "$folderPath" "$backupDir"
}

# Очистка папки folderPath
clean_log_dir() {
    local folderPath="$1"
    echo "Очистка папки $folderPath..."
    rm -rf "$folderPath"/*
}

# Генерация данных (файлов) в папке /log
generate_files() {
    local folderPath="$1"
    local fileNumber="$2"
    local fileSizeMb="$3"

    # Проверка, чтобы не генерировать файлы, если fileNumber или fileSizeMb равно 0
    if [ "$fileNumber" -eq 0 ] || [ "$fileSizeMb" -eq 0 ]; then
        echo "Генерация файлов не выполнена (fileNumber или fileSizeMb равно 0)."
        return
    fi
    echo "Генерация $fileNumber файлов по $fileSizeMb МБ в папке $folderPath..."
    # Используем стандартный цикл for
    for (( i = 1; i <= fileNumber; i++ )); do
        # Генерируем файл заданного размера
        dd if=/dev/zero of="$folderPath/logfile$i.log" bs=1M count="$fileSizeMb" status=none
        # Задержка для изменения даты модификации файлов
        sleep 0.1
    done
}

# Запуск основного скрипта и проверка результатов
execute_test() {
    local folderPath="$1"
    local threshold="$2"
    local backupDir="$3"
    # echo "Запуск теста с порогом архивирования: $threshold%"
    # Запуск основного скрипта (базового)
    ./backup_script.sh "$folderPath" "$threshold" "$backupDir"

    # Проверка результатов
    local initial_files=$(ls "$folderPath" | wc -l) # Подсчитываем файлы перед архивированием
    local remaining_files=$(ls "$folderPath" | wc -l) # Подсчитываем файлы после архивирования
    local archived_files=$((initial_files - remaining_files)) # Вычисляем разницу
    echo "Оставшиеся файлы в папке: $remaining_files"
}

# Тест 1: Один файл на 2ГБ
test_1() {
    local folderPath="$1"
    local backupDir="$2"
    echo "Тест 1: Один файл на 2ГБ при максимальном размере папки в 2.5ГБ"
    initialize_directories "$folderPath" "$backupDir"
    clean_log_dir "$folderPath" # Очищаем папку перед тестом
    generate_files "$folderPath" 1 2048 # 1 файл, 2048 МБ (2 ГБ)
    execute_test "$folderPath" 2.5 "$backupDir"
}

# Тест 2: 100 файлов по 50МБ при максимальном размере папки в 5ГБ"
test_2() {
    local folderPath="$1"
    local backupDir="$2"
    echo "Тест 2: 100 файлов по 50МБ при максимальном размере папки в 5ГБ"
    initialize_directories "$folderPath" "$backupDir"
    clean_log_dir "$folderPath" # Очищаем папку перед тестом
    generate_files "$folderPath" 100 50 # 100 файлов, 50 МБ каждый
    execute_test "$folderPath" 5 "$backupDir"
}

# Тест 3: 10 файлов по 100МБ при максимальном размере папки в 2ГБ"
test_3() {
    local folderPath="$1"
    local backupDir="$2"
    echo "Тест 3: 10 файлов по 100МБ при максимальном размере папки в 2ГБ"
    initialize_directories "$folderPath" "$backupDir"
    clean_log_dir "$folderPath" # Очищаем папку перед тестом
    generate_files "$folderPath" 10 100 # 10 файлов, 100 МБ каждый
    execute_test "$folderPath" 2 "$backupDir"
}

# Тест 4: 0 файлов (пустая папка)
test_4() {
    local folderPath="$1"
    local backupDir="$2"
    echo "Тест 4: Пустая папка"
    initialize_directories "$folderPath" "$backupDir"
    clean_log_dir "$folderPath" # Очищаем папку перед тестом
    generate_files "$folderPath" 0 0
    execute_test "$folderPath" 0.5 "$backupDir"
}

# Основная функция запуска всех тестов
run_all_tests() {
    local folderPath="$1"
    local backupDir="$2"
    test_1 "$folderPath" "$backupDir"
    test_2 "$folderPath" "$backupDir"
    test_3 "$folderPath" "$backupDir"
    test_4 "$folderPath" "$backupDir"
}

# Проверка входных параметров
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "$0 <путь_к_папке> <путь_для_backup>"
    exit 1
fi

# Параметры для папок логов и резервных копий
folderPath="$1"
backupDir="$2"

# Запуск всех тестов
initialize_directories "$folderPath" "$backupDir"
run_all_tests "$folderPath" "$backupDir"
