#!/bin/bash

# Функция для вывода сообщений с временной меткой и кодом завершения
print_message() {
    local message="$1"
    local code="${2:-0}"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $message (Код завершения: $code)"
}

# Проверка наличия sudo
if ! command -v sudo &>/dev/null; then
    print_message "Ошибка: sudo не установлено. Пожалуйста, установите sudo и попробуйте снова." 1
    exit 1
fi

echo -e "\033[1;31m\033[43mВнимание! Операция затронет только настройки стандартного Terminal и его файлы. \nДругие терминалы не будут затронуты.\033[0m"

# Запрос пароля sudo один раз в начале
echo "Пожалуйста, введите ваш пароль sudo для продолжения:"
sudo -v

# Функция для проверки статуса завершения и записи результатов
check_exit_status() {
    local action="$1"
    local exit_code="$?"
    if [[ $exit_code -eq 0 ]]; then
        print_message "$action успешно завершено."
    else
        print_message "Ошибка при выполнении $action." 1
        exit 1
    fi
}

# Проверка, что скрипт не запускается в стандартном Terminal.app
if [[ "$TERM_PROGRAM" == "Apple_Terminal" ]]; then
    print_message "Выполнение скрипта в Terminal.app запрещено. Пожалуйста, запустите скрипт в другом терминале." 1
    exit 1
else
    print_message "Продолжаем сброс настроек терминала."
fi

# Флаг для отслеживания выполненных операций
OPERATIONS_DONE=false

# Список файлов и директорий для удаления
FILES_TO_REMOVE=(
    "$HOME/Library/Preferences/com.apple.Terminal.plist"
    "$HOME/Library/Saved Application State/com.apple.Terminal.savedState"
    "$HOME/.bash_profile"
    "$HOME/.bashrc"
    "$HOME/.zshrc"
    "$HOME/.zsh_profile"
    "$HOME/.config"
)

# Определение имени терминала и сохраненного состояния
TERMINAL_APP="Terminal"
TERMINAL_SAVED_STATE="$HOME/Library/Saved Application State/com.apple.Terminal.savedState"

# Закрытие Terminal, если оно запущено
if pgrep -x "$TERMINAL_APP" > /dev/null; then
    print_message "Попытка закрыть Terminal..."
    osascript -e 'quit app "Terminal"'
    check_exit_status "Закрытие Terminal"
    OPERATIONS_DONE=true
else
    print_message "Terminal не запущен, закрывать не нужно."
fi

# Удаление указанных файлов и директорий
for file in "${FILES_TO_REMOVE[@]}"; do
    if [[ -e "$file" ]]; then
        print_message "Удаление $file..."
        sudo rm -rf "$file" 2>/dev/null
        check_exit_status "Удаление $file"
        OPERATIONS_DONE=true
    else
        print_message "$file не существует."
    fi
done

# Сброс настроек Terminal
print_message "Восстановление стандартных профилей Terminal..."
if defaults read com.apple.Terminal &>/dev/null; then
    defaults delete com.apple.Terminal
    check_exit_status "Восстановление стандартных профилей Terminal"
    OPERATIONS_DONE=true
else
    print_message "Настройки Terminal не найдены для сброса."
fi

# Сброс файлов конфигурации оболочек (bash, zsh и других)
SHELL_FILES=(
    "$HOME/.bashrc"
    "$HOME/.bash_profile"
    "$HOME/.zshrc"
    "$HOME/.zsh_profile"
)

for shell_file in "${SHELL_FILES[@]}"; do
    if [[ -e "$shell_file" ]]; then
        print_message "Удаление $shell_file..."
        sudo rm -f "$shell_file" 2>/dev/null
        check_exit_status "Удаление $shell_file"
        OPERATIONS_DONE=true
    else
        print_message "$shell_file не существует."
    fi
done

# Очистка остатков файлов, связанных с Terminal
print_message "Очистка остаточных файлов, связанных с Terminal..."
sudo rm -rf "$HOME/Library/Application Support/Terminal" 2>/dev/null
sudo rm -rf "$HOME/Library/Caches/com.apple.Terminal" 2>/dev/null

# Итоговое сообщение о статусе, в зависимости от выполненных операций
if [[ "$OPERATIONS_DONE" == true ]]; then
    print_message "Сброс настроек Terminal завершен успешно."
else
    print_message "Нет изменений: все настройки терминала уже в исходном состоянии."
fi