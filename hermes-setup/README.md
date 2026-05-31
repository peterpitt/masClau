# Hermes Agent 安裝 + Discord 對話設定教學（Windows）

把 [NousResearch/hermes-agent](https://github.com/nousresearch/hermes-agent) 安裝到你的電腦
（`C:\Users\tt\Documents\Claude\Projects\hermas\`),設定模型,並接上 Discord,
**跑出一個可以雙向對話的 bot**。

---

## ⚠️ 開始前必讀(三個重點)

1. **要對話 → 必須用 Discord「Bot Token」,不是 webhook。**
   官方文件明確說明 Hermes **完全不使用 webhook URL**。webhook 只能「單向送訊息」到頻道,
   無法「收訊息」,所以 **webhook 做不出對話**。要聊天一定要建立一個 Discord Bot。

2. **🔒 安全:先處理外洩的 webhook。**
   如果你曾把含密鑰的 webhook 網址貼給別人或貼在公開處,請到
   `Discord 頻道設定 → 整合 → Webhook` 把它**刪除或重設**。
   任何拿到那段網址的人都能冒名往你頻道發訊息。

3. **需要一把模型 API 金鑰。**
   agent 要能「回話」需要連到大型語言模型(Nous Portal / OpenRouter / OpenAI / 自架端點)。
   安裝後用精靈設定即可。

---

## 方法 A:一鍵腳本(推薦)

1. 開啟 **PowerShell**,切到專案資料夾並放行本次執行原則:
   ```powershell
   cd C:\Users\tt\Documents\Claude\Projects\hermas\
   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
   ```
2. 把本資料夾的 `install-hermes.ps1` 放到該資料夾,執行:
   ```powershell
   .\install-hermes.ps1
   ```
3. 腳本會依序帶你完成:安裝 → 健檢 → 設定模型 → 建立 Discord Bot → 接上 gateway → 啟動驗證。

> 安裝完若提示找不到 `hermes` 指令,請**關閉並重開 PowerShell**(讓 PATH 重新載入),
> `cd` 回資料夾後再跑一次腳本。

---

## 方法 B:手動逐步

### 步驟 1 — 安裝 Hermes Agent
官方 Windows 安裝器會自帶 Python 3.11 / Node.js / ripgrep / ffmpeg / Git Bash:
```powershell
cd C:\Users\tt\Documents\Claude\Projects\hermas\
iex (irm https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.ps1)
```
> 設定檔會放在 `%USERPROFILE%\.hermes\`(例如 token 存在 `~\.hermes\.env`)。
> 你仍可從 `hermas` 資料夾啟動使用。

### 步驟 2 — 設定模型(讓它會回話)
```powershell
hermes setup --portal     # 最省事:Nous Portal(含 300+ 模型 + 工具)
# 或
hermes model              # 互動選 OpenRouter(200+ 模型)/ OpenAI / 自架端點
```

### 步驟 3 — 建立 Discord Bot
1. 開 <https://discord.com/developers/applications> → **New Application**
2. 左側 **Bot** → **Reset Token** → 複製 **Bot Token**
3. **Bot** 頁開啟 **Message Content Intent**(需要讀頻道文字時)
4. **OAuth2 → URL Generator** → 勾選 `bot` → 用產生的邀請連結把 bot 邀進你的伺服器
5. 取得你自己的 **User ID**:
   `Discord 設定 → 進階 → 開啟「開發者模式」` → 右鍵你的名字 → **複製使用者 ID**

### 步驟 4 — 把 Discord 接上 Hermes
```powershell
hermes gateway setup      # 選 Discord,貼上 Bot Token 與你的 User ID
```
對應寫進 `~\.hermes\.env` 的關鍵設定(可參考本資料夾 `.env.example`):
```
DISCORD_BOT_TOKEN=你的bot token
DISCORD_ALLOWED_USERS=你的Discord使用者ID    # 務必設定,否則預設拒絕所有人
```

### 步驟 5 — 啟動並驗證對話
```powershell
hermes gateway            # 啟動,bot 幾秒內會在 Discord 上線(此視窗保持執行)
```
另開一個 PowerShell 視窗確認狀態:
```powershell
hermes gateway status     # 確認 Discord = connected
```
然後在 Discord 頻道 **@提及你的 bot** 發一句話 → 它會回覆。**這就是可對話的成果。**

---

## 常用指令

| 用途 | 指令 |
|------|------|
| 直接在終端機聊天 | `hermes` |
| 設定模型 | `hermes model` |
| 完整設定精靈 | `hermes setup` |
| 開關工具 | `hermes tools` |
| 環境健檢 | `hermes doctor` |
| 更新 | `hermes update` |
| Gateway 狀態 | `hermes gateway status` |

---

## 疑難排解

- **找不到 `hermes` 指令** → 關閉並重開 PowerShell(PATH 需重新載入);仍不行就重開機。
- **bot 上線但不回話** →
  - 沒設 `DISCORD_ALLOWED_USERS`(預設拒絕所有人)→ 補上你的 User ID。
  - 伺服器頻道需要 **@提及** bot(`DISCORD_REQUIRE_MENTION` 預設 true);
    或把頻道加入 `DISCORD_FREE_RESPONSE_CHANNELS`。
  - 沒開 **Message Content Intent**。
  - 模型金鑰沒設或額度用完 → `hermes doctor` / `hermes model` 檢查。
- **PowerShell 擋腳本** → `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force`。

---

## 參考來源
- 專案首頁:<https://github.com/nousresearch/hermes-agent>
- 官方文件:<https://hermes-agent.nousresearch.com/docs/>
- Discord 設定文件:<https://github.com/nousresearch/hermes-agent/blob/main/website/docs/user-guide/messaging/discord.md>

> 備註:本教學由 Claude Code 在雲端容器中產生。該環境無法存取你的本機檔案,
> 網路政策也封鎖 Discord,因此**安裝與啟動需由你在自己電腦上執行**。
