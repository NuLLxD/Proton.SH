#!/bin/bash

# Cheat Engine Helper by Chris Douglas
# Launch CE in the specified prefix, or get the AppId for a running game
# Run after you have launched your Steam Proton game.
# Use the AppId to get the correct prefix to link CE
# Specify an AppID to launch CE, or use the automatic option to launch in the current prefix - this will fail if the CE executable is not present.

# Update to match the installed directory for Cheat Engine
CEPATH="$HOME/CheatEngine/"

STEAMPATH="$HOME/.local/share/Steam"
COMPDATA="$STEAMPATH/steamapps/compatdata"
# This script uses Proton Experimental, modify to suit your needs
PRTEXEC="$STEAMPATH/steamapps/common/Proton - Experimental/proton"

# Acquire AppId
# Get the executable path of all running processes
# 'grep' for AppId, include the first 20 characters after match
# 'cut' the "AppId=" match from the result, return only those that match the '=' delimiter
# 'awk' returns the first "column" of output, trimmed of whitespace
APPID=$(ps -ef | grep -oP "AppId.{0,20}" | cut -sf2- -d= | awk '{print $1}')

if [ $# = 0 ]; then
    PS3='Select choice: '
    select choice in "Auto Launch Cheat Engine in active prefix
    " "Get AppId of Running Game
    "; do
        case $REPLY in
            [1-2]) break ;;
                *) echo 'Try again' >&2
        esac
    done
else
    REPLY=1
fi

if [ $REPLY -eq 1 ]; then
    # Runs Cheat Engine in the specified prefix.
    if [ $# = 0 ]; then
        # Use Automatic option, should be the current running prefix
        GAME="$APPID"
    else
        # Use the AppId passed into the script by the user.
        GAME="$1"
    fi
    STEAM_COMPAT_DATA_PATH="$COMPDATA/$GAME/" STEAM_COMPAT_CLIENT_INSTALL_PATH="$STEAMPATH" "$PRTEXEC" run "$CEPATH/cheatengine-x86_64.exe" </dev/null &>/dev/null &
else
 # Display only the AppId, do not launch Cheat Engine
 echo "$APPID"
fi
