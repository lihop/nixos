#!/usr/bin/env bash
# Simplified Hyprland Steam launcher for Kodi
# Hyprland window rules handle window placement, fullscreen, and workspace assignment

set -e

l="script.steam.launcher: "

# Parse arguments (only the ones we need)
STEAM_PATH="$1"
PRE_SCRIPT="$5"
STEAM_PARAMS="$7"
DESKTOP_MODE="$9"

echo "$l Starting Steam launcher"

# Run pre-script if provided
if [[ $PRE_SCRIPT != false ]] ; then
  echo "$l Running pre-script: $PRE_SCRIPT"
  "$PRE_SCRIPT"
fi

# Launch or switch to Steam
# Hyprland rules automatically handle window placement and fullscreen
if [[ $DESKTOP_MODE = true ]] ; then
    echo "$l Launching Steam desktop mode"
    "$STEAM_PATH" $STEAM_PARAMS &
else
    echo "$l Launching/switching to Big Picture Mode"
    # Works whether Steam is running or not - switches to BPM if already open
    "$STEAM_PATH" $STEAM_PARAMS steam://open/bigpicture &
fi

echo "$l Done - Hyprland will handle window management"
