#!/bin/bash

# Переход в директорию проекта
cd ~/Desktop/reset-terminal-macos || { echo "Ошибка при переходе в директорию!"; exit 1; }

# Главные переменные
readonly RESET_COLOR='\033[0m'  # Сброс цвета
readonly WARNING_COLOR='\033[1;31m'  # Красный цвет для предупреждений
readonly INFO_COLOR='\033[1;32m'  # Зеленый цвет для информации
readonly AUTHOR_COLOR='\033[1;32m'  # Зеленый цвет для информации об авторе
readonly AGREEMENT_COLOR='\033[1;34m'  # Синий цвет для соглашения
readonly RISK_COLOR='\033[1;33m'  # Желтый цвет для рисков

# Папки с утилитами и основными скриптами
readonly UTILS_DIR="./scripts/utils"  # Папка с утилитами
readonly CORE_DIR="./scripts/core"    # Папка с основными скриптами

# Пути к скриптам
readonly ASCII_SCRIPT="$UTILS_DIR/ascii.sh"  # Скрипт для вывода ASCII-арт
readonly RESET_TERMINAL_SCRIPT="$CORE_DIR/reset_terminal.sh"  # Скрипт для сброса настроек терминала
readonly RESET_TO_DEFAULT_SCRIPT="$CORE_DIR/reset_terminal_to_default.sh"  # Скрипт для восстановления настроек по умолчанию
readonly CLEAN_HOME_SCRIPT="$CORE_DIR/clean_home_directory.sh"  # Скрипт для очистки домашней директории

# URL для получения последней версии
readonly GITHUB_API_URL="https://api.github.com/repos/DevCicadaY/reset-terminal-macos33/releases/latest"  

# Путь к скрипту для проверки macOS
readonly SCRIPT_PATH="$UTILS_DIR/check_mac.sh"  

# Путь к скрипту рисков и документации
readonly RISKS_AND_DOCS_SCRIPT="$UTILS_DIR/risks-and-docs.sh"

# Документация и репозиторий
readonly DOC_URL="https://github.com/DevCicadaY/reset-terminal-macos33/blob/main/README.md"
readonly REPO_URL="https://github.com/DevCicadaY/reset-terminal-macos33"  

# Функции
# Функция для установки прав на выполнение всех файлов в папке
make_executable() {
    find "$1" -type f -exec chmod +x {} \;
}

# Функция для вывода сообщений с разными цветами
print_message() {
    local message="$1"
    local color="$2"
    
    case "$color" in
        "1") echo -e "${WARNING_COLOR}$message${RESET_COLOR}" ;;  # Красный для предупреждений
        *) echo -e "${INFO_COLOR}$message${RESET_COLOR}" ;;  # Зеленый для информации
    esac
}

# Функция для запуска скриптов и обработки ошибок
run_script() {
    local script="$1"
    echo -e "${INFO_COLOR}Запуск скрипта: $script...${RESET_COLOR}"
    if [ -f "$script" ]; then
        "$script" || handle_error "$?" "$script"  # Если скрипт не выполнен, обработаем ошибку
        echo -e "${INFO_COLOR}Скрипт завершен: $script${RESET_COLOR}"
    else
        echo -e "${WARNING_COLOR}Не найден скрипт: $script!${RESET_COLOR}"
        exit 1
    fi
}

# Функция обработки ошибок
handle_error() {
    local exit_code="$1"
    local command="$2"
    
    if [ "$exit_code" -ne 0 ]; then
        echo -e "${WARNING_COLOR}Ошибка в процессе выполнения скрипта: $command${RESET_COLOR}"
        exit 1
    fi
}

# Проверка на поддержку цветов в терминале
check_colors() {
    if ! tput colors >/dev/null 2>&1; then
        echo -e "${WARNING_COLOR}Цвета не поддерживаются в вашем терминале. Продолжение будет без них.${RESET_COLOR}"
        RESET_COLOR='' WARNING_COLOR='' INFO_COLOR='' AUTHOR_COLOR='' AGREEMENT_COLOR='' RISK_COLOR=''
    fi
}

# Получение последней версии из GitHub API
get_latest_version() {
    version=$(curl -s "$GITHUB_API_URL" | jq -r '.tag_name')
    if [ -z "$version" ]; then
        echo -e "${WARNING_COLOR}Не удалось получить информацию о версии. Попробуйте позже.${RESET_COLOR}"
        exit 1
    fi
    echo -e "${INFO_COLOR}Текущая версия: ${version}${RESET_COLOR}"
}

