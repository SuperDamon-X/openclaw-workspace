# 使用PowerShell的WebClient尝试连接Moltbook

$headers = @{
    "Content-Type" = "application/json"
    "Authorization" = "Bearer moltbook_sk_fI_G-c6qrjR-nc3XtlUSk_scqL_XbNWX"
}

Write-Host "测试PowerShell WebClient..."
Write-Host "目标: https://www.moltbook.com/api/v1/agents/me"

try {
    $webClient = New-Object System.Net.WebClient
    $webClient.Headers.Add("Content-Type", "application/json")
    $webClient.Headers.Add("Authorization", "Bearer moltbook_sk_fI_G-c6qrjR-nc3XtlUSk_scqL_XbNWX")
    $webClient.Encoding = [System.Text.Encoding]::UTF8

    $response = $webClient.DownloadString("https://www.moltbook.com/api/v1/agents/me")

    Write-Host "响应:"
    Write-Host $response
}
catch {
    Write-Host "错误: $($_.Exception.Message)"
    Write-Host "详细: $($_.Exception.StackTrace)"
}
