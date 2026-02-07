#
# 火山引擎语音识别（异步模式）- Windows PowerShell 版本
#
# 用法: .\transcribe.ps1 <audio_url>
# 输出: volcengine_result.json
#

param(
    [Parameter(Mandatory=$true)]
    [string]$AudioUrl
)

# 获取脚本目录
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$EnvFile = Join-Path (Split-Path -Parent (Split-Path -Parent $ScriptDir)) ".env"

# 检查 .env 文件
if (-not (Test-Path $EnvFile)) {
    Write-Host "❌ 找不到 $EnvFile"
    Write-Host "请创建 .env 文件并填入 VOLCENGINE_API_KEY"
    exit 1
}

# 读取 API Key
$ApiKey = (Get-Content $EnvFile | Select-String "VOLCENGINE_API_KEY").ToString().Split('=')[1].Trim()

Write-Host "🎤 提交火山引擎转录任务..."
Write-Host "音频 URL: $AudioUrl"

# 读取热词词典
$DictFile = Join-Path (Split-Path -Parent $ScriptDir) "字幕\词典.txt"
$HotWords = ""
if (Test-Path $DictFile) {
    $Words = Get-Content $DictFile | Where-Object { $_ -ne "" }
    $HotWords = ($Words | ForEach-Object { "`"$_`"" }) -join ","
    Write-Host "📖 加载热词: $($Words.Count) 个"
}

# 构建请求体
$RequestData = @{
    url = $AudioUrl
}
if ($HotWords) {
    $RequestData.hot_words = $HotWords | ConvertFrom-Json
}

# 步骤1: 提交任务
$Headers = @{
    "Accept" = "*/*"
    "x-api-key" = $ApiKey
    "Connection" = "keep-alive"
    "content-type" = "application/json"
}

$Body = @{
    url = $AudioUrl
    hot_words = @()
} | ConvertTo-Json -Depth 10

$SubmitResponse = Invoke-RestMethod -Uri "https://openspeech.bytedance.com/api/v1/vc/submit?language=zh-CN&use_itn=True&use_capitalize=True&max_lines=1&words_per_line=15" -Method POST -Headers $Headers -Body $Body

if (-not $SubmitResponse.id) {
    Write-Host "❌ 提交失败，响应:"
    Write-Host ($SubmitResponse | ConvertTo-Json)
    exit 1
}

$TaskId = $SubmitResponse.id
Write-Host "✅ 任务已提交，ID: $TaskId"
Write-Host "⏳ 等待转录完成..."

# 步骤2: 轮询结果
$MaxAttempts = 120  # 最多等待 10 分钟
$Attempt = 0

while ($Attempt -lt $MaxAttempts) {
    Start-Sleep -Seconds 5
    $Attempt++

    $QueryResponse = Invoke-RestMethod -Uri "https://openspeech.bytedance.com/api/v1/vc/query?id=$TaskId" -Method GET -Headers $Headers

    if ($QueryResponse.code -eq 0) {
        # 成功完成
        $QueryResponse | ConvertTo-Json -Depth 10 | Out-File -FilePath "volcengine_result.json" -Encoding utf8
        Write-Host "✅ 转录完成，已保存 volcengine_result.json"

        # 显示统计
        $Utterances = $QueryResponse.result.utterances.Count
        Write-Host "📝 识别到 $Utterances 段语音"
        exit 0
    } elseif ($QueryResponse.code -eq 1000) {
        # 处理中
        Write-Host -NoNewline "."
    } else {
        # 其他错误
        Write-Host ""
        Write-Host "❌ 转录失败，响应:"
        Write-Host ($QueryResponse | ConvertTo-Json)
        exit 1
    }
}

Write-Host ""
Write-Host "❌ 超时，任务未完成"
exit 1