# Анимация (для ожидания завершения процесса)
spin() {
    local pid=$!
    local spinstr='|/-\\'
    local temp

    while kill -0 "$pid" 2>/dev/null; do
        temp="${spinstr#?}"
        printf " [%c]  " "$spinstr"
        spinstr="$temp${spinstr%"$temp"}"
        sleep .1
        printf "\r"
    done
    printf "    \r"
}

# Подтверждение пользователя перед выполнением скриптов
confirm_and_run_script() {
    local script_name="$1"
    local script_desc="$2"
    local script_path="$3"

    echo -e "${INFO_COLOR}### $script_name ###${RESET_COLOR}"
    echo -e "$script_desc"
    echo -e "Нажмите ENTER для продолжения или CTRL+C для отмены."
    read -r
    run_script "$script_path"
}

# Основной процесс
main() {
    # Устанавливаем права на исполнение для всех файлов в папках с утилитами и скриптами
    make_executable "$UTILS_DIR"
    make_executable "$CORE_DIR"

    # Запуск проверки совместимости с macOS
    bash "$SCRIPT_PATH" || exit 1

    # Проверка поддержки цветов в терминале
    check_colors

    # Запуск скрипта с рисками и документацией
    bash "$RISKS_AND_DOCS_SCRIPT"

    # Запуск скрипта для вывода ASCII-арт
    echo -e "${INFO_COLOR}Запуск скрипта для вывода ASCII-арт...${RESET_COLOR}"
    "$ASCII_SCRIPT"

    # Получение последней версии проекта
    get_latest_version

    # Информация об авторе
    echo -e "${AUTHOR_COLOR}Автор: DevCicadaY${RESET_COLOR}"
    echo -e "${AUTHOR_COLOR}Репозиторий: $REPO_URL${RESET_COLOR}"

    # Предупреждение о рисках
    echo -e "${WARNING_COLOR}\nПРЕДУПРЕЖДЕНИЕ!${RESET_COLOR}"
    echo -e "${WARNING_COLOR}Этот скрипт изменит настройки терминала и может удалить файлы. \nВсе изменения необратимы!${RESET_COLOR}"
    echo -e "Нажмите ENTER для продолжения или CTRL+C для отмены."
    read -r  # Ждем нажатие Enter для продолжения

    # Соглашение на выполнение изменений
    echo -e "${RISK_COLOR}СОГЛАШЕНИЕ!${RESET_COLOR}"
    echo -e "${RISK_COLOR}Вы понимаете риски изменений и удалений файлов. \nЭти действия необратимы!${RESET_COLOR}"
    echo -e "Нажмите ENTER для продолжения, CTRL+C для отмены."
    read -r  # Ждем нажатие Enter для подтверждения

    # Выполнение сброса настроек терминала
    echo -e "${INFO_COLOR}Сброс настроек терминала...${RESET_COLOR}"

    # Подтверждения перед запуском скриптов
    confirm_and_run_script "reset_terminal.sh" \
        "$(echo -e "${WARNING_COLOR}Сброс настроек терминала к дефолтным и удаление всех изменений.\nПроцесс необратим! Продолжить?${RESET_COLOR}")" \
        "$RESET_TERMINAL_SCRIPT"

    confirm_and_run_script "reset_terminal_to_default.sh" \
        "$(echo -e "${WARNING_COLOR}Восстановление стандартных настроек терминала, удалив все пользовательские конфигурации.\nЭто необратимо! Вы уверены?${RESET_COLOR}")" \
        "$RESET_TO_DEFAULT_SCRIPT"

    # Подтверждение для удаления ненужных файлов
    confirm_and_run_script "clean_home_directory.sh" \
        "$(echo -e "${WARNING_COLOR}Удаление ненужных файлов из домашней директории. Этот процесс нельзя отменить.\nВы уверены, что хотите продолжить?${RESET_COLOR}")" \
        "$CLEAN_HOME_SCRIPT"
    
    # Завершение процесса
    echo -e "\n${INFO_COLOR}Процесс завершён успешно!${RESET_COLOR}"
    echo -e "${INFO_COLOR}Ваш терминал сброшен, настройки восстановлены, домашняя директория очищена.${RESET_COLOR}"
    echo -e "${INFO_COLOR}Для применения изменений перезагрузите терминал.${RESET_COLOR}"
    echo -e "\n${INFO_COLOR}Спасибо за использование!${RESET_COLOR}"
    echo -e "\n${INFO_COLOR}Есть вопросы? Репозиторий: $REPO_URL${RESET_COLOR}"
}

# Запуск основного процесса
main