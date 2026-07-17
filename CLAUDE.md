<!-- workspace-schema: v1 -->
# [專案名稱]

## 專案說明

> **文件分工**：
> - `CLAUDE.md`（本文件）→ **使用說明**：如何操作 workspace 產出成果
> - `_dev/DEV.md` → **開發說明**：skill/agent 如何建立、同步、打包（不隨 workspace 交付）

[一句話描述這個專案的用途]

## 技術棧
- 語言：
- 框架：
- 套件管理：

## 目錄結構
[重要目錄列表]

## 開發規範
- 縮排：
- 命名：
- 提交訊息：[e.g. feat: / fix: / docs: 前綴]

## 文件同步規則

| 異動類型 | 主動檢查項目 |
|---------|------------|
| `docs/*.md` 有變動 | `README.md` 中的連結與說明是否仍符合 |
| `scripts/*.sh` 有變動 | `README.md`（安裝/移除步驟）、`docs/permissions.md`（指令） |
| `launchd/*.plist`（Label 或路徑）有變動 | `docs/troubleshooting-sequoia.md`（bundle ID / plist 路徑指令）、`README.md` |
| `CONTRIBUTING.md` 有變動 | `README.md`（如有連結） |

## 常用指令

### 開發環境啟動

### 執行測試

### 建置

## 注意事項
-

## 異動歷程
- [2026-07-03] 初始建立
