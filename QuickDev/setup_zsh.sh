#!/bin/bash

# Функция для очистки терминала
clear_terminal() {
  echo "Очищаем терминал..."
  clear
}

# Функция для закрытия терминала
close_terminal() {
  echo "Закрываем терминал..."
  osascript -e 'tell application "Terminal" to quit'
  # Ожидание подтверждения от пользователя
  read -p "После выполнения этих шагов нажмите Enter для продолжения..."
}

# Функция для запроса пароля и вывода сообщения
request_sudo_password() {
  # Проверяем, был ли запрос пароля
  if sudo -v 2>/dev/null; then
    # Если sudo запросил пароль, выводим сообщение
    echo -e "Для выполнения изменений требуется ввести ваш пароль администратора."
  else
    # Если sudo не запросил пароль (например, уже активен таймер), ничего не делаем
    :
  fi
  # Ожидание подтверждения от пользователя
  read -p "После выполнения этих шагов нажмите Enter для продолжения..."
}


install_homebrew() {
  # Проверка, установлен ли Homebrew
  if ! command -v brew &>/dev/null && ! [ -f /opt/homebrew/bin/brew ] && ! [ -f /usr/local/bin/brew ]; then
    echo "Homebrew не установлен. Начинаю установку..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  else
    echo "Homebrew уже установлен."
  fi
  # Ожидание подтверждения от пользователя
  read -p "После выполнения этих шагов нажмите Enter для продолжения..."
}

setup_homebrew_env() {
  # Путь к файлу .zprofile
  local zprofile_file="$HOME/.zprofile"

  # Проверка, существует ли файл .zprofile
  if [ ! -f "$zprofile_file" ]; then
    # Создаем файл, если его нет
    touch "$zprofile_file"
    echo "$zprofile_file has been created."
  fi

  # Проверка, содержится ли уже строка для настройки Homebrew
  if ! grep -q 'eval "$(/opt/homebrew/bin/brew shellenv)"' "$zprofile_file"; then
    # Добавляем строку в конец файла .zprofile
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$zprofile_file"
    echo "Homebrew shell environment setup added to $zprofile_file"
  else
    echo "Homebrew shell environment setup already exists in $zprofile_file"
  fi

  # Применяем настройки сразу в текущем сеансе
  eval "$(/opt/homebrew/bin/brew shellenv)"
  echo "Homebrew environment variables are now set."
  # Ожидание подтверждения от пользователя
  read -p "После выполнения этих шагов нажмите Enter для продолжения..."
}



# Функция для установки Oh My Zsh
install_oh_my_zsh() {
  # Проверка, установлен ли Oh My Zsh, путем проверки существования директории ~/.oh-my-zsh
  if [ -d "$HOME/.oh-my-zsh" ]; then
    # Если директория существует, значит, Oh My Zsh уже установлен, выводим сообщение и выходим из функции
    echo "Oh My Zsh уже установлен."
    return 0  # Выход из функции с кодом 0 (успешное завершение)
  fi

  # Если Oh My Zsh не установлен, выводим сообщение и начинаем установку
  echo "Устанавливаю Oh My Zsh..."

# Запускаем установку Oh My Zsh в новом терминале и после завершения закрываем окно
  osascript -e 'tell application "Terminal"
    do script "sh -c \"$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh) && exit\""
  end tell'

  # После завершения установки выводим сообщение
  echo "Установка завершена."

  # Ожидаем подтверждения от пользователя
  read -n 1 -s -r -p "Нажмите Enter, чтобы продолжить..."
  echo "Продолжаем работу после завершения установки."

  # Закрытие стандартного терминала (окно, где был запущен основной скрипт)
  osascript -e 'tell application "Terminal" to close front window'
}

# Функция для отключения сообщения о последнем входе в терминал
disable_last_login_message() {
  # Проверяем, существует ли файл .hushlogin в домашней директории
  if [ ! -f "$HOME/.hushlogin" ]; then
    # Если файл не существует, создаем его, чтобы отключить сообщение о последнем входе
    touch "$HOME/.hushlogin"
    # Выводим сообщение о том, что сообщение отключено
    echo "Сообщение о последнем входе отключено."
  else
    # Если файл уже существует, выводим сообщение, что отключение уже выполнено
    echo "Сообщение о последнем входе уже отключено."
  fi
  # Ожидание подтверждения от пользователя
  read -p "После выполнения этих шагов нажмите Enter для продолжения..."
}

# Функция для отключения сообщения о новой почте
disable_new_mail_message() {
  # Добавляем команду для отключения проверки новой почты в файл ~/.zshrc
  echo 'unset MAILCHECK' >> ~/.zshrc
  # Выводим сообщение о выполнении действия
  echo "Сообщение о новой почте отключено."
  # Ожидание подтверждения от пользователя
  read -p "После выполнения этих шагов нажмите Enter для продолжения..."
}

# Функция для добавления Homebrew в PATH
add_homebrew_to_path() {
    # Проверяем, установлен ли Homebrew
    if ! command -v brew &>/dev/null && ! [ -f /opt/homebrew/bin/brew ] && ! [ -f /usr/local/bin/brew ]; then
        echo "Homebrew не найден. Пожалуйста, установите Homebrew перед запуском этого скрипта."
        return 1
    fi

    # Команда для добавления Homebrew в PATH
    local brew_cmd='eval "$(/opt/homebrew/bin/brew shellenv)"'

    # Файлы конфигураций для различных оболочек
    local files=("$HOME/.bash_profile" "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.config/fish/config.fish")

    for file in "${files[@]}"; do
        if [[ -f "$file" ]]; then
            # Проверяем, содержится ли команда в файле
            if grep -q "$brew_cmd" "$file"; then
                echo "Команда уже существует в $file."
            else
                # Добавляем команду в файл, если её нет
                echo "$brew_cmd" >> "$file"
                echo "Команда для добавления Homebrew в PATH добавлена в $file."
            fi
        else
            echo "$file не существует. Пропускаем..."
        fi
    done

    # Применяем изменения
    if command -v brew &>/dev/null; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
        echo "Homebrew успешно добавлен в PATH."
    else
        echo "Не удалось добавить Homebrew в PATH. Пожалуйста, перезапустите терминал или вручную добавьте команду."
    fi
  # Ожидание подтверждения от пользователя
  read -p "После выполнения этих шагов нажмите Enter для продолжения..."
}

