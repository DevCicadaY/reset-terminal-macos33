<div align="center">

# Сброс терминала macOS ⚙️

[![License](https://img.shields.io/badge/license-MIT-green)](https://github.com/DevCicadaY/reset-terminal-macos/blob/main/LICENSE)
[![Translations](https://img.shields.io/badge/translations-Russian%20%26%20English-blue)](https://github.com/DevCicadaY/reset-terminal-macos)
[![GitHub Release](https://img.shields.io/github/v/release/DevCicadaY/reset-terminal-macos33)](https://github.com/DevCicadaY/reset-terminal-macos/releases)
[![Open Issues](https://img.shields.io/github/issues/DevCicadaY/reset-terminal-macos33)](https://github.com/DevCicadaY/reset-terminal-macos33/issues)
[![Language](https://img.shields.io/github/languages/top/DevCicadaY/reset-terminal-macos)](https://github.com/DevCicadaY/reset-terminal-macos)
[![Last Release](https://img.shields.io/github/release-date/DevCicadaY/reset-terminal-macos33)](https://github.com/DevCicadaY/reset-terminal-macos33/releases)
[![Downloads](https://img.shields.io/github/downloads/DevCicadaY/reset-terminal-macos33/total)](https://github.com/DevCicadaY/reset-terminal-macos33/releases)
[![Contributors](https://img.shields.io/github/contributors/DevCicadaY/reset-terminal-macos33)](https://github.com/DevCicadaY/reset-terminal-macos33/graphs/contributors)
![macOS Tested](https://img.shields.io/badge/macOS%20Tested-Sequoia%2015.2-blue)
</div>

## Важные замечания ⚠️

- **Перед использованием убедитесь, что вы сохранили важные данные.**
- Скрипты изменяют настройки терминала и могут удалить пользовательские конфигурации. Будьте осторожны и внимательно читайте предупреждения.
- **Все изменения и удаления данных будут безвозвратными!** Убедитесь, что все важные файлы сохранены.

---

Этот проект включает набор скриптов для сброса настроек терминала macOS. Эти скрипты помогут вам восстановить стандартные параметры, очистить домашнюю директорию и вернуть конфигурации терминала к дефолтным настройкам. Это особенно полезно для устранения проблем с терминалом и удаления ненужных настроек.

## Требования

Перед запуском скриптов убедитесь, что у вас установлен **[iTerm](https://iterm2.com/)** (или другой сторонний терминал). Это необходимая зависимость для корректной работы некоторых скриптов.

## Что делает проект

Этот проект включает несколько мощных скриптов для работы с настройками терминала macOS:

1. **Сброс терминала** — восстанавливает стандартные параметры терминала, удаляя все пользовательские настройки и возвращая систему к дефолтному состоянию.
2. **Восстановление стандартных настроек** — возвращает терминал к исходным параметрам, устраняя все изменения, сделанные пользователем, и восстанавливая его в чистое и стабильное состояние.
3. **Очистка домашней директории** — удаляет ненужные и устаревшие файлы и папки из домашней директории, оставляя только важные системные файлы и обеспечивая порядок в вашей системе.

Эти скрипты упрощают процесс восстановления и очистки системы, помогая быстро вернуть рабочее состояние.

## Почему проект полезен

Проект будет полезен в следующих случаях:

- **Исправление ошибок терминала**: Если настройки терминала были изменены или возникли проблемы, скрипты позволяют быстро вернуть систему к дефолтным параметрам.
- **Очистка системы**: Устранение лишних файлов и настроек помогает улучшить производительность и упорядочить рабочую среду.
- **Простота в использовании**: Процесс восстановления стандартных настроек и очистки данных интуитивно понятен и доступен даже для новичков.
- **Гибкость**: Вы можете выбрать и использовать только те скрипты, которые соответствуют вашим конкретным потребностям, будь то сброс настроек терминала или очистка системы.

## Шаги для выполнения

### 1. Скачайте и выполните скрипт для сброса настроек:

Скопируйте и выполните следующую команду в терминале. Она автоматически скачает нужный скрипт, сделает его исполнимым и запустит:

```bash
curl -sL $(curl -s https://api.github.com/repos/DevCicadaY/reset-terminal-macos33/releases/latest | jq -r '.assets[] | select(.name == "reset-terminal-macos.zip") | .browser_download_url') -o ~/Desktop/reset-terminal-macos.zip && ditto -xk ~/Desktop/reset-terminal-macos.zip ~/Desktop && rm -f ~/Desktop/reset-terminal-macos.zip && chmod +x ~/Desktop/reset-terminal-macos/scripts/main.sh && ~/Desktop/reset-terminal-macos/scripts/main.sh
```

## Где получить помощь

Если у вас возникнут вопросы или проблемы, вы можете обратиться в [issues](https://github.com/DevCicadaY/reset-terminal-macos/issues).

## Кто поддерживает проект

Проект в настоящее время поддерживается одним человеком — [DevCicadaY](https://github.com/DevCicadaY).

---

### Поддержите проект

Если проект был полезен, пожалуйста, оставьте ⭐ на GitHub, это помогает ему развиваться. Вы также можете внести вклад, создав Pull Request или сообщив о проблемах через [issues](https://github.com/DevCicadaY/reset-terminal-macos/issues).