#!/bin/bash

# Функция для логирования сообщений
log_message() {
    local message="$1"
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $message"
}

# Функция для удаления всех конфигурационных файлов
remove_all_config_files() {
    log_message "Начинаю удаление всех пользовательских конфигурационных файлов..."

    # Конфигурационные файлы Zsh
    local zsh_files=(
        "$HOME/.zshrc"
        "$HOME/.zshenv"
        "$HOME/.zprofile"
        "$HOME/.zlogin"
        "$HOME/.zlogout"
    )

    for file in "${zsh_files[@]}"; do
        if [ -f "$file" ]; then
            log_message "Удаляю $file"
            rm -f "$file"
        else
            log_message "$file не найден"
        fi
    done

    # Конфигурационные файлы Bash
    local bash_files=(
        "$HOME/.bash_profile"
        "$HOME/.bashrc"
        "$HOME/.profile"
        "$HOME/.bash_logout"
    )

    for file in "${bash_files[@]}"; do
        if [ -f "$file" ]; then
            log_message "Удаляю $file"
            rm -f "$file"
        else
            log_message "$file не найден"
        fi
    done

    # Удаление других конфигурационных файлов (если есть)
    local other_files=(
        "$HOME/.inputrc"
        "$HOME/.gitconfig"
        "$HOME/.config/fish/config.fish"
    )

    for file in "${other_files[@]}"; do
        if [ -f "$file" ]; then
            log_message "Удаляю $file"
            rm -f "$file"
        else
            log_message "$file не найден"
        fi
    done
}

# Функция для восстановления настроек оболочки по умолчанию
restore_default_shell() {
    log_message "Начинаю восстановление настроек оболочки по умолчанию..."

    # Восстановление стандартного ~/.bash_profile
    cat <<EOF > "$HOME/.bash_profile"
export PATH="/usr/local/bin:\$PATH"
export PATH="\$HOME/bin:\$PATH"
export PS1="\u@\h:\w\$ "
EOF
    log_message "~/.bash_profile восстановлен"

    # Восстановление стандартного ~/.bashrc
    cat <<EOF > "$HOME/.bashrc"
# ~/.bashrc: выполняется для оболочек bash, не являющихся входными.
if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi
EOF
    log_message "~/.bashrc восстановлен"

    # Восстановление стандартного ~/.profile
    cat <<EOF > "$HOME/.profile"
# ~/.profile: выполняется при входных оболочках, совместимых с Bourne.
if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi
EOF
    log_message "~/.profile восстановлен"
}

# Функция для проверки текущей оболочки
check_current_shell() {
    log_message "Проверяю текущую оболочку..."
    current_shell=$(echo $SHELL)
    log_message "Текущая оболочка: $current_shell"
}

# Функция для сброса оболочки по умолчанию на bash
reset_default_shell() {
    log_message "Меняю оболочку по умолчанию на /bin/bash..."

    # Получение текущей оболочки
    current_shell=$(echo $SHELL)

    # Проверка, если оболочка уже bash
    if [ "$current_shell" != "/bin/bash" ]; then
        sudo chsh -s /bin/bash "$USER" &>/dev/null

        # Проверка, была ли команда успешной
        if [ $? -eq 0 ]; then
            log_message "Оболочка по умолчанию успешно изменена на /bin/bash"
        else
            log_message "Ошибка при изменении оболочки. Убедитесь, что у вас есть права администратора."
        fi
    else
        log_message "Оболочка уже установлена как /bin/bash"
    fi
}

# Выполнение функций
remove_all_config_files
restore_default_shell
check_current_shell
reset_default_shell

log_message "Сброс завершён. Пожалуйста, перезапустите терминал для применения изменений."