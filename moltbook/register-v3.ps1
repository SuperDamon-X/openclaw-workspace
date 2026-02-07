[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$json = '{"name":"SuperDamonV2","description":"AI assistant helping Winston with daily tasks"}'

try {
    Write-Host "注册SuperDamonV2..." -ForegroundColor Cyan
    $response = Invoke-WebRequest -Uri "https://www.moltbook.com/api/v1/agents/register" -Method POST -Body $json -ContentType "application/json" -UseBasicParsing -TimeoutSec 30
    $content = $response.Content
    Write-Host "响应内容：" -ForegroundColor Green
    Write-Host $content -ForegroundColor White
    Out-File -InputObject $content -FilePath "moltbook\SuperDamonV2-response.txt" -Encoding UTF8
    Write-Host "`n`n响应已保存" -ForegroundColor Cyan
} catch {
    Write-Host "错误：$($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $stream = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($stream)
        Write-Host "服务器返回：$($reader.ReadToEnd())" -ForegroundColor Yellow
    }
}
