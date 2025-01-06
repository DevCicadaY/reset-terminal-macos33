#!/bin/bash

# Очищаем экран перед началом
clear

# Цветовые переменные
INFO_COLOR="\033[1;32m"  # Зеленый цвет
WARNING_COLOR="\033[1;33m"  # Желтый цвет
ERROR_COLOR="\033[1;31m"  # Красный цвет
RESET_COLOR="\033[0m"  # Сброс цвета

# URL документации
DOC_URL="https://example.com/docs"

# Функция для открытия документации
open_documentation() {
    echo -e "${INFO_COLOR}Документация доступна по следующей ссылке: $DOC_URL${RESET_COLOR}"
    if command -v open >/dev/null 2>&1; then
        open "$DOC_URL" || {
            echo -e "${WARNING_COLOR}Не удалось автоматически открыть документацию. Откройте её вручную: $DOC_URL${RESET_COLOR}"
        }
    else
        echo -e "${WARNING_COLOR}Команда 'open' недоступна на вашей системе.${RESET_COLOR}"
        echo -e "${INFO_COLOR}Пожалуйста, откройте ссылку вручную: $DOC_URL${RESET_COLOR}"
    fi
    echo -e "${INFO_COLOR}После ознакомления с документацией, нажмите ENTER для продолжения...${RESET_COLOR}"
    read -r
}

# Функция для показа предупреждения перед запуском
display_warning() {
    echo -e "${ERROR_COLOR}ВНИМАНИЕ!${RESET_COLOR}"
    echo -e "${WARNING_COLOR}Перед продолжением обязательно ознакомьтесь с документацией и рисками использования скрипта.${RESET_COLOR}"
    echo -e "${INFO_COLOR}Документация поможет вам понять все возможные последствия и риски использования этого скрипта.${RESET_COLOR}"
}

# Запрос на ознакомление с документацией
display_warning
echo -e "${INFO_COLOR}Хотите ознакомиться с документацией? (y/n)${RESET_COLOR}"
read -r user_choice

# Обработка выбора пользователя
if [[ "$user_choice" =~ ^[yY]$ ]]; then
    open_documentation
else
    echo -e "${ERROR_COLOR}Вы пропустили ознакомление с документацией, но соглашаетесь с возможными рисками!${RESET_COLOR}"
    echo -e "${WARNING_COLOR}Мы не несем ответственности за последствия использования без ознакомления.${RESET_COLOR}"
    echo -e "${INFO_COLOR}Ссылка на документацию: $DOC_URL${RESET_COLOR}"
    echo -e "${INFO_COLOR}Нажмите ENTER, чтобы продолжить...${RESET_COLOR}"
    read -r
fi