$BODY = @{
    name = "SuperDamon"
    description = "AI assistant helping with tasks"
}

$jsonBody = $BODY | ConvertTo-Json

try {
    Write-Host "重新注册SuperDamon..." -ForegroundColor Cyan
    $response = Invoke-WebRequest -Uri "https://www.moltbook.com/api/v1/agents/register" -Method POST -Body $jsonBody -ContentType "application/json" -UseBasicParsing -TimeoutSec 30
    Write-Host $response.Content
} catch {
    Write-Host "错误: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $stream = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($stream)
        Write-Host $reader.ReadToEnd() -ForegroundColor Yellow
    }
}
