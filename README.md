# touchguard-sequoia-guide

Unofficial guide for running TouchGuard on modern macOS (e.g. Sonoma/Sequoia) with Apple Silicon.

**[Read the online guide →](https://josesuntw.github.io/touchguard-sequoia-guide/)**

> This repository intentionally **does NOT include** the TouchGuard binary or upstream source code.
> You will download TouchGuard from the upstream project and use the LaunchAgent + scripts here.

---

## 中文（快速開始）

### 你會得到什麼？
- 在 macOS Sequoia / Apple Silicon 上，改用 **LaunchAgent（使用者層）** 方式啟動 TouchGuard
- 指令與腳本，讓 TouchGuard 有機會取得 **TCC 權限**（「輔助使用」＋「輸入監控」）

### 為什麼不用 LaunchDaemon？
LaunchDaemon（system/root）常常拿不到使用者授權的 TCC 權限，導致「看起來有跑，但沒有作用」。  
因此本指南使用 LaunchAgent（登入後以使用者 session 啟動）。

---

## English (Quick start)

### What you get
- A **LaunchAgent (user session)** setup for TouchGuard on macOS Sonoma/Sequoia + Apple Silicon
- Scripts/commands to work with macOS **TCC permissions** (Accessibility + Input Monitoring)

### Why not LaunchDaemon?
System/root LaunchDaemons often cannot receive user-granted TCC approvals, resulting in “running but no effect”.
A LaunchAgent runs in the user session after login and can be granted permissions.

---

## Files / 檔案結構

- `launchd/org.amanagr.TouchGuard.agent.plist`  
  LaunchAgent template (logs to `/tmp/TouchGuard.log`).
- `scripts/install_launchagent.sh`  
  Installs TouchGuard to `/usr/local/bin/TouchGuard`, installs LaunchAgent plist, loads it.
- `scripts/uninstall_launchagent.sh`  
  Unloads/removes LaunchAgent and installed files.
- [`docs/permissions.md`](./docs/permissions.md)  
  Quick-reference commands for permissions and log checks.
- [`docs/troubleshooting-sequoia.md`](./docs/troubleshooting-sequoia.md)  
  Detailed troubleshooting guide for macOS Sequoia.

---

## Install / 安裝（LaunchAgent）

### Step 1 — Place TouchGuard binary / 放置 TouchGuard 執行檔
Put the upstream `TouchGuard` executable in the repository root (same level as `scripts/` and `launchd/`).

將上游專案提供的 `TouchGuard` 執行檔放到本 repo 根目錄（和 `scripts/`、`launchd/` 同一層）。

### Step 2 — Run installer / 執行安裝腳本
```bash
cd /path/to/touchguard-sequoia-guide
bash scripts/install_launchagent.sh
```

### Step 3 — Grant permissions (REQUIRED) / 開啟權限（必做）
System Settings → Privacy & Security:
- Accessibility → enable TouchGuard
- Input Monitoring → enable TouchGuard

系統設定 → 隱私權與安全性：
- 輔助使用 → 開啟 TouchGuard
- 輸入監控 → 開啟 TouchGuard

After enabling permissions, restart TouchGuard:
```bash
launchctl kickstart -k gui/$(id -u)/org.amanagr.TouchGuard
```

---

## Verify / 驗證

```bash
launchctl print gui/$(id -u)/org.amanagr.TouchGuard | egrep 'state =|pid =|last exit code|runs ='
pgrep -ax TouchGuard
tail -n 120 /tmp/TouchGuard.log
```

---

## Uninstall / 移除

```bash
cd /path/to/touchguard-sequoia-guide
bash scripts/uninstall_launchagent.sh
```

---

## Troubleshooting / 排錯

For a detailed troubleshooting guide, see [docs/troubleshooting-sequoia.md](./docs/troubleshooting-sequoia.md).  
詳細故障排查指南請參考 [docs/troubleshooting-sequoia.md](./docs/troubleshooting-sequoia.md)。

### A) Running but no effect / 有跑但沒效果
- Confirm both permissions are enabled (Accessibility + Input Monitoring).
- Restart TouchGuard:
```bash
launchctl kickstart -k gui/$(id -u)/org.amanagr.TouchGuard
```

### B) TCC logs / 看 TCC 記錄
```bash
log show --last 30m --predicate '(subsystem == "com.apple.TCC") AND (eventMessage CONTAINS[c] "TouchGuard")' --info
```

### C) Agent not found / 找不到服務
```bash
launchctl print gui/$(id -u)/org.amanagr.TouchGuard
```
If not found, re-bootstrap:
```bash
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/org.amanagr.TouchGuard.plist
launchctl enable gui/$(id -u)/org.amanagr.TouchGuard
launchctl kickstart -k gui/$(id -u)/org.amanagr.TouchGuard
```

---
## Attribution / 致謝與來源

See [`ATTRIBUTION.md`](./ATTRIBUTION.md) for upstream references and credits.  
請參考 [`ATTRIBUTION.md`](./ATTRIBUTION.md)（上游連結與致謝）。


## Disclaimer / 免責聲明
This is an unofficial compatibility guide. No upstream code/binary is redistributed here.
Use at your own risk.
