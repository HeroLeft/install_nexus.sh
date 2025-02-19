#!/bin/bash
# Скрипт для автоматической установки Nexus CLI
# Перед запуском убедитесь, что у вас есть права sudo.
#
# Инструкция по запуску:
# На сервере выполните:
# curl -sSL https://raw.githubusercontent.com/<YOUR_GITHUB_USER>/nexus-install/main/install_nexus.sh | bash
#
# Замените <YOUR_GITHUB_USER> на ваше имя пользователя GitHub.

set -e  # Прерывание выполнения скрипта при ошибке

echo "-----------------------------"
echo "Шаг 1. Обновление системы"
echo "-----------------------------"
sudo apt update -y && sudo apt upgrade -y

echo "-----------------------------"
echo "Шаг 2. Установка необходимых пакетов"
echo "-----------------------------"
sudo apt install -y htop ca-certificates zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev tmux iptables curl nvme-cli git wget make jq libleveldb-dev build-essential pkg-config ncdu tar clang bsdmainutils lsb-release libssl-dev libreadline-dev libffi-dev gcc screen unzip lz4

echo "-----------------------------"
echo "Установка дополнительных инструментов"
echo "-----------------------------"
sudo apt install -y build-essential pkg-config libssl-dev git-all protobuf-compiler unzip

echo "-----------------------------"
echo "Шаг 3. Удаление старой версии protobuf-compiler и установка protoc v21.12"
echo "-----------------------------"
sudo apt remove -y protobuf-compiler
sudo curl -LO https://github.com/protocolbuffers/protobuf/releases/download/v21.12/protoc-21.12-linux-x86_64.zip
sudo unzip protoc-21.12-linux-x86_64.zip -d /usr/local
sudo chmod +x /usr/local/bin/protoc
rm protoc-21.12-linux-x86_64.zip

echo "-----------------------------"
echo "Шаг 4. Установка Rust и настройка окружения"
echo "-----------------------------"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source $HOME/.cargo/env
rustup target add riscv32i-unknown-none-elf

echo "-----------------------------"
echo "Шаг 5. Запуск Nexus CLI в сессии screen"
echo "-----------------------------"
# Запускаем Nexus CLI в новой сессии screen с именем 'nexus'
screen -S nexus -dm bash -c "curl https://cli.nexus.xyz/ | sh; exec bash"

echo "-----------------------------"
echo "Установка завершена!"
echo "Для подключения к сессии выполните: screen -r nexus"