open_shells_in_current_terminal() {
    local editor="nano"  # Установите по умолчанию nano, можно изменить на vim или другой редактор

    # Проверка, установлен ли редактор
    if ! command -v $editor &>/dev/null; then
        echo "Редактор $editor не найден. Пожалуйста, установите его перед продолжением."
        return 1
    fi
    
    # Вывод содержимого /etc/shells после добавления
    echo "Содержимое /etc/shells после добавления пути:"
    cat /etc/shells
  # Ожидание подтверждения от пользователя
  read -p "После выполнения этих шагов нажмите Enter для продолжения..."
}

install_nano() {
    # Проверка, установлен ли Homebrew
    if ! command -v brew &>/dev/null; then
        echo "Homebrew не найден. Пожалуйста, установите его перед продолжением."
        return 1
    fi

    # Проверка, установлен ли уже nano
    if command -v nano &>/dev/null; then
        echo "nano уже установлен."
    else
        # Установка nano
        echo "Устанавливаю nano с помощью brew..."
        brew install nano
    fi
  # Ожидание подтверждения от пользователя
  read -p "После выполнения этих шагов нажмите Enter для продолжения..."
}

# Функция для установки последней версии Bash через Homebrew
install_latest_bash() {
    # Проверяем, установлен ли Homebrew
    if ! command -v brew &>/dev/null && ! [ -f /opt/homebrew/bin/brew ] && ! [ -f /usr/local/bin/brew ]; then
        echo "Homebrew не найден. Пожалуйста, установите Homebrew перед запуском этого скрипта."
        return 1
    fi

    # Выводим текущую версию Bash
    current_bash_version=$(bash --version | head -n 1)
    echo "Текущая версия Bash: $current_bash_version"

    # Проверяем, установлена ли последняя версия Bash (например, версия 5.x)
    if ! command -v bash &>/dev/null || ! [[ "$(bash --version | head -n 1)" == *"5."* ]]; then
        echo "Устанавливаю последнюю версию Bash..."
        brew install bash
        # Выводим новую версию после установки
        new_bash_version=$(bash --version | head -n 1)
        echo "После установки новая версия Bash: $new_bash_version"
    else
        echo "Последняя версия Bash уже установлена."
    fi
  # Ожидание подтверждения от пользователя
  read -p "После выполнения этих шагов нажмите Enter для продолжения..."
}

install_git() {
    # Проверяем, установлен ли Homebrew
    if command -v brew &>/dev/null; then
        echo "Homebrew найден, продолжаем установку Git..."
    else
        echo "Homebrew не найден. Устанавливаем Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    # Проверяем, установлен ли Git и установлен ли он через Homebrew
    git_path=$(which git)
    if [[ -n "$git_path" && "$git_path" == /usr/local/bin/git* || "$git_path" == /opt/homebrew/bin/git* ]]; then
        echo "Git уже установлен через Homebrew."
    else
        echo "Git не установлен через Homebrew или не установлен. Устанавливаем Git..."
        brew install git
    fi
  # Ожидание подтверждения от пользователя
  read -p "После выполнения этих шагов нажмите Enter для продолжения..."
}



add_homebrew_path() {
  # Проверяем, существует ли строка в ~/.zshrc
  if ! grep -q 'export PATH="/opt/homebrew/bin:$PATH"' ~/.zshrc; then
    # Добавляем строку в ~/.zshrc
    echo 'export PATH="/opt/homebrew/bin:$PATH"' >> ~/.zshrc
    # Применяем изменения
    source ~/.zshrc
    echo "Путь Homebrew успешно добавлен в ~/.zshrc и применён."
  else
    echo "Строка уже присутствует в ~/.zshrc."
  fi
  # Ожидание подтверждения от пользователя
  read -p "После выполнения этих шагов нажмите Enter для продолжения..."
}



