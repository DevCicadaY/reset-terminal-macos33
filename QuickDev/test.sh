#!/bin/bash

# Функция установки Firefox Developer Edition
install_firefox_dev() {
  echo "Проверка наличия Firefox Developer Edition..."

  if [ ! -d "/Applications/Firefox Developer Edition.app" ]; then
    echo "Firefox Developer Edition не найден. Установка Firefox Developer Edition..."
    brew install --cask firefox-developer-edition
    echo "Firefox Developer Edition успешно установлен."
  else
    echo "Firefox Developer Edition уже установлен."
  fi

  echo "Процесс установки завершён."
  # Ожидание подтверждения от пользователя
  read -p "После выполнения этих шагов нажмите Enter для продолжения..."
}

# Вызов функции
install_firefox_dev