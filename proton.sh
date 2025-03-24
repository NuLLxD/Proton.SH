#!/bin/bash

# Proton.SH by NuLLxD based off cehelper by chrisdouglas
# This version does NOT require gum.
# Launch CE in the specified prefix, get the AppId for a running game, or run an arbitrary executable.

clear

# Locate Cheat Engine
CEPATH=$(find "$HOME" -maxdepth 2 -type f -name "cheatengine-x86_64.exe" 2>/dev/null | head -n 1)
if [ -z "$CEPATH" ]; then
  read -rp "Enter the full path to the Cheat Engine directory: " CEPATH
  if [ ! -f "$CEPATH/cheatengine-x86_64.exe" ]; then
    echo "Error: Cheat Engine executable not found in the specified directory."
    clear
    exit 1
  fi
else
  CEPATH=$(dirname "$CEPATH")
fi

# Detect Steam installation path or prompt user
if [ -d "$HOME/.local/share/Steam" ]; then
  STEAMPATH="$HOME/.local/share/Steam"
elif [ -d "$HOME/.var/app/com.valvesoftware.Steam/.steam/steam" ]; then
  STEAMPATH="$HOME/.var/app/com.valvesoftware.Steam/.steam/steam"
else
  echo "No default Steam directory found."
  read -rp "Enter custom Steam directory (absolute path): " STEAMPATH
  if [ ! -d "$STEAMPATH" ]; then
    echo "Error: Invalid Steam directory."
    clear
    exit 1
  fi
fi

COMPDATA="$STEAMPATH/steamapps/compatdata"

# Acquire AppId (may fail if no game is running)
APPID=$(ps -ef | grep -oP "AppId.{0,20}" | cut -sf2- -d= | awk '{print $1}')

# Function to choose a Proton version or custom path
choose_proton() {
  echo "Select a Proton version:"
  echo "1) Proton 9.0.x"
  echo "2) Proton Experimental"
  echo "3) Proton Hotfix"
  echo "4) Custom Proton Path"
  read -rp "Enter choice: " proton_choice

  case "$proton_choice" in
  1)
    PRTEXEC="$STEAMPATH/steamapps/common/Proton 9.0 (Beta)/proton"
    ;;
  2)
    PRTEXEC="$STEAMPATH/steamapps/common/Proton - Experimental/proton"
    ;;
  3)
    PRTEXEC="$STEAMPATH/steamapps/common/Proton Hotfix/proton"
    ;;
  4)
    read -rp "Enter the absolute path to your Proton 'proton' executable: " CUSTOM_PROTON
    if [ ! -f "$CUSTOM_PROTON" ]; then
      echo "Error: Proton not found at specified path."
      clear
      exit 1
    fi
    PRTEXEC="$CUSTOM_PROTON"
    ;;
  *)
    echo "Invalid choice."
    clear
    exit 1
    ;;
  esac

  # Ensure Proton exists
  if [ ! -f "$PRTEXEC" ]; then
    echo "Error: Selected Proton version not found."
    clear
    exit 1
  fi
}

# Main loop
while true; do
  echo "---------------------------------"
  echo "1) Launch Cheat Engine in Active Prefix"
  echo "2) Get APPID"
  echo "3) Run Arbitrary Executable"
  echo "4) Exit Script"
  echo "---------------------------------"
  read -rp "Select an option: " choice

  case "$choice" in
  1)
    # Choose Proton
    choose_proton
    GAME="$APPID"
    STEAM_COMPAT_DATA_PATH="$COMPDATA/$GAME/" STEAM_COMPAT_CLIENT_INSTALL_PATH="$STEAMPATH" \
      "$PRTEXEC" run "$CEPATH/cheatengine-x86_64.exe" </dev/null &>/dev/null &
    echo "Cheat Engine launched in active prefix."
    ;;
  2)
    echo "Running Game AppID: $APPID"
    ;;
  3)
    choose_proton
    read -rp "Enter full path of the executable: " EXEC_PATH
    if [ -f "$EXEC_PATH" ]; then
      STEAM_COMPAT_DATA_PATH="$COMPDATA/$APPID/" STEAM_COMPAT_CLIENT_INSTALL_PATH="$STEAMPATH" \
        "$PRTEXEC" run "$EXEC_PATH" </dev/null &>/dev/null &
      echo "Executable launched successfully."
    else
      echo "Error: File not found at specified path."
    fi
    ;;
  4)
    clear
    exit 0
    ;;
  *)
    echo "Invalid option."
    ;;
  esac

  echo
  read -rp "Press Enter to return to the menu..."
  clear
done