# Функция для установки шрифтов для всех пользователей
install_fonts() {
  # Папка с шрифтами на рабочем столе
  FONT_DIR="$HOME/Desktop/JetBrainsMono Nerd Font"
  
  # Проверка наличия папки с шрифтами
  if [ ! -d "$FONT_DIR" ]; then
    echo "Папка с шрифтами не найдена на рабочем столе!"
    return 1
  fi

  # Папка для установки шрифтов
  INSTALL_DIR="/Library/Fonts/"

  # Проверка, существуют ли шрифты уже в системной папке
  echo "Проверка наличия шрифтов в папке $INSTALL_DIR..."
  for font in "$FONT_DIR"/*.ttf; do
    if [ -f "$INSTALL_DIR/$(basename "$font")" ]; then
      echo "Шрифт $(basename "$font") уже установлен."
    else
      # Копирование шрифта в системную папку для всех пользователей
      echo "Устанавливаю шрифт $(basename "$font")..."
      sudo cp "$font" "$INSTALL_DIR"
      
      # Проверка успешности установки
      if [ $? -eq 0 ]; then
        echo "Шрифт $(basename "$font") успешно установлен!"
      else
        echo "Произошла ошибка при установке шрифта $(basename "$font")."
        return 1
      fi
    fi
  done
  # Ожидание подтверждения от пользователя
  read -p "После выполнения этих шагов нажмите Enter для продолжения..."
}

# Функция для установки Zsh
install_zsh() {
  # Проверка, установлен ли Zsh через Homebrew
  if ! brew list | grep -q "zsh"
  then
    echo "Zsh не установлен через Homebrew. Устанавливаю..."
    # Установка Zsh через Homebrew
    brew install zsh
  else
    echo "Zsh уже установлен через Homebrew."
  fi

  # Проверка, есть ли путь к Zsh в /etc/shells
  if ! grep -q "/opt/homebrew/bin/zsh" /etc/shells
  then
    echo "Добавляю путь к Zsh в /etc/shells..."
    sudo sh -c 'echo /opt/homebrew/bin/zsh >> /etc/shells'
  elseripgrep
    echo "Путь к Zsh уже добавлен в /etc/shells."
  fi

  # Вывод содержимого /etc/shells после добавления
  echo "Содержимое /etc/shells после добавления пути:"
  cat /etc/shells
  # Ожидание подтверждения от пользователя
  read -p "После выполнения этих шагов нажмите Enter для продолжения..."
}


# Функция для изменения текущей оболочки на zsh
change_shell_to_zsh() {
    # Определяем текущую оболочку
    local current_shell=$(basename "$SHELL")

    # Проверяем, настроена ли оболочка на zsh
    if [[ "$current_shell" != "zsh" ]]; then
        echo -e "\nТекущая оболочка: $current_shell"
        echo "Меняем оболочку на zsh..."

        # Меняем оболочку пользователя на zsh с использованием sudo
        sudo chsh -s /opt/homebrew/bin/zsh $USER
        
        # Проверяем успешность выполнения команды
        if [[ $? -eq 0 ]]; then
            echo -e "\nОболочка успешно изменена на zsh."
        else
            echo -e "\nОшибка при изменении оболочки. Убедитесь, что у вас достаточно прав."
            echo "Попробуйте снова или обратитесь к администратору."
        fi
    else
        echo -e "\nВаша оболочка уже настроена на zsh."
    fi
  # Ожидание подтверждения от пользователя
  read -p "После выполнения этих шагов нажмите Enter для продолжения..."
}

# Функция для установки и настройки zsh-autosuggestions
install_zsh_autosuggestions() {
  # Проверка, установлен ли плагин zsh-autosuggestions
  if ! brew list | grep -q "zsh-autosuggestions"; then
    echo "Устанавливаю zsh-autosuggestions через Homebrew..."
    brew install zsh-autosuggestions
  else
    echo "zsh-autosuggestions уже установлен."
  fi

  # Проверка, существует ли файл .zshrc
  if [ -f "$HOME/.zshrc" ]; then
    # Проверка, есть ли уже строка для плагина в .zshrc
    if ! grep -q "zsh-autosuggestions.zsh" "$HOME/.zshrc"; then
      echo "Добавляю плагин в .zshrc..."
      echo "source \$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh" >> "$HOME/.zshrc"
    else
      echo "Плагин уже добавлен в .zshrc."
    fi
  else
    echo ".zshrc не найден. Пожалуйста, создайте файл .zshrc в вашем домашнем каталоге."
    exit 1
  fi

  echo "Установка и настройка завершены. Перезапустите терминал или выполните 'source ~/.zshrc', чтобы применить изменения."
  # Ожидание подтверждения от пользователя
  read -p "После выполнения этих шагов нажмите Enter для продолжения..."
}

# Функция для установки или обновления zsh-syntax-highlighting
install_or_update_zsh_syntax_highlighting() {
  # Папка для установки плагинов
  local plugin_dir="$HOME/.zsh/plugins"
  local plugin_path="$plugin_dir/zsh-syntax-highlighting"
  
  # Создаем папку, если она не существует
  echo "Проверка и создание директории для плагинов: $plugin_dir"
  mkdir -p "$plugin_dir"

  # Проверяем, существует ли уже плагин
  if [ -d "$plugin_path" ]; then
    echo "Плагин zsh-syntax-highlighting уже установлен. Выполняю обновление..."
    # Переходим в папку плагина и обновляем репозиторий
    git -C "$plugin_path" pull
  else
    echo "Плагин zsh-syntax-highlighting не найден. Устанавливаю..."
    # Клонируем репозиторий
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$plugin_path"
  fi

  # Проверяем, добавлена ли строка для активации плагина в .zshrc
  if ! grep -q "zsh-syntax-highlighting.zsh" "${ZDOTDIR:-$HOME}/.zshrc"; then
    echo "Добавляю строку для активации плагина в .zshrc..."
    echo "source $plugin_path/zsh-syntax-highlighting.zsh" >> "${ZDOTDIR:-$HOME}/.zshrc"
    echo "Строка для загрузки плагина добавлена в .zshrc"
  else
    echo "Строка для загрузки плагина уже присутствует в .zshrc"
  fi

  # Сообщение о завершении
  echo "zsh-syntax-highlighting успешно установлен или обновлен!"
  # Ожидание подтверждения от пользователя
  read -p "После выполнения этих шагов нажмите Enter для продолжения..."
}



# Функция для установки Powerlevel10k через Homebrew
install_powerlevel10k() {
    # Шаг 1: Проверка, установлен ли Powerlevel10k через Homebrew
    if brew list --formula | grep -q "^powerlevel10k$"; then
        echo "Powerlevel10k уже установлен."
    else
        echo "Устанавливаю Powerlevel10k через Homebrew..."
        brew install powerlevel10k

        # Шаг 2: Проверка успешной установки Powerlevel10k
        if brew list --formula | grep -q "^powerlevel10k$"; then
            echo "Powerlevel10k успешно установлен."
        else
            echo "Ошибка: Powerlevel10k не установлен. Проверьте Homebrew и повторите попытку."
            return 1  # Выход из функции с кодом ошибки
        fi
    fi

    # Шаг 3: Путь к теме Powerlevel10k в директории, установленной Homebrew
    P10K_PATH="$(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme"

    # Шаг 4: Проверка, существует ли файл ~/.zshrc
    if [[ ! -f ~/.zshrc ]]; then
        echo "Файл ~/.zshrc не найден. Создаю новый файл..."
        touch ~/.zshrc  # Создание пустого файла ~/.zshrc
    fi

    # Шаг 5: Проверка, добавлена ли уже тема Powerlevel10k в файл ~/.zshrc
    if ! grep -q "source $P10K_PATH" ~/.zshrc; then
        echo "Добавляю тему Powerlevel10k в ~/.zshrc..."
        echo "source $P10K_PATH" >>~/.zshrc  # Добавляем строку с темой в ~/.zshrc
    else
        echo "Тема Powerlevel10k уже добавлена в ~/.zshrc."
    fi

    # Шаг 6: Копирование кастомных настроек Powerlevel10k с рабочего стола
    CUSTOM_P10K_CONFIG=~/Desktop/p10k.zsh  # Путь к вашему файлу на рабочем столе
    if [[ -f "$CUSTOM_P10K_CONFIG" ]]; then
        echo "Копирую кастомные настройки Powerlevel10k..."

        # Проверка, существует ли файл .p10k.zsh
        if [[ -f ~/.p10k.zsh ]]; then
            echo "Файл .p10k.zsh уже существует. Заменяю его..."
            rm ~/.p10k.zsh  # Удаляем старый файл
        fi

        # Копирование настроек в скрытый файл .p10k.zsh
        cp "$CUSTOM_P10K_CONFIG" ~/.p10k.zsh
        echo "Настройки успешно скопированы в ~/.p10k.zsh"
    else
        echo "Ошибка: Кастомные настройки Powerlevel10k не найдены на рабочем столе. Пропускаю копирование."
    fi

    # Шаг 7: Проверка, добавлена ли строка source ~/.p10k.zsh в ~/.zshrc
    if ! grep -q "source ~/.p10k.zsh" ~/.zshrc; then
        echo "Добавляю кастомные настройки Powerlevel10k в ~/.zshrc..."
        echo "source ~/.p10k.zsh" >>~/.zshrc  # Добавляем строку в ~/.zshrc
    else
        echo "Кастомные настройки Powerlevel10k уже добавлены в ~/.zshrc."
    fi
    
    # Финальное сообщение об успешной установке
    echo "Установка Powerlevel10k завершена!"
  # Ожидание подтверждения от пользователя
  read -p "После выполнения этих шагов нажмите Enter для продолжения..."
}

# Функция для восстановления настроек терминала
restore_terminal_settings() {
    local SETTINGS_PATH="$HOME/Desktop/TerminalSettings.plist" # Путь к файлу на рабочем столе

    echo "Проверяем наличие файла настроек..."
    if [[ ! -f "$SETTINGS_PATH" ]]; then
        echo "Ошибка: Файл настроек не найден по пути $SETTINGS_PATH!"
        return 1
    fi

    echo "Восстанавливаем настройки терминала..."
    defaults import com.apple.Terminal "$SETTINGS_PATH"

    echo "Определяем профиль по умолчанию..."
    local DEFAULT_PROFILE
    DEFAULT_PROFILE=$(defaults read com.apple.Terminal "Default Window Settings")

    if [[ -z "$DEFAULT_PROFILE" ]]; then
        echo "Ошибка: Профиль по умолчанию не найден!"
        return 1
    fi

    echo "Удаляем все профили, кроме \"$DEFAULT_PROFILE\"..."
    local PROFILES=($(defaults read com.apple.Terminal "Window Settings" | grep -o '".*"' | tr -d '"'))

    for PROFILE in "${PROFILES[@]}"; do
        if [[ "$PROFILE" != "$DEFAULT_PROFILE" ]]; then
            echo "Удаляем профиль: $PROFILE"
            defaults delete com.apple.Terminal "Window Settings" "$PROFILE"
        fi
    done

    echo "Перезапускаем терминал для применения настроек..."
    killall Terminal

    echo "Настройки успешно восстановлены!"
    return 0
  # Ожидание подтверждения от пользователя
  read -p "После выполнения этих шагов нажмите Enter для продолжения..."
}



# Функция для установки последней версии Alacritty
install_latest_alacritty() {
  echo "Получение последней версии Alacritty..."

# Установка последней версии Alacritty через brew
echo "Проверка наличия Alacritty в системе..."
if command -v alacritty &> /dev/null; then
  echo "Alacritty уже установлено в системе."
else
  echo "Alacritty не найдено. Устанавливаю через Homebrew..."

  # Проверка наличия приложения в /Applications
  if [ -d "/Applications/Alacritty.app" ]; then
    echo "Alacritty уже установлено в /Applications, но не через Homebrew."
  else
    # Установка через Homebrew
    brew install --cask alacritty || { echo "Ошибка установки через Homebrew!"; return 1; }
  fi
fi

  # Сообщение об успешной установке
  echo "Alacritty успешно установлен! Однако, возможно, потребуется вручную разрешить его запуск."

  # Объяснение проблемы и шагов по исправлению
  echo "Если macOS заблокирует запуск Alacritty, выполните следующие действия:"
  echo "1. Откройте 'Системные настройки' > 'Защита и безопасность'."
  echo "2. В разделе 'Основные' вы увидите уведомление о том, что Alacritty заблокирован."
  echo "3. Нажмите 'Разрешить' для разрешения на запуск приложения."

  # Ожидание подтверждения от пользователя
  read -p "После выполнения этих шагов нажмите Enter для продолжения..."
  # Ожидание подтверждения от пользователя
  read -p "После выполнения этих шагов нажмите Enter для продолжения..."
}

# Функция для создания конфигурации Alacritty
create_alacritty_config() {
# 1. Удаление старой конфигурации Alacritty, если она существует
  echo "Удаляю старую конфигурацию Alacritty..."
  rm -rf ~/.config/alacritty/

  # 1. Создание папки для конфигурации, если она не существует
  echo "Создаю папку для конфигурации..."
  mkdir -p ~/.config/alacritty/

  # 2. Создание файла конфигурации Alacritty с необходимыми параметрами
  echo "Создаю файл конфигурации..."
  cat <<EOL > ~/.config/alacritty/alacritty.toml
[terminal]
shell = { program = "/opt/homebrew/bin/zsh", args = ["-l"] }

[env]

TERM = "xterm-256color"

[window]

position = { x = 2, y = 2 }
dimensions = { columns = 61, lines = 100 }
padding. x = 20
padding. y = 20
decorations = "Buttonless"
opacity = 0.90
blur = true
option_as_alt = "Both"

[font]
normal = { family = "JetBrainsMono Nerd Font", style = "Bold" }
size = 22.0
EOL

  # 3. Вывод сообщения об успешном создании конфигурации
  echo "Конфигурация Alacritty успешно создана!"

  # 5. Запуск Alacritty (используем путь к приложению)
  echo "Запускаю Alacritty..."
  open -a "Alacritty"
  # Ожидание подтверждения от пользователя
  read -p "После выполнения этих шагов нажмите Enter для продолжения..."
}

# Функция для установки Node.js через Homebrew
install_node() {
  # Проверка, установлен ли Node.js через Homebrew
  if brew list node &> /dev/null; then
    echo "Node.js уже установлен через Homebrew!"
    return 0  # Завершаем выполнение функции, если Node.js уже установлен
  fi

  # Установка Node.js через Homebrew
  echo "Установка Node.js через Homebrew..."
  brew install node

  # Проверка успешности установки Node.js
  if command -v node &> /dev/null; then
    echo "Node.js успешно установлен!"
  else
    echo "Ошибка при установке Node.js."
    return 1
  fi
  # Ожидание подтверждения от пользователя
  read -p "После выполнения этих шагов нажмите Enter для продолжения..."
}

# Функция для установки Vim через Homebrew
install_vim() {
    # Проверяем, установлен ли Vim через Homebrew
    if brew list vim &>/dev/null; then
        # Если Vim уже установлен, выводим сообщение
        echo "Vim уже установлен через Homebrew."
    else
        # Если Vim не установлен, выводим сообщение о начале установки
        echo "Устанавливаю Vim..."
        
        # Попытка установить Vim через Homebrew
        # Если установка прошла успешно, выводим сообщение об успехе
        # Если произошла ошибка при установке, выводим сообщение об ошибке
        brew install vim && echo "Vim успешно установлен." || echo "Ошибка при установке Vim."
    fi
  # Ожидание подтверждения от пользователя
  read -p "После выполнения этих шагов нажмите Enter для продолжения..."
}

# Функция для установки Neovim через Homebrew
install_neovim() {
    # Проверяем, установлен ли Homebrew
    if ! command -v brew &>/dev/null; then
        echo "Homebrew не установлен. Пожалуйста, установите Homebrew."
        return 1
    fi

    # Проверяем, установлен ли Neovim через Homebrew
    if brew list neovim &>/dev/null; then
        # Если Neovim уже установлен, выводим сообщение
        echo "Neovim уже установлен через Homebrew."
    else
        # Если Neovim не установлен, выводим сообщение о начале установки
        echo "Устанавливаю Neovim..."
        
        # Попытка установить Neovim через Homebrew
        # Если установка прошла успешно, выводим сообщение об успехе
        # Если произошла ошибка при установке, выводим сообщение об ошибке
        brew install neovim && echo "Neovim успешно установлен." || echo "Ошибка при установке Neovim."
    fi
  # Ожидание подтверждения от пользователя
  read -p "После выполнения этих шагов нажмите Enter для продолжения..."
}

# Функция для клонирования репозитория
clone_nvchad() {
    # Преобразование ~ в полный путь
    local target_dir="$HOME/.config/nvim"
    
    # Проверка, существует ли папка с конфигурацией Neovim
    if [ ! -d "$target_dir" ]; then
        # Клонирование репозитория, если папка не существует
        echo "Клонируем репозиторий NvChad..."
        git clone https://github.com/NvChad/starter "$target_dir"
        
        # Проверка успешности клонирования
        if [ $? -eq 0 ]; then
            echo "Репозиторий клонирован успешно."
        else
            echo "Ошибка при клонировании репозитория!"
            exit 1
        fi
    else
        echo "Репозиторий уже существует, пропускаем клонирование."
    fi
  # Ожидание подтверждения от пользователя
  read -p "После выполнения этих шагов нажмите Enter для продолжения..."
}

# Функция для добавления настроек прозрачности в конфигурационный файл Neovim
add_transparency_settings() {
  # Путь к конфигурационному файлу Neovim
  local config_file="$HOME/.config/nvim/init.lua"

  # Проверка, существует ли конфигурационный файл
  if [ ! -f "$config_file" ]; then
    echo "Конфигурационный файл Neovim не найден."
    return 1
  fi

  # Проверка, чтобы избежать повторного добавления
  if ! grep -q "hi Normal guibg=none" "$config_file"; then
    # Добавление настроек прозрачности перед vim.schedule(function())
    awk '/vim.schedule\(function\(\)/ { 
        print "vim.cmd([[hi Normal guibg=none]])"
        print "vim.cmd([[hi NonText guibg=none]])"
        print "vim.cmd([[hi SignColumn guibg=none]])"
        print "vim.cmd([[hi NormalNC guibg=none]])"
        print "vim.cmd([[hi EndOfBuffer guibg=none]])"
        print ""  # добавляем пустую строку
    } { print }' "$config_file" > "$config_file.tmp" && mv "$config_file.tmp" "$config_file"
    
    echo "Настройки прозрачности добавлены в конфигурационный файл Neovim."
  else
    echo "Настройки прозрачности уже присутствуют в конфигурационном файле."
  fi

  # Открытие нового окна в iTerm и запуск nvim
    osascript -e 'tell application "iTerm"
        create window with default profile
        tell current session of current window
            write text "nvim"
        end tell
    end tell'

    # Сообщение в основном терминале перед запуском
    echo "Открытие нового терминала и запуск nvim..."
    echo "Нажмите Enter для выхода..."
    read  # Ожидание нажатия Enter в основном терминале
}

# Функция для установки Yarn через Homebrew
install_yarn() {
    # Проверяем, установлен ли Yarn через Homebrew
    if brew list yarn &>/dev/null; then
        # Если Yarn уже установлен, выводим сообщение
        echo "Yarn уже установлен через Homebrew."
    else
        # Если Yarn не установлен, выводим сообщение о начале установки
        echo "Устанавливаю Yarn..."
        
        # Попытка установить Yarn через Homebrew
        # Если установка прошла успешно, выводим сообщение об успехе
        # Если произошла ошибка при установке, выводим сообщение об ошибке
        brew install yarn && echo "Yarn успешно установлен." || echo "Ошибка при установке Yarn."
    fi
  # Ожидание подтверждения от пользователя
  read -p "После выполнения этих шагов нажмите Enter для продолжения..."
}

# Функция для добавления конфигурации плагина в init.lua
add_markdown_preview_plugin() {
    # Абсолютный путь к файлу init.lua
    local config_file="$HOME/.config/nvim/lua/plugins/init.lua"

    # Проверяем, существует ли файл конфигурации
    if [ ! -f "$config_file" ]; then
        echo "Файл конфигурации $config_file не найден."
        return 1
    fi

    # Проверяем, добавлен ли уже плагин
    if grep -q '"iamcco/markdown-preview.nvim"' "$config_file"; then
        echo "Плагин уже добавлен в init.lua."
        return 0
    fi

    # Временный файл для нового содержимого
    local temp_file="$config_file.tmp"

    # Создаём новый файл, добавляя конфигурацию плагина перед последней `}`
    awk '
    BEGIN { added = 0 }
    /^}$/ && !added {
        # Добавляем конфигурацию плагина
        print "  {"
        print "    \"iamcco/markdown-preview.nvim\","
        print "    cmd = { \"MarkdownPreviewToggle\", \"MarkdownPreview\", \"MarkdownPreviewStop\" },"
        print "    build = \"cd app && yarn install\","
        print "    init = function()"
        print "      vim.g.mkdp_filetypes = { \"markdown\" }"
        print "    end,"
        print "    ft = { \"markdown\" },"
        print "  },"
        added = 1
    }
    { print }
    ' "$config_file" > "$temp_file" && mv "$temp_file" "$config_file"

    echo "Плагин markdown-preview.nvim успешно добавлен в init.lua."

  # Открытие нового окна в iTerm и запуск nvim
    osascript -e 'tell application "iTerm"
        create window with default profile
        tell current session of current window
            write text "nvim"
        end tell
    end tell'

    # Сообщение в основном терминале перед запуском
    echo "Открытие нового терминала и запуск nvim..."
    echo "Нажмите Enter для выхода..."
    read  # Ожидание нажатия Enter в основном терминале
  # Ожидание подтверждения от пользователя
  read -p "После выполнения этих шагов нажмите Enter для продолжения..."
}

# Функция для установки fzf, если он не установлен
install_fzf() {
    # Проверка, установлен ли Homebrew
    # Если команда 'brew' не найдена в системе, выводим сообщение об ошибке
    if ! command -v brew &>/dev/null; then
        echo "Homebrew не найден. Пожалуйста, установите его перед продолжением."
        return 1  # Завершаем выполнение функции с кодом ошибки 1
    fi

    # Проверка, установлен ли fzf
    # Если команда 'fzf' найдена, выводим сообщение о том, что fzf уже установлен
    if command -v fzf &>/dev/null; then
        echo "fzf уже установлен."
    else
        # Если fzf не установлен, выполняем установку с помощью Homebrew
        echo "Устанавливаю fzf с помощью brew..."
        brew install fzf

        # Опциональная настройка автозаполнения и интеграции с шеллом
        # Запускаем установочный скрипт fzf для настройки автозаполнения и других опций
        echo "Настройка автозаполнения для fzf..."
        $(brew --prefix)/opt/fzf/install --all
    fi
  # Ожидание подтверждения от пользователя
  read -p "После выполнения этих шагов нажмите Enter для продолжения..."
}

# Функция для установки jq, если он не установлен
install_jq() {
    # Проверка, установлен ли Homebrew
    if ! command -v brew &>/dev/null; then
        echo "Homebrew не найден. Пожалуйста, установите его перед продолжением."
        return 1  # Завершаем выполнение функции с кодом ошибки 1
    fi

    # Проверка, установлен ли jq через Homebrew
    if brew list jq &>/dev/null; then
        echo "jq уже установлен через Homebrew."
    else
        # Если jq не установлен, выполняем установку с помощью Homebrew
        echo "Устанавливаю jq с помощью brew..."
        brew install jq
    fi
  # Ожидание подтверждения от пользователя
  read -p "После выполнения этих шагов нажмите Enter для продолжения..."
}

# Функция для установки tmux, если он не установлен
install_tmux() {
    # Проверка, установлен ли Homebrew
    if ! command -v brew &>/dev/null; then
        echo "Homebrew не найден. Пожалуйста, установите его перед продолжением."
        return 1  # Завершаем выполнение функции с кодом ошибки 1
    fi

    # Проверка, установлен ли tmux через Homebrew
    if brew list tmux &>/dev/null; then
        echo "tmux уже установлен через Homebrew."
    else
        # Если tmux не установлен, выполняем установку с помощью Homebrew
        echo "Устанавливаю tmux с помощью brew..."
        brew install tmux
    fi
  # Ожидание подтверждения от пользователя
  read -p "После выполнения этих шагов нажмите Enter для продолжения..."
}

# Функция для установки ripgrep, если он не установлен
install_ripgrep() {
    # Проверка, установлен ли Homebrew
    if ! command -v brew &>/dev/null; then
        echo "Homebrew не найден. Пожалуйста, установите его перед продолжением."
        return 1  # Завершаем выполнение функции с кодом ошибки 1
    fi

    # Проверка, установлен ли ripgrep через Homebrew
    if brew list ripgrep &>/dev/null; then
        echo "ripgrep уже установлен через Homebrew."
    else
        # Если ripgrep не установлен, выполняем установку с помощью Homebrew
        echo "Устанавливаю ripgrep с помощью brew..."
        brew install ripgrep
    fi
  # Ожидание подтверждения от пользователя
  read -p "После выполнения этих шагов нажмите Enter для продолжения..."
}

# Функция для установки и запуска Amazon Q на macOS
install_amazon_q() {
  # Путь к установленному приложению
  app_path="/Applications/Amazon Q.app"

  # Проверка, установлено ли приложение
  if [ -d "$app_path" ]; then
    echo "Amazon Q уже установлен."
  else
    # Если приложение не установлено, начинаем установку
    echo "Скачиваю Amazon Q для macOS..."

    # URL для скачивания Amazon Q .dmg файла
    url="https://desktop-release.codewhisperer.us-east-1.amazonaws.com/latest/Amazon%20Q.dmg"
    
    # Путь для временного сохранения скачанного файла (на рабочий стол)
    temp_file="$HOME/Desktop/Amazon_Q.dmg"

    # Скачиваем файл с использованием curl
    curl -L -o "$temp_file" "$url"

    # Проверка успешности скачивания
    if [ $? -ne 0 ]; then
      echo "Ошибка при скачивании Amazon Q. Пожалуйста, проверьте соединение с интернетом."
      return 1  # Если скачивание не удалось, завершаем выполнение функции
    fi

    # Монтируем скачанный .dmg файл
    echo "Монтируем диск-образ..."
    hdiutil attach "$temp_file"

    # Проверка успешности монтирования
    if [ $? -ne 0 ]; then
      echo "Ошибка при монтировании диска. Возможно, файл поврежден."
      return 1  # Если монтирование не удалось, завершаем выполнение функции
    fi

    # Устанавливаем приложение Amazon Q в папку /Applications
    echo "Устанавливаю Amazon Q в папку /Applications..."
    cp -r /Volumes/*/Amazon\ Q.app /Applications/

    # Проверка успешности копирования
    if [ $? -ne 0 ]; then
      echo "Ошибка при установке приложения. Попробуйте снова."
      hdiutil detach /Volumes/*  # Размонтируем образ, если установка не удалась
      rm "$temp_file"  # Удаляем временный файл
      return 1  # Завершаем выполнение функции
    fi

    # Размонтируем образ после установки
    hdiutil detach /Volumes/*

    # Удаляем временный файл .dmg
    rm "$temp_file"

    echo "Установка Amazon Q завершена успешно."
  fi

  # Открытие документации для ознакомления
  echo "Открываю документацию для ознакомления..."
  open "https://docs.aws.amazon.com/amazonq/latest/qdeveloper-ug/command-line-installing.html#command-line-installing-macos"

  # Запуск приложения Amazon Q
  echo "Запускаю приложение Amazon Q..."
  open -a "Amazon Q"

  echo "Документация открыта. Приложение Amazon Q запущено."

# Ожидание нажатия клавиши Enter перед завершением
  echo "Нажмите Enter для завершения..."
  read
  # Ожидание подтверждения от пользователя
  read -p "После выполнения этих шагов нажмите Enter для продолжения..."
}

# Функция для установки и проверки Python
install_and_check_python() {
    # Проверка, установлен ли Python
    if ! command -v python3 &>/dev/null; then
        echo "Python не установлен. Устанавливаю..."
        # Установка Python через Homebrew
        if command -v brew &>/dev/null; then
            brew install python
        else
            echo "Homebrew не найден. Установите Homebrew и повторите попытку."
            exit 1
        fi
    fi

    # Определение установленной версии Python
    installed_version=$(python3 --version | awk '{print $2}')
    echo "Установленная версия Python: $installed_version"

    # Проверка валидности Python
    if [[ -z "$installed_version" ]]; then
        echo "Не удалось определить версию Python. Проверьте установку."
        exit 1
    fi
  # Ожидание подтверждения от пользователя
  read -p "После выполнения этих шагов нажмите Enter для продолжения..."
}

# Функция для установки и проверки Rust
install_and_check_rust() {
    local minimum_version="1.70.0"

    # Проверка, установлен ли Rust
    if ! command -v rustc &>/dev/null; then
        echo "Rust не установлен. Устанавливаю через Homebrew..."
        if command -v brew &>/dev/null; then
            brew install rust
        else
            echo "Homebrew не найден. Установите Homebrew и повторите попытку."
            exit 1
        fi
    fi

    # Определение установленной версии Rust
    installed_version=$(rustc --version | awk '{print $2}')
    echo "Установленная версия Rust: $installed_version"

    # Сравнение установленной версии с минимальной
    if [[ "$(printf '%s\n' "$minimum_version" "$installed_version" | sort -V | head -n1)" != "$minimum_version" ]]; then
        echo "Требуется версия Rust не ниже $minimum_version. Обновляю Rust через Homebrew..."
        brew upgrade rust
    else
        echo "Rust версии $installed_version соответствует требованиям."
    fi
  # Ожидание подтверждения от пользователя
  read -p "После выполнения этих шагов нажмите Enter для продолжения..."
}

# Функция для открытия сайта
open_ssh_editor() {
  local url="https://hejki.org/ssheditor/"
  open "$url"
    # Ожидание подтверждения от пользователя
  read -p "После выполнения этих шагов нажмите Enter для продолжения..."
}

# Функция установки Docker
install_docker() {
  echo "Проверка наличия Docker..."
  if ! brew list --cask docker &>/dev/null; then
    echo "Docker не найден. Установка Docker..."
    brew install --cask docker
    echo "Docker успешно установлен."
  else
    echo "Docker уже установлен."
  fi

  echo "Процесс установки завершён."
# Ожидание подтверждения от пользователя
  read -p "После выполнения этих шагов нажмите Enter для продолжения..."
}

# Функция установки Warp
install_warp() {
  echo "Проверка наличия Warp..."

  if [ ! -d "/Applications/Warp.app" ]; then
    echo "Warp не найден. Установка Warp..."
    brew install --cask warp
    echo "Warp успешно установлен."
  else
    echo "Warp уже установлен."
  fi

  echo "Процесс установки завершён."
  # Ожидание подтверждения от пользователя
  read -p "После выполнения этих шагов нажмите Enter для продолжения..."
}

# Функция установки GitKraken и gitkraken-cli
install_gitkraken() {
  echo "Проверка наличия GitKraken..."

  if [ ! -d "/Applications/GitKraken.app" ]; then
    echo "GitKraken не найден. Установка GitKraken..."
    brew install --cask gitkraken
    echo "GitKraken успешно установлен."
  else
    echo "GitKraken уже установлен."
  fi

  echo "Проверка наличия gitkraken-cli..."
  
  if ! command -v gitkraken-cli &>/dev/null; then
    echo "gitkraken-cli не найден. Установка gitkraken-cli..."
    brew install gitkraken-cli
    echo "gitkraken-cli успешно установлен."
  else
    echo "gitkraken-cli уже установлен."
  fi

  echo "Процесс установки завершён."
  # Ожидание подтверждения от пользователя
  read -p "После выполнения этих шагов нажмите Enter для продолжения..."
}

# Функция установки Visual Studio Code
install_vscode() {
  echo "Проверка наличия Visual Studio Code..."

  if [ ! -d "/Applications/Visual Studio Code.app" ]; then
    echo "Visual Studio Code не найден. Установка Visual Studio Code..."
    brew install --cask visual-studio-code
    echo "Visual Studio Code успешно установлен."
  else
    echo "Visual Studio Code уже установлен."
  fi

  echo "Процесс установки завершён."
  # Ожидание подтверждения от пользователя
  read -p "После выполнения этих шагов нажмите Enter для продолжения..."
}

# Функция установки Min Browser
install_minbrowser() {
  echo "Проверка наличия Min Browser..."

  if [ ! -d "/Applications/Min.app" ]; then
    echo "Min Browser не найден. Установка Min Browser..."
    brew install --cask min
    echo "Min Browser успешно установлен."
  else
    echo "Min Browser уже установлен."
  fi

  echo "Процесс установки завершён."
  # Ожидание подтверждения от пользователя
  read -p "После выполнения этих шагов нажмите Enter для продолжения..."
}

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

# Функция для открытия сайта Transmit
open_transmit_website() {
  echo "Открытие сайта Transmit..."

  # Открыть сайт в браузере по умолчанию
  open "https://www.panic.com/transmit/"

  echo "Сайт Transmit открыт."
  # Ожидание подтверждения от пользователя
  read -p "Нажмите Enter для продолжения..."
}

# Функция для открытия сайта Solis
open_solis_website() {
  echo "Открытие сайта Solis..."

  # Открыть сайт в браузере по умолчанию
  open "https://solisapp.com/index.html"

  echo "Сайт Solis открыт."
  # Ожидание подтверждения от пользователя
  read -p "Нажмите Enter для продолжения..."
}

# Выполнение функций
clear_terminal
close_terminal

request_sudo_password
install_homebrew
setup_homebrew_env
change_shell_to_zsh
install_oh_my_zsh

disable_last_login_message
disable_new_mail_message

add_homebrew_to_path
install_nano
open_shells_in_current_terminal

install_git
add_homebrew_path
install_fonts
install_zsh
install_latest_bash
install_zsh_autosuggestions
install_or_update_zsh_syntax_highlighting
install_powerlevel10k
restore_terminal_settings
install_latest_alacritty
create_alacritty_config
install_node
install_vim
install_neovim
clone_nvchad
add_transparency_settings
install_yarn
add_markdown_preview_plugin
install_fzf
install_jq
install_tmux
install_ripgrep
install_amazon_q
# Запуск функции
install_and_check_python
install_and_check_rust
open_ssh_editor
install_docker
install_warp
install_gitkraken
install_vscode
install_minbrowser
install_firefox_dev
open_transmit_website
open_solis_website