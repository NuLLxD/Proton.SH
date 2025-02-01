#/bin/bash

# Cheat Engine Helper by Chris Douglas
# Launch CE in the specified prefix, or get the AppId for a running game
# Run after you have launched your Steam Proton game.
# Use the AppId to get the correct prefix to link CE
# Specify an AppID to launch CE, or use the automatic option to launch in the current prefix - this will fail if the CE executable is not present.

PS3='Select choice: '
select choice in "Auto Launch Cheat Engine in active prefix
" "Launch Cheat Engine in specified prefix
" "Get AppId of Running Game
"; do
    case $REPLY in
        [1-3]) break ;;
            *) echo 'Try again' >&2
    esac
done

# Get the executable path of all running processes
# 'grep' for AppId, include the first 20 characters after match
# 'cut' the "AppId=" match fro the result, return only those that match the '=' delimiter
# 'grep' for 1-20 numbers, return only the first match
APPID=`ps -ef | grep -oP "AppId.{0,20}" | cut -sf2- -d= | grep -Eom1 "[0-9]{0,20}"`

if [[ $REPLY -eq 1 || $REPLY -eq 2 ]]; then
    # Runs Cheat Engine in the specified prefix.
    # Note, you must have CE extracted to your system
    # CE executable seems to be required within the game's prefix
    # I use a symbolic link within the prefix. Example:
    # ln -s /home/user/.local/bin/CheatEngine/ [PATH TO PREFIX]/drive_c/CheatEngine

    if [ $# = 0 ]; then
        # Use Automatic option, should be the current running prefix
        GAME="$APPID"
    else
        # Use a user provided steam game id from user's Steam "compdata" location
        GAME="$1"
    fi

    STEAMPATH="$HOME/.local/share/Steam"
    COMPDATA="$STEAMPATH/steamapps/compatdata"
    # This script uses Proton Experimental, modify to suit your needs
    PRTEXEC="$STEAMPATH/steamapps/common/Proton - Experimental/proton"
    CEPATH="$COMPDATA/$GAME/pfx/drive_c/CheatEngine/"

    STEAM_COMPAT_DATA_PATH="$COMPDATA/$GAME/" STEAM_COMPAT_CLIENT_INSTALL_PATH="$STEAMPATH" "$PRTEXEC" run "$CEPATH/cheatengine-x86_64.exe" </dev/null &>/dev/null &
else
 echo "$GAME"
fi
