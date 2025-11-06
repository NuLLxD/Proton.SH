#!/bin/bash

# Proton.SH by NuLLxD

clear

# Define colors
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
CYAN='\e[36m'
BOLD='\e[1m'
RESET='\e[0m'

header() {
  echo -e "${BLUE}${BOLD}====================================="
  echo -e "             Proton.SH        "
  echo -e "=====================================${RESET}"
}

gamename() {
  local appid=$1
  local response
  response=$(curl -s "https://store.steampowered.com/api/appdetails?appids=${appid}")
  echo "$response" | grep -oP '"name":"\K[^"]+' | head -n1
}

execauto() {
  local cur_word=${COMP_WORDS[COMP_CWORD]}
  COMPREPLY=( $(compgen -f -- "$cur_word" | grep -iE '\.exe$') )
}

complete -F execauto execpath

execpath() {
  echo -e "${CYAN}Enter full path of the executable:${RESET}"
  read -e -rp "→ " RAW_INPUT
  EXEC_PATH=$(eval echo "$RAW_INPUT")

  if [ -f "$EXEC_PATH" ]; then
    STEAM_COMPAT_DATA_PATH="$compData/$appid/" \
    STEAM_COMPAT_CLIENT_INSTALL_PATH="$steamPath" \
    "$prtExec" run "$EXEC_PATH" &>/dev/null &
    echo -e "${GREEN}Executable launched: $EXEC_PATH${RESET}"
    sleep 2
  else
    echo -e "${RED}Error: File not found!${RESET}"
    sleep 2
  fi
}

# Detect Cheat Engine path
cePath=$(find "$HOME" -maxdepth 2 -type f -name "cheatengine-x86_64.exe" 2>/dev/null | head -n 1)
if [ -n "$cePath" ]; then
  cePath=$(dirname "$cePath")
  ceFound=true
else
  ceFound=false
  echo -e "${YELLOW}Cheat Engine not found.${RESET}"
  echo -e "${YELLOW}Press any key to continue...${RESET}"
  read -n 1 -s
fi

# Detect Steam path
if [ -d "$HOME/.local/share/Steam" ]; then
  steamPath="$HOME/.local/share/Steam"
elif [ -d "$HOME/.var/app/com.valvesoftware.Steam/.steam/steam" ]; then
  steamPath="$HOME/.var/app/com.valvesoftware.Steam/.steam/steam"
elif [ -d "$HOME/.steam/root" ]; then
  steamPath="$HOME/.steam/root"
else
  echo -e "${RED}Error: Steam installation not found!${RESET}"
  exit 1
fi

compData="$steamPath/steamapps/compatdata"

# Wait for Proton
while true; do
  pids=($(pgrep -f 'proton'))
  if [ ${#pids[@]} -gt 0 ]; then break; fi
  clear
  header
  echo -e "${YELLOW}Waiting for Proton instance to be started...${RESET}"
  sleep 2
done

# Detect active Proton prefix
detectAppid() {
  local prefixes
  prefixes=$(lsof -Fn 2>/dev/null | grep "/pfx" | grep -oE "$compData/[0-9]+" | sort -u)
  if [[ -z "$prefixes" ]]; then return 1; fi
  appid=$(basename "$(echo "$prefixes" | head -n 1)")
  export appid
}

# Detect Proton version from config_info
detectProtonPath() {
    local cfg="$compData/$appid/config_info"
    if [[ ! -f "$cfg" ]]; then return 1; fi

    # Get the path from the second line of the config file
    local proton_font_path
    proton_font_path=$(sed -n '2p' "$cfg")

    # Check if the path format is as expected and extract the root directory
    if [[ "$proton_font_path" == *"/files/share/fonts/"* ]]; then
        # The actual Proton installation is three directories above the font path
        dirname "$(dirname "$(dirname "$proton_font_path")")"
    else
        return 1
    fi
}

# Prompt for Proton manually
promptProton() {
  local dir="$steamPath/compatibilitytools.d"
  echo -e "${CYAN}Available Proton versions:${RESET}"
  select v in "$dir"/*/; do
    basename "$v"
    return
  done
}

# Run detection steps
if ! detectAppid; then
  echo -e "${RED}No running Proton prefixes found.${RESET}"
  exit 1
fi

# Try to get Proton path automatically
prtPath=$(detectProtonPath)

# Fallback to manual selection if auto-detection fails
if [[ -z "$prtPath" || ! -d "$prtPath" ]]; then
  echo -e "${YELLOW}Could not auto-detect Proton version. Please select one manually.${RESET}"
  prtVer=$(promptProton)
  prtPath="$steamPath/compatibilitytools.d/$prtVer"
fi

prtExec="$prtPath/proton"

# Validate proton executable
if [ ! -x "$prtExec" ]; then
  echo -e "${RED}Error: Proton executable not found at $prtExec${RESET}"
  exit 1
fi

# Main menu
while true; do
  clear
  header
  gameName=$(gamename "$appid")
  echo -e "${CYAN}Active Prefix: $appid - ${gameName:-Unknown}${RESET}"
  echo -e "${BLUE}${BOLD}=====================================${RESET}" 
  echo -e "${GREEN}[1]${RESET} Launch Cheat Engine"
  echo -e "${GREEN}[2]${RESET} Run Executable"
  echo -e "${GREEN}[3]${RESET} Open Command Prompt"
  echo -e "${GREEN}[4]${RESET} Debug Info"
  echo -e "${GREEN}[5]${RESET} Switch Proton Instance"
  echo -e "${RED}[6] Exit${RESET}"
  read -rp "→ " choice

  case "$choice" in
  1)
    if [ "$ceFound" = false ]; then
      echo -e "${RED}Cheat Engine not available.${RESET}"
      sleep 2
      continue
    fi
    STEAM_COMPAT_DATA_PATH="$compData/$appid/" \
    STEAM_COMPAT_CLIENT_INSTALL_PATH="$steamPath" \
    "$prtExec" run "$cePath/Cheat Engine.exe" &>/dev/null &
    echo -e "${GREEN}Cheat Engine launched.${RESET}"
    sleep 2
    ;;
  2)
    execpath
    ;;
  3)
    nohup bash -c "STEAM_COMPAT_DATA_PATH=\"$compData/$appid/\" STEAM_COMPAT_CLIENT_INSTALL_PATH=\"$steamPath\" \"$prtExec\" run cmd.exe" &>/dev/null &
    echo -e "${GREEN}Command Prompt opened.${RESET}"
    sleep 2
    ;;
  4)
    echo -e "${CYAN}Debug Info:${RESET}"
    echo -e "AppID: $appid - ${gameName:-Unknown}"
    echo -e "Steam Path: $steamPath"
    echo -e "CompatData: $compData"
    echo -e "Proton Path: $prtPath"
    echo -e "Proton Exec: $prtExec"
    echo -e "Cheat Engine: $cePath"
    echo -e "${YELLOW}Press any key to return...${RESET}"
    read -n 1 -s
    ;;
  5)
    exec "$0"
    ;;
  6)
    clear; exit 0 ;;
  *) echo -e "${RED}Invalid choice.${RESET}" ;;
  esac
done
