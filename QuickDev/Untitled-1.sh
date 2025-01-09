~/Desktop/setup_zsh.sh


curl -sL $(curl -s https://api.github.com/repos/DevCicadaY/reset-terminal-macos33/releases/latest | jq -r '.assets[] | select(.name == "reset-terminal-macos.zip") | .browser_download_url') -o ~/Desktop/reset-terminal-macos.zip && ditto -xk ~/Desktop/reset-terminal-macos.zip ~/Desktop && rm -f ~/Desktop/reset-terminal-macos.zip && chmod +x ~/Desktop/reset-terminal-macos/scripts/main.sh && ~/Desktop/reset-terminal-macos/scripts/main.sh

defaults export com.apple.Terminal ~/Desktop/TerminalSettings.plist

~/Desktop/test.sh

QuickDev/
├── bin/                # Скрипты для установки и настройки
│   ├── install.sh
│   └── setup.sh
├── config/             # Конфигурационные файлы
│   └── config.yaml
├── docs/               # Документация
│   └── README.md
├── src/                # Исходный код
│   ├── core/           # Основные скрипты/функции
│   │   ├── install.sh  # Общие скрипты установки
│   │   └── setup.sh    # Общие скрипты настройки
│   └── modules/        # Модули для разных языков
│       ├── nodejs/     # Модуль для Node.js
│       │   ├── install.sh
│       │   └── setup.sh
│       ├── python/     # Модуль для Python
│       │   ├── install.sh
│       │   └── setup.sh
│       ├── java/       # Модуль для Java
│       │   ├── install.sh
│       │   └── setup.sh
│       └── cpp/        # Модуль для C++
│           ├── install.sh
│           └── setup.sh
├── tests/              # Тесты
│   ├── test_nodejs.sh  # Тесты для Node.js
│   ├── test_python.sh  # Тесты для Python
│   ├── test_java.sh    # Тесты для Java
│   └── test_cpp.sh     # Тесты для C++
└── .gitignore          # Игнорируемые файлы для git