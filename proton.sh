#!/bin/bash

# Proton.SH by NuLLxD, based on cehelper by chrisdouglas
# Launch Cheat Engine, find AppID, or run an arbitrary executable in a Steam Proton environment

clear

# Detect Cheat Engine path automatically or ask for input
CEPATH=$(find "$HOME" -maxdepth 2 -type f -name "cheatengine-x86_64.exe" 2>/dev/null | head -n 1)
if [ -z "$CEPATH" ]; then
    read -rp "Enter the full path to the Cheat Engine directory: " CEPATH
    if [ ! -f "$CEPATH/cheatengine-x86_64.exe" ]; then
        echo "Error: Cheat Engine executable not found in the specified directory."
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
else
    echo "Error: Steam installation not found."
    exit 1
fi

COMPDATA="$STEAMPATH/steamapps/compatdata"

# Detect running game AppID
APPID=$(ps -ef | grep -oP "AppId.{0,20}" | cut -sf2- -d= | awk '{print $1}')

# Function to detect Proton version & path
detect_proton() {
    PROTON_CONFIG_INFO="$COMPDATA/$APPID/config_info"

    if [ -f "$PROTON_CONFIG_INFO" ]; then
        # Extract the second line (contains Proton install path)
        FULL_PATH=$(sed -n '2p' "$PROTON_CONFIG_INFO")

        if [[ "$FULL_PATH" =~ (/steamapps/common/Proton[^/]*)/ ]]; then
            PROTON_DIR="${BASH_REMATCH[1]}"
            PRTEXEC="$STEAMPATH$PROTON_DIR/proton"

            if [ -x "$PRTEXEC" ]; then
                return 0
            else
                echo "Warning: Proton binary not found at expected path ($PRTEXEC)."
                return 1
            fi
        fi
    fi

    echo "Warning: Could not determine Proton installation path automatically."
    return 1
}

# Function to return to the main menu or exit
return_or_exit() {
    echo -e "\n1) Return to Main Menu"
    echo "2) Exit Script"
    read -rp "Select an option: " action

    if [ "$action" = "1" ]; then
        exec "$0"
    else
        clear
        exit 0
    fi
}

# Auto-detect Proton
if ! detect_proton; then
    echo "Select Proton version manually:"
    echo "1) Proton 9.0.x"
    echo "2) Proton Experimental"
    echo "3) Proton Hotfix"
    echo "4) Enter custom Proton path"
    read -rp "Choice: " PROTON_CHOICE

    case "$PROTON_CHOICE" in
        1) PRTEXEC="$STEAMPATH/steamapps/common/Proton 9.0 (Beta)/proton" ;;
        2) PRTEXEC="$STEAMPATH/steamapps/common/Proton - Experimental/proton" ;;
        3) PRTEXEC="$STEAMPATH/steamapps/common/Proton Hotfix/proton" ;;
        4) read -rp "Enter full Proton path: " PRTEXEC ;;
        *) echo "Invalid choice."; exit 1 ;;
    esac
fi

# Main Menu
while true; do
    echo -e "\n========== Proton.SH =========="
    echo "1) Launch Cheat Engine in Active Prefix"
    echo "2) Get Running Game AppID"
    echo "3) Run Arbitrary Executable"
    echo "4) Open Windows Command Prompt"
    echo "5) Exit Script"
    read -rp "Select an option: " choice

    case "$choice" in
        1)  # Launch Cheat Engine
            STEAM_COMPAT_DATA_PATH="$COMPDATA/$APPID/" STEAM_COMPAT_CLIENT_INSTALL_PATH="$STEAMPATH" "$PRTEXEC" run "$CEPATH/cheatengine-x86_64.exe" &>/dev/null &
            echo "Cheat Engine launched in active prefix."
            return_or_exit
            ;;
        2)  # Get APPID
            echo "Running Game AppID: $APPID"
            return_or_exit
            ;;
        3)  # Run Arbitrary Executable
            read -rp "Enter full path of the executable: " EXEC_PATH
            if [ -f "$EXEC_PATH" ]; then
                STEAM_COMPAT_DATA_PATH="$COMPDATA/$APPID/" STEAM_COMPAT_CLIENT_INSTALL_PATH="$STEAMPATH" "$PRTEXEC" run "$EXEC_PATH" &>/dev/null &
                echo "Executable launched successfully."
            else
                echo "Error: File not found at specified path."
            fi
            return_or_exit
            ;;
        4)  # Open Windows Command Prompt
            STEAM_COMPAT_DATA_PATH="$COMPDATA/$APPID/" STEAM_COMPAT_CLIENT_INSTALL_PATH="$STEAMPATH" "$PRTEXEC" run cmd.exe
            return_or_exit
            ;;
        5)  # Exit
            clear
            exit 0
            ;;
        *) echo "Invalid choice. Please select a valid option." ;;
    esac
done
