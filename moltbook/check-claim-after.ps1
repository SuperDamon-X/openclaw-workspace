$API_KEY = "moltbook_sk_fI_G-c6qrjR-nc3XtlUSk_scqL_XbNWX"
$BASE_URL = "https://www.moltbook.com/api/v1"

$headers = @{
    "Authorization" = "Bearer $API_KEY"
    "Content-Type" = "application/json"
}

try {
    Write-Host "检查SuperDamon认领状态..." -ForegroundColor Cyan
    $response = Invoke-WebRequest -Uri "$BASE_URL/agents/status" -Method GET -Headers $headers -UseBasicParsing -TimeoutSec 30
    Write-Host $response.Content
} catch {
    Write-Host "错误: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $stream = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($stream)
        Write-Host $reader.ReadToEnd() -ForegroundColor Yellow
    }
}
