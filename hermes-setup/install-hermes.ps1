<#
====================================================================
 Hermes Agent 一鍵安裝 / Discord 設定腳本 (Windows PowerShell)
====================================================================
 用途：在你自己的 Windows 電腦上安裝 NousResearch/hermes-agent，
       設定模型、並接上 Discord「Bot」(可雙向對話)。

 重要說明：
  - Hermes 連 Discord 使用「Bot Token」，不是 webhook。
    webhook 只能單向送訊息，無法對話。
  - 本腳本不會、也請你不要把任何 token 寫進這個檔案。
    所有密鑰一律由互動式精靈輸入，存到 %USERPROFILE%\.hermes\.env。

 使用方式（在 PowerShell 視窗）：
    cd C:\Users\tt\Documents\Claude\Projects\hermas\
    # 若被擋，先放行本次執行原則：
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
    .\install-hermes.ps1
====================================================================
#>

[CmdletBinding()]
param(
    # 你要把專案放在哪個資料夾（預設依你的需求）
    [string]$ProjectDir = "C:\Users\tt\Documents\Claude\Projects\hermas"
)

$ErrorActionPreference = "Stop"

function Write-Step($n, $msg) { Write-Host "`n[$n] $msg" -ForegroundColor Cyan }
function Write-Ok($msg)        { Write-Host "  OK  $msg" -ForegroundColor Green }
function Write-Warn2($msg)     { Write-Host "  !!  $msg" -ForegroundColor Yellow }
function Pause-Step($msg)      { Read-Host "  >>> $msg（完成後按 Enter 繼續）" | Out-Null }

Write-Host "==============================================" -ForegroundColor Magenta
Write-Host " Hermes Agent 安裝 + Discord 對話設定" -ForegroundColor Magenta
Write-Host "==============================================" -ForegroundColor Magenta

# --- 0. 準備專案資料夾 ------------------------------------------------
Write-Step 0 "準備專案資料夾：$ProjectDir"
if (-not (Test-Path $ProjectDir)) {
    New-Item -ItemType Directory -Path $ProjectDir -Force | Out-Null
    Write-Ok "已建立資料夾"
} else {
    Write-Ok "資料夾已存在"
}
Set-Location $ProjectDir

# --- 1. 安裝 Hermes Agent --------------------------------------------
Write-Step 1 "安裝 Hermes Agent（官方 Windows 安裝器，自帶 Python/Node/git）"
if (Get-Command hermes -ErrorAction SilentlyContinue) {
    Write-Ok "偵測到 hermes 已安裝，略過安裝步驟（如需更新可稍後執行 hermes update）"
} else {
    Write-Host "  從官方來源下載安裝中…" -ForegroundColor Gray
    iex (irm https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.ps1)
    Write-Ok "安裝指令已執行"
    Write-Warn2 "若這個視窗找不到 hermes 指令，請『關閉並重開』PowerShell 後再跑一次本腳本（PATH 需要重新載入）。"
}

# 確認 hermes 可用
if (-not (Get-Command hermes -ErrorAction SilentlyContinue)) {
    Write-Warn2 "目前這個視窗還抓不到 hermes 指令。請關閉 PowerShell、重新開啟，cd 回專案資料夾後再執行本腳本。"
    return
}

# --- 2. 環境健檢 ------------------------------------------------------
Write-Step 2 "環境健檢（hermes doctor）"
hermes doctor

# --- 3. 設定模型（讓 agent 會回話）----------------------------------
Write-Step 3 "設定模型供應商與 API 金鑰"
Write-Host "  接下來會開啟模型設定精靈。" -ForegroundColor Gray
Write-Host "  - 最省事：選 Nous Portal（hermes setup --portal）" -ForegroundColor Gray
Write-Host "  - 或自選：OpenRouter / OpenAI / 自架端點（hermes model）" -ForegroundColor Gray
$usePortal = Read-Host "  要用 Nous Portal 嗎？(Y/n)"
if ($usePortal -eq "" -or $usePortal -match '^[Yy]') {
    hermes setup --portal
} else {
    hermes model
}
Write-Ok "模型設定完成"

# --- 4. Discord Bot 前置（手動，在瀏覽器）---------------------------
Write-Step 4 "建立 Discord Bot（取代 webhook，才能雙向對話）"
Write-Host @"
  請在瀏覽器完成以下動作，完成後回來按 Enter：
   1) 開 https://discord.com/developers/applications  ->  New Application
   2) 左側 Bot -> Reset Token -> 複製【Bot Token】
   3) Bot 頁開啟【Message Content Intent】（需要讀頻道文字時）
   4) OAuth2 -> URL Generator -> 勾 bot -> 用產生的連結把 Bot 邀進你的伺服器
   5) 取得你自己的【User ID】：
      Discord 設定 -> 進階 -> 開啟「開發者模式」-> 右鍵你的名字 -> 複製使用者 ID
"@ -ForegroundColor Gray
Pause-Step "完成 Discord 前置設定後"

# --- 5. 把 Discord 接上 Hermes --------------------------------------
Write-Step 5 "設定 Discord Gateway（貼上 Bot Token 與你的 User ID）"
Write-Warn2 "Token 只會輸入到 hermes 精靈，存進 %USERPROFILE%\.hermes\.env，不會寫到本腳本。"
hermes gateway setup

# --- 6. 啟動並驗證 ----------------------------------------------------
Write-Step 6 "啟動 Gateway 並驗證"
Write-Host "  即將啟動 gateway（此視窗會持續執行）。" -ForegroundColor Gray
Write-Host "  啟動後請到 Discord 頻道【@提及你的 bot】發一句話，它就會回覆。" -ForegroundColor Gray
Write-Host "  另開一個 PowerShell 視窗可用 'hermes gateway status' 查看連線狀態。" -ForegroundColor Gray
Pause-Step "準備好啟動 gateway 了嗎？按 Enter 啟動（Ctrl+C 可停止）"
hermes gateway
