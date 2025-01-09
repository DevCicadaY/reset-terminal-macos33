#!/bin/bash

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RESET_COLOR='\033[0m'  # Сброс цвета

# Важные переменные
MIN_MAC_VERSION=15               # Минимальная поддерживаемая версия macOS
MIN_CURL_VERSION="7.64.1"         # Минимальная версия утилиты curl
MIN_JQ_VERSION="1.5"              # Минимальная версия утилиты jq
DOC_URL="https://example.com"     # Ссылка на документацию

# Функция для получения версии macOS
get_mac_version() {
    local version=$(sw_vers -productVersion)
    echo "$version"
}

# Получение данных об операционной системе и версии macOS
os_name=$(uname)
mac_version=$(get_mac_version)
mac_major_version=$(echo "$mac_version" | cut -d'.' -f1)

# Получение версий утилит
curl_version=$(curl --version | head -n 1 | awk '{print $2}')
jq_version=$(jq --version | cut -d'-' -f2)

# Список поддерживаемых терминалов
SUPPORTED_TERMINALS=("iTerm2", "Hyper", "Alacritty", "Kitty")

# Вывод общей информации о системе
echo -e "${BLUE}Информация о системе:${RESET_COLOR}"
echo -e "${GREEN}Операционная система: $os_name${RESET_COLOR}"
echo -e "${GREEN}Версия macOS: $mac_version${RESET_COLOR}"
echo -e "${GREEN}Минимальная поддерживаемая версия macOS: $MIN_MAC_VERSION${RESET_COLOR}"
echo -e "${GREEN}Минимальная версия curl: $MIN_CURL_VERSION${RESET_COLOR}"
echo -e "${GREEN}Минимальная версия jq: $MIN_JQ_VERSION${RESET_COLOR}"
echo -e "${GREEN}Версия curl: $curl_version${RESET_COLOR}"
echo -e "${GREEN}Версия jq: $jq_version${RESET_COLOR}"
echo -e "${BLUE}Рекомендуемые терминалы: ${SUPPORTED_TERMINALS[*]}${RESET_COLOR}"

# Определение текущего терминала
current_terminal=$(echo "$TERM_PROGRAM")
echo -e "${BLUE}Текущий терминал: $current_terminal${RESET_COLOR}"

# Проверка операционной системы
echo -e "${BLUE}Проверка операционной системы...${RESET_COLOR}"
if [[ "$os_name" != "Darwin" ]]; then
    echo -e "${RED}Ошибка: данный скрипт поддерживает только macOS.${RESET_COLOR}"
    exit 1
fi

# Проверка версии macOS
echo -e "${BLUE}Проверка версии macOS...${RESET_COLOR}"
if [[ "$mac_major_version" -lt "$MIN_MAC_VERSION" ]]; then
    echo -e "${RED}Ошибка: данный скрипт требует macOS версии $MIN_MAC_VERSION и выше.${RESET_COLOR}"
    echo -e "${RED}Пожалуйста, обновите macOS до поддерживаемой версии.${RESET_COLOR}"
    exit 1
fi

# Если версия macOS подходит, продолжаем выполнение
echo -e "${GREEN}Версия macOS $mac_version поддерживается. Продолжаем выполнение скрипта...${RESET_COLOR}"

# Функция для проверки утилит и их версий
check_utility_version() {
    local utility="$1"
    local current_version="$2"
    local min_version="$3"
    local utility_name="$4"

    echo -e "${BLUE}Проверка утилиты: $utility...${RESET_COLOR}"
    if [[ -z "$current_version" ]]; then
        echo -e "${YELLOW}Ошибка: утилита $utility не установлена!${RESET_COLOR}" >&2
        case "$utility" in
            curl) echo -e "${BLUE}Установите curl с помощью команды: brew install curl.${RESET_COLOR}" ;;
            jq) echo -e "${BLUE}Установите jq с помощью команды: brew install jq.${RESET_COLOR}" ;;
            *) echo -e "${BLUE}Установите $utility через ваш пакетный менеджер.${RESET_COLOR}" ;;
        esac
        exit 1
    elif [[ "$(printf '%s\n' "$min_version" "$current_version" | sort -V | head -n1)" != "$min_version" ]]; then
        echo -e "${RED}Ошибка: версия $utility ($current_version) ниже минимальной ($min_version).${RESET_COLOR}"
        echo -e "${RED}Пожалуйста, обновите $utility.${RESET_COLOR}"
        exit 1
    else
        echo -e "${GREEN}Версия $utility ($current_version) удовлетворяет минимальному требованию ($min_version).${RESET_COLOR}"
    fi
}

# Проверка утилит
check_utility_version "curl" "$curl_version" "$MIN_CURL_VERSION" "curl"
check_utility_version "jq" "$jq_version" "$MIN_JQ_VERSION" "jq"

# Функция для проверки терминала
check_terminal() {
    echo -e "${BLUE}Проверка терминала...${RESET_COLOR}"
    if [[ "$TERM_PROGRAM" == "Apple_Terminal" ]]; then
        echo -e "${YELLOW}Предупреждение: Для наилучшего опыта используйте другой терминал. \nРекомендуем: ${SUPPORTED_TERMINALS[*]}.${RESET_COLOR}"
        echo -e "${BLUE}Дополнительную информацию можно найти в документации: $DOC_URL${RESET_COLOR}"
        exit 1
    else
        echo -e "${GREEN}Терминал поддерживается. Продолжаем выполнение скрипта.${RESET_COLOR}"
    fi
}

# Проверка терминала
check_terminal

# Если все проверки пройдены успешно, продолжаем выполнение
echo -e "${GREEN}Все проверки пройдены успешно. Скрипт продолжает выполнение...${RESET_COLOR}"

exit 0