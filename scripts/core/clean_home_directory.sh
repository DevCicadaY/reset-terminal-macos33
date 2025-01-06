#!/bin/bash
set -e

# Список стандартных папок, которые НЕ будут удалены
standard_folders=("Desktop" "Documents" "Downloads" "Movies" "Music" "Pictures" "Public" "Library" ".Trash" "Applications")

# Путь к рабочему столу
desktop_path="$HOME/Desktop"

# Проверка существования папки 'Desktop'
if [ ! -d "$desktop_path" ]; then
    echo "Папка 'Desktop' не существует."
    exit 1
fi

# Включаем dotglob, чтобы учитывать скрытые файлы
shopt -s dotglob

# Массивы для хранения файлов и папок
non_system_files=()  # Сюда добавляем файлы/папки для резервного копирования
files_to_delete=()   # Сюда добавляем файлы/папки, которые нужно удалить

# Ищем все файлы и папки в домашней директории, исключая стандартные
while IFS= read -r -d '' folder; do
    folder_name=$(basename "$folder")
    # Если папка не из стандартного списка, добавляем её в массивы
    if [[ ! " ${standard_folders[*]} " =~ " ${folder_name} " ]]; then
        non_system_files+=("$folder")  # Для резервного копирования
        files_to_delete+=("$folder")   # Для удаления
    fi
done < <(find ~ -mindepth 1 -maxdepth 1 -print0)

# Проверка на наличие файлов или папок для резервного копирования или удаления
if [ ${#non_system_files[@]} -eq 0 ]; then
    echo "Не найдено файлов или папок, не относящихся к системе. Пропускаем резервное копирование и удаление."
    exit 0
fi

# Создание папки для резервных копий на рабочем столе
backup_folder="$desktop_path/Backup_Folder"
mkdir -p "$backup_folder"
echo "Создана папка для резервных копий: $backup_folder"

# Копирование файлов и папок, не относящихся к системе, в папку для резервных копий
echo "Начинаем копирование файлов и папок..."
for folder in "${non_system_files[@]}"; do
    backup_path="$backup_folder/$(basename "$folder")"
    if [ -e "$backup_path" ]; then
        echo "Предупреждение: $folder уже существует в папке для резервных копий. Пропускаем копирование."
    else
        echo "Копирование: $folder в $backup_folder"
        cp -rL "$folder" "$backup_folder" || { echo "Ошибка при копировании: $folder"; continue; }
        echo "Успешно скопировано: $folder"
    fi
done

# После успешного завершения копирования
echo -e "\033[32mПроцесс копирования завершён. \nРезервные копии находятся в папке: $backup_folder\033[0m"

# Если есть файлы или папки для удаления, показываем список
if [ ${#files_to_delete[@]} -eq 0 ]; then
    echo "Нет файлов или папок для удаления."
else
    # Отображение списка файлов и папок для удаления
    echo -e "\033[31mПРЕДУПРЕЖДЕНИЕ: Следующие файлы и папки будут удалены навсегда!\033[0m"
    for file in "${files_to_delete[@]}"; do
        echo "$file"
    done

    # Подтверждение удаления
    read -p "Вы уверены, что хотите удалить эти файлы и папки? (y/n): " confirmation
    if [[ "$confirmation" == "y" ]]; then
        for folder in "${files_to_delete[@]}"; do
            echo "Удаление: $folder"
            rm -rf "$folder" || { echo "Ошибка при удалении: $folder"; continue; }
            echo "Успешно удалено: $folder"
        done
        echo "Процесс очистки завершён."
    else
        echo "Удаление отменено."
    fi
fi

# Отключаем dotglob, чтобы вернуться к стандартному поведению
shopt -u dotglob