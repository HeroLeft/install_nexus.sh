#!/bin/bash
# Скрипт для автоматической установки Nexus (прувера) и всех необходимых зависимостей.
# Если оперативной памяти меньше 8GB, автоматически создается swap-файл (7GB) с использованием fallocate.
# В конце установка Nexus CLI запускается в сессии screen.
#
# Пример запуска:
# curl -sSL https://raw.githubusercontent.com/HeroLeft/install_nexus.sh/main/install_nexus.sh | bash
#
# В процессе установки, когда Nexus CLI запросит подтверждение,
# выберите "y", затем опцию "2" и введите свой уникальный Node ID.

set -e  # Прерываем выполнение при ошибке

echo "------------------------------------------------"
echo "Nexus. Устанавливаем прувер"
echo "CryptoFortochka — гайды, ноды, новости, тестнеты"
echo "------------------------------------------------"

echo "Обновляем систему и устанавливаем базовые пакеты..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential pkg-config libssl-dev git-all cargo unzip screen curl wget

echo "------------------------------------------------"
echo "Устанавливаем и настраиваем Rust..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source $HOME/.cargo/env
echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
rustup update

echo "------------------------------------------------"
echo "Устанавливаем protoc (версия 25.2)..."
# Сначала устанавливаем системный protobuf-compiler, затем удаляем его для установки нужной версии
sudo apt install -y protobuf-compiler
sudo apt remove -y protobuf-compiler
curl -LO https://github.com/protocolbuffers/protobuf/releases/download/v25.2/protoc-25.2-linux-x86_64.zip
unzip protoc-25.2-linux-x86_64.zip -d $HOME/.local
rm protoc-25.2-linux-x86_64.zip
export PATH="$HOME/.local/bin:$PATH"
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
protoc --version

echo "------------------------------------------------"
echo "Проверяем объем оперативной памяти..."
TOTAL_MEM=$(free -m | awk '/^Mem:/{print $2}')
echo "Общий объем RAM: ${TOTAL_MEM} MB"
if [ "$TOTAL_MEM" -lt 8000 ]; then
    echo "Объем RAM меньше 8GB, создаем swap-файл размером 7GB..."
    sudo fallocate -l 7G /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
    echo "Swap успешно добавлен."
else
    echo "Достаточно оперативной памяти – swap не требуется."
fi

echo "------------------------------------------------"
echo "Создаем сессию screen для установки Nexus CLI..."
# Создаем новую сессию screen с именем "nexus" и запускаем установку Nexus CLI внутри неё
screen -S nexus -dm bash -c "echo 'Установка Nexus CLI начнется через 5 секунд...'; sleep 5; curl https://cli.nexus.xyz/ | sh; exec bash"

echo "------------------------------------------------"
echo "Установка запущена в сессии screen 'nexus'."
echo "------------------------------------------------"
echo "Подключитесь к сессии для интерактивной части установки:"
echo "   screen -r nexus"
echo ""
echo "В процессе установки вам потребуется:"
echo "   1. Нажать 'y' для подтверждения установки."
echo "   2. Выбрать опцию '2' для ввода Node ID."
echo "   3. Ввести свой уникальный Node ID (полученный на сайте)."
echo ""
echo "После ввода всех данных дождитесь завершения компиляции (около 10-15 минут)."
echo "------------------------------------------------"
echo "Чтобы свернуть сессию screen, нажмите: Ctrl+A, затем D."
echo "Чтобы вернуться к сессии, используйте: screen -r nexus"
echo "------------------------------------------------"
echo "Дополнительные команды (при возникновении ошибок):"
echo "   cd ~/.nexus/network-api/clients/cli"
echo "   cargo build --release"
echo "   rustup target add riscv32i-unknown-none-elf"
echo "   ./target/release/nexus-network --start --beta"
echo "------------------------------------------------"
echo "Чтобы удалить ноду, выполните:"
echo "   screen -S nexus -X quit && rm -rf ~/.nexus/"
