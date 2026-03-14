# Contributing / 貢獻指南

Thanks for improving this guide! / 感謝你願意一起把這份指南做得更好！

> **Scope / 範圍說明**
> - This repository is a **guide + scripts** project for modern macOS (Sonoma/Sequoia) setup.
> - It does **NOT** redistribute upstream TouchGuard source code or binaries.
> - PRs should focus on docs, scripts, plist templates, and troubleshooting.
>
> 本 repo 是「指南 + 腳本」專案，用於新 macOS 的安裝與排錯。
> 本 repo **不**重新散佈上游 TouchGuard 的程式碼或執行檔。
> PR 以文件、腳本、plist 範本、排錯內容為主。

---

## How to contribute / 如何貢獻

### 1) Fork & branch / Fork 與分支
**English**
1. Fork this repository
2. Create a branch:
   - `fix/...` for bug fixes
   - `docs/...` for documentation updates

**中文**
1. Fork 此 repo
2. 建立分支：
   - `fix/...` 修正問題
   - `docs/...` 文件更新

### 2) Make changes / 修改內容
Typical changes:
- `README.md`
- `docs/*`
- `scripts/*`
- `launchd/*`

### 3) Keep it safe / 安全與隱私（重要）
Please **do not** commit:
- `TouchGuard` binary / executables
- logs (`*.log`), `.DS_Store`
- personal paths, usernames, emails, tokens, or screenshots containing secrets

請 **不要** 提交：
- `TouchGuard` 執行檔/二進位
- log（`*.log`）、`.DS_Store`
- 個人路徑、帳號信箱、token、含敏感資訊的截圖

---

## Testing checklist / 測試清單（建議）

Before opening a PR, verify:
- `scripts/install_launchagent.sh` works on a clean folder layout
- LaunchAgent loads and runs:
  ```bash
  launchctl print gui/$(id -u)/org.amanagr.TouchGuard | egrep 'state =|pid =|last exit code|runs ='
  pgrep -ax TouchGuard
  ```
- Log is written:
  ```bash
  tail -n 80 /tmp/TouchGuard.log
  ```
- Permission steps are accurate:
  - Accessibility
  - Input Monitoring

---

## Reporting issues / 回報問題

### What to include / 建議附上
**English**
- macOS version (e.g. 15.x) and chip (Apple Silicon / Intel)
- Whether Accessibility & Input Monitoring are enabled
- Output (please redact personal info):
  ```bash
  launchctl print gui/$(id -u)/org.amanagr.TouchGuard | egrep 'state =|pid =|last exit code|runs ='
  pgrep -ax TouchGuard
  tail -n 120 /tmp/TouchGuard.log
  ```

**中文**
- macOS 版本（例如 15.x）與晶片（Apple Silicon / Intel）
- 是否已開啟「輔助使用」與「輸入監控」
- 指令輸出（請遮蔽個資）：
  ```bash
  launchctl print gui/$(id -u)/org.amanagr.TouchGuard | egrep 'state =|pid =|last exit code|runs ='
  pgrep -ax TouchGuard
  tail -n 120 /tmp/TouchGuard.log
  ```

---

## Licensing / 授權
Contributions are accepted under this repo’s MIT license (docs & scripts).  
提交的內容會以本 repo 的 MIT（文件與腳本）授權釋出。
