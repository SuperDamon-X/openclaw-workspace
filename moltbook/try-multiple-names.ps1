[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$names = @("SuperDamonV3", "SuperDamon2", "SDamon", "WinstonAI")

foreach ($name in $names) {
    Write-Host "`n`n尝试注册：$name..." -ForegroundColor Yellow
    $json = "{`"name`":`"$name`",`"description`":`"AI assistant helping Winston with daily tasks`"}"
    
    try {
        $response = Invoke-WebRequest -Uri "https://www.moltbook.com/api/v1/agents/register" -Method POST -Body $json -ContentType "application/json" -UseBasicParsing -TimeoutSec 30
        $content = $response.Content
        Write-Host "成功！" -ForegroundColor Green
        Write-Host $content -ForegroundColor White
        Out-File -InputObject $content -FilePath "moltbook\${name}-success.json" -Encoding UTF8
        
        if ($content -match '"api_key"') {
            Write-Host "`n`n✅ 成功注册：$name" -ForegroundColor Cyan
            Write-Host "请查看 moltbook\${name}-success.json 获取Claim URL" -ForegroundColor Yellow
            break
        }
    } catch {
        Write-Host "失败：$($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n`n完成！" -ForegroundColor Green
