#!/bin/bash
# Скрипт для автоматической установки Nexus CLI (прувера) и всех зависимостей.
# Запускать с правами sudo (или под root).
# Пример запуска:
#   curl -sSL https://raw.githubusercontent.com/<YOUR_GITHUB_USER>/<REPO_NAME>/main/install_nexus.sh | bash
#
# Где <YOUR_GITHUB_USER> — ваш логин на GitHub,
#     <REPO_NAME>        — имя репозитория.

set -e  # Прерывать выполнение при возникновении ошибки

echo "------------------------------------------------"
echo "Шаг 1. Обновление системы"
echo "------------------------------------------------"
sudo apt update -y && sudo apt upgrade -y

echo "------------------------------------------------"
echo "Шаг 2. Установка необходимых пакетов"
echo "------------------------------------------------"
sudo apt install -y build-essential pkg-config libssl-dev git-all cargo unzip screen

# В некоторых гайдах фигурирует protobuf-compiler из репозиториев, устанавливаем, потом обновляем до нужной версии
sudo apt install -y protobuf-compiler

echo "------------------------------------------------"
echo "Шаг 3. Установка и настройка Rust"
echo "------------------------------------------------"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source $HOME/.cargo/env
echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
rustup update

echo "------------------------------------------------"
echo "Шаг 4. Установка и настройка protoc (v25.2)"
echo "------------------------------------------------"
sudo apt remove -y protobuf-compiler
curl -LO https://github.com/protocolbuffers/protobuf/releases/download/v25.2/protoc-25.2-linux-x86_64.zip
unzip protoc-25.2-linux-x86_64.zip -d $HOME/.local
rm protoc-25.2-linux-x86_64.zip
export PATH="$HOME/.local/bin:$PATH"
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
protoc --version

echo "------------------------------------------------"
echo "Шаг 5. Запуск официального скрипта Nexus CLI в screen"
echo "------------------------------------------------"
# Создаём новую сессию screen с именем "nexus" и запускаем внутри неё установку Nexus
screen -S nexus -dm bash -c "curl https://cli.nexus.xyz/ | sh; exec bash"

echo "------------------------------------------------"
echo "Установка завершена!"
echo "------------------------------------------------"
echo "1) Подключитесь к сессии командой: screen -r nexus"
echo "2) Когда Nexus CLI запросит, нажмите 'y' (если потребуется)."
echo "3) Дождитесь окончания компиляции (10-15 минут)."
echo "4) Выберите '2', чтобы привязать Node ID."
echo "5) Вставьте свой Node ID и нажмите Enter."
echo "------------------------------------------------"
echo "Для выхода из screen нажмите: Ctrl+A, затем D."
