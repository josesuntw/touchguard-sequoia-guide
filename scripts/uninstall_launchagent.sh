#!/usr/bin/env bash
set -euo pipefail

PLIST_DST="$HOME/Library/LaunchAgents/org.amanagr.TouchGuard.plist"

echo "[1] Unload LaunchAgent"
launchctl bootout "gui/$(id -u)" "$PLIST_DST" 2>/dev/null || true

echo "[2] Remove files"
rm -f "$PLIST_DST"
sudo rm -f /usr/local/bin/TouchGuard
rm -f /tmp/TouchGuard.log

echo "[3] Done"
echo "You may also remove TouchGuard from Accessibility/Input Monitoring lists manually if needed."