#!/usr/bin/env bash
set -euo pipefail

echo "[0] Pre-check"
command -v plutil >/dev/null || { echo "plutil not found"; exit 1; }
command -v launchctl >/dev/null || { echo "launchctl not found"; exit 1; }

BIN_SRC="./TouchGuard"
BIN_DST="/usr/local/bin/TouchGuard"
PLIST_SRC="./launchd/org.amanagr.TouchGuard.agent.plist"
PLIST_DST="$HOME/Library/LaunchAgents/org.amanagr.TouchGuard.plist"

echo "[1] Put TouchGuard binary to $BIN_DST"
if [[ ! -f "$BIN_SRC" ]]; then
  echo "TouchGuard binary not found at $BIN_SRC — downloading from upstream..."
  UPSTREAM_URL="https://github.com/amanagr/TouchGuard/raw/master/TouchGuard"
  if curl -fL --progress-bar -o "$BIN_SRC" "$UPSTREAM_URL"; then
    echo "Download OK"
  else
    echo "ERROR: Download failed. Please download manually:"
    echo "  curl -L $UPSTREAM_URL -o ./TouchGuard"
    exit 1
  fi
fi

chmod +x "$BIN_SRC"
sudo mkdir -p /usr/local/bin
sudo cp "$BIN_SRC" "$BIN_DST"

echo "[2] Install LaunchAgent plist"
mkdir -p "$HOME/Library/LaunchAgents"
cp "$PLIST_SRC" "$PLIST_DST"
plutil -lint "$PLIST_DST"

echo "[3] Load LaunchAgent (user session)"
launchctl bootout "gui/$(id -u)" "$PLIST_DST" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$PLIST_DST"
launchctl enable "gui/$(id -u)/org.amanagr.TouchGuard"
launchctl kickstart -k "gui/$(id -u)/org.amanagr.TouchGuard"

echo "[4] Verify"
launchctl print "gui/$(id -u)/org.amanagr.TouchGuard" | egrep 'state =|pid =|last exit code|runs =' || true
pgrep -ax TouchGuard || true

echo "[5] Grant permissions (required)"
if [[ "${LANG:-}" == zh_* ]]; then
  echo "請至「系統設定 → 隱私權與安全性 → 輔助使用」手動啟用 TouchGuard"
  echo "開啟後執行以下指令重啟服務："
  echo "  launchctl kickstart -k gui/\$(id -u)/org.amanagr.TouchGuard"
  echo "記錄檔：/tmp/TouchGuard.log"
else
  echo "System Settings -> Privacy & Security -> Accessibility: enable TouchGuard"
  echo "After enabling, restart TouchGuard:"
  echo "  launchctl kickstart -k gui/\$(id -u)/org.amanagr.TouchGuard"
  echo "Log: /tmp/TouchGuard.log"
fi