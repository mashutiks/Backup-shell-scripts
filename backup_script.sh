#!/bin/bash

# Проверка наличия аргументов
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
    echo "$0 <путь_к_папке> <макс_размер_папки_в_ГБ> <путь_для_backup>"
    exit 1
fi

folderPath="$1"
maxSizeGB="$2"
backupDir="$3"
threshold=70  # ограничение в процентах

# Преобразование ГБ в биты
maxSizeBits=$(echo "$maxSizeGB * 1024 * 1024 * 1024 * 8" | bc)

# Проверка, существует ли указанная папка
if [ ! -d "$folderPath" ]; then
    echo "Папка \"$folderPath\" не существует."
    exit 1
fi

# Проверка, существует ли директория для backup
if [ ! -d "$backupDir" ]; then
    echo "Директория для backup \"$backupDir\" не существует."
    exit 1
fi

# Функция для вычисления размера папки в битах
calculate_folder_size() {
    size=$(find "$folderPath" -type f -exec du -b {} + | awk '{sum += $1} END {print sum}')
    if [ -z "$size" ]; then
        size=0
    fi
    echo $(($size * 8))
}

# Начальный расчет размера папки
logSizeBits=$(calculate_folder_size)

# Проверка, если папка пуста
if [ "$logSizeBits" -eq 0 ]; then
    echo "Папка пуста."
    exit 0
fi

# Расчет текущей заполненности папки
percentage=$(echo "scale=2; 100 * $logSizeBits / $maxSizeBits" | bc)

# Проверка, если заполненность больше 70%
while (( $(echo "$percentage > $threshold" | bc -l) )) || (( $(echo "$logSizeBits > $maxSizeBits" | bc -l) )); do

    echo "Текущая заполненность папки: $percentage%"
    echo "Заполненность папки превышает $threshold%. Начинаем архивирование старых файлов..."

    # Создаем папку /backup в указанной директории
    backupFolder="$backupDir/backup"
    if [ ! -d "$backupFolder" ]; then
        mkdir -p "$backupFolder"
        echo "Создана папка для архивов: $backupFolder"
    fi

    # Находим самый древний файл
    oldestFile=$(find "$folderPath" -type f -printf '%T+ %p\n' | sort | head -n 1 | awk '{print $2}')
    if [ -z "$oldestFile" ]; then
        echo "Не найдено файлов для архивирования."
        break
    fi

    # Архивируем файл
    archiveName="$backupFolder/backup_$(date +%Y%m%d%H%M%S).tar.gz"
    tar -czf "$archiveName" "$oldestFile"
    echo "Файл $oldestFile заархивирован в $archiveName"

    # Удаляем файл из исходной папки
    rm "$oldestFile"
    echo "Файл $oldestFile удален."

    # Пересчитываем размер папки
    logSizeBits=$(calculate_folder_size)
    percentage=$(echo "scale=2; 100 * $logSizeBits / $maxSizeBits" | bc)
done

if [ $(echo "$percentage < $threshold" | bc -l) ]; then
    echo "Папка занимает $percentage% от $maxSizeGB ГБ"
fi
