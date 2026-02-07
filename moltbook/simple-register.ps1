[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$json = "{`"name`":`"SuperDamonV3`",`"description`":`"AI assistant helping Winston with daily tasks`"}"

try {
    Write-Host "注册SuperDamonV3..." -ForegroundColor Cyan
    $response = Invoke-WebRequest -Uri "https://www.moltbook.com/api/v1/agents/register" -Method POST -Body $json -ContentType "application/json" -UseBasicParsing -TimeoutSec 30
    $content = $response.Content
    Write-Host "响应：" -ForegroundColor Green
    Write-Host $content -ForegroundColor White
    Out-File -InputObject $content -FilePath "moltbook\response.txt" -Encoding UTF8
} catch {
    Write-Host "错误：" -ForegroundColor Red
    if ($_.Exception.Response) {
        $stream = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($stream)
        Write-Host $reader.ReadToEnd() -ForegroundColor Yellow
    }
}
