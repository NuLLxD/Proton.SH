#!/bin/bash

# Proton.SH by NuLLxD - Now with colors~
# Based off cehelper by chrisgdouglas

clear

# Define colors
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
CYAN='\e[36m'
BOLD='\e[1m'
RESET='\e[0m'

# Function to display the stylish header
display_header() {
  echo -e "${BLUE}${BOLD}====================================="
  echo -e "             Proton.SH        "
  echo -e "=====================================${RESET}"
}

# Detect Cheat Engine path
CEPATH=$(find "$HOME" -maxdepth 2 -type f -name "cheatengine-x86_64.exe" 2>/dev/null | head -n 1)
if [ -z "$CEPATH" ]; then
  echo -e "${CYAN}Enter the full path to Cheat Engine:${RESET}"
  read -rp "→ " CEPATH
  if [ ! -f "$CEPATH/cheatengine-x86_64.exe" ]; then
    echo -e "${RED}Error: Cheat Engine executable not found!${RESET}"
    exit 1
  fi
else
  CEPATH=$(dirname "$CEPATH")
fi

# Detect Steam installation path
if [ -d "$HOME/.local/share/Steam" ]; then
  STEAMPATH="$HOME/.local/share/Steam"
elif [ -d "$HOME/.var/app/com.valvesoftware.Steam/.steam/steam" ]; then
  STEAMPATH="$HOME/.var/app/com.valvesoftware.Steam/.steam/steam"
elif [ -d "$HOME/.steam/root" ]; then
  STEAMPATH="$HOME/.steam/root"
else
  echo -e "${RED}Error: Steam installation not found!${RESET}"
  exit 1
fi

COMPDATA="$STEAMPATH/steamapps/compatdata"

# Detect AppID of the currently running game
APPID=$(ps -ef | grep -oP "AppId.{0,20}" | cut -sf2- -d= | awk '{print $1}')

# Function to detect Proton version
detect_proton() {
  PROTON_CONFIG_INFO="$COMPDATA/$APPID/config_info"

  if [ -f "$PROTON_CONFIG_INFO" ]; then
    FULL_PATH=$(sed -n '2p' "$PROTON_CONFIG_INFO")
    if [[ "$FULL_PATH" =~ (/steamapps/common/Proton[^/]*)/ ]]; then
      PROTON_DIR="${BASH_REMATCH[1]}"
      PRTEXEC="$STEAMPATH$PROTON_DIR/proton"
      if [ -x "$PRTEXEC" ]; then
        return 0
      fi
    fi
  fi

  # Check for custom Proton versions, excluding LegacyRuntime
  CUSTOM_PROTON_PATH="$HOME/.steam/root/compatibilitytools.d"
  if [ -d "$CUSTOM_PROTON_PATH" ]; then
    CUSTOM_PROTONS=($(find "$CUSTOM_PROTON_PATH" -mindepth 1 -maxdepth 1 -type d ! -name "LegacyRuntime"))
    
    if [ ${#CUSTOM_PROTONS[@]} -eq 1 ]; then
      # Only one custom Proton found, auto-select it
      PRTEXEC="${CUSTOM_PROTONS[0]}/proton"
      return 0
    elif [ ${#CUSTOM_PROTONS[@]} -gt 1 ]; then
      # More than one custom Proton found, let the user choose
      echo -e "${CYAN}Available Custom Proton Versions:${RESET}"
      for i in "${!CUSTOM_PROTONS[@]}"; do
        echo -e "${GREEN}[$((i+1))]${RESET} ${CUSTOM_PROTONS[$i]}"
      done
      read -rp "Choose a Proton version: " CUSTOM_CHOICE
      PRTEXEC="${CUSTOM_PROTONS[$((CUSTOM_CHOICE-1))]}/proton"
      return 0
    fi
  fi

  echo -e "${YELLOW}Warning: Could not determine Proton path.${RESET}"
  return 1
}

# Detect or manually select Proton version
if ! detect_proton; then
  echo -e "${CYAN}Select Proton version:${RESET}"
  echo -e "${GREEN}[1]${RESET} Proton 9.0.x"
  echo -e "${GREEN}[2]${RESET} Proton Experimental"
  echo -e "${GREEN}[3]${RESET} Proton Hotfix"
  echo -e "${GREEN}[4]${RESET} Enter custom Proton path"
  read -rp "→ " PROTON_CHOICE

  case "$PROTON_CHOICE" in
  1) PRTEXEC="$STEAMPATH/steamapps/common/Proton 9.0 (Beta)/proton" ;;
  2) PRTEXEC="$STEAMPATH/steamapps/common/Proton - Experimental/proton" ;;
  3) PRTEXEC="$STEAMPATH/steamapps/common/Proton Hotfix/proton" ;;
  4) read -rp "Enter full Proton path: " PRTEXEC ;;
  *)
    echo -e "${RED}Invalid choice.${RESET}"
    exit 1
    ;;
  esac
fi

# Main Menu Loop
while true; do
  clear
  display_header  # Print the stylish header

  echo -e "${GREEN}[1]${RESET} Launch Cheat Engine in Active Prefix"
  echo -e "${GREEN}[2]${RESET} Run Arbitrary Executable"
  echo -e "${GREEN}[3]${RESET} Open Windows Command Prompt"
  echo -e "${GREEN}[4]${RESET} Debug Environment Info"
  echo -e "${RED}[5] Exit Script${RESET}"
  read -rp "→ " choice

  case "$choice" in
  1) # Launch Cheat Engine
    STEAM_COMPAT_DATA_PATH="$COMPDATA/$APPID/" STEAM_COMPAT_CLIENT_INSTALL_PATH="$STEAMPATH" "$PRTEXEC" run "$CEPATH/cheatengine-x86_64.exe" &>/dev/null &
    echo -e "${GREEN}Cheat Engine launched successfully!${RESET}"
    sleep 2
    ;;
  2) # Run Arbitrary Executable
    echo -e "${CYAN}Enter full path of the executable:${RESET}"
    read -rp "→ " EXEC_PATH
    if [ -f "$EXEC_PATH" ]; then
      STEAM_COMPAT_DATA_PATH="$COMPDATA/$APPID/" STEAM_COMPAT_CLIENT_INSTALL_PATH="$STEAMPATH" "$PRTEXEC" run "$EXEC_PATH" &>/dev/null &
      echo -e "${GREEN}Executable launched successfully: $EXEC_PATH${RESET}"
      sleep 2
    else
      echo -e "${RED}Error: File not found!${RESET}"
      sleep 2
    fi
    ;;
  3) # Open Windows Command Prompt
    nohup bash -c "STEAM_COMPAT_DATA_PATH=\"$COMPDATA/$APPID/\" STEAM_COMPAT_CLIENT_INSTALL_PATH=\"$STEAMPATH\" \"$PRTEXEC\" run cmd.exe" &>/dev/null &
    echo -e "${GREEN}Windows Command Prompt opened.${RESET}"
    sleep 2
    ;;
  4) # Debug Environment Info
    echo -e "${CYAN}Debug Information:${RESET}"
    echo -e "APPID: $APPID"
    echo -e "Cheat Engine Path: $CEPATH"
    echo -e "Steam Path: $STEAMPATH"
    echo -e "Compatibility Data Path: $COMPDATA"
    echo -e "Proton Executable: $PRTEXEC"
    echo -e "${YELLOW}Press any key to return to the main menu...${RESET}"
    read -n 1 -s
    ;;
  5) # Exit
    clear
    exit 0
    ;;
  *) echo -e "${RED}Invalid choice. Try again.${RESET}" ;;
  esac
done
