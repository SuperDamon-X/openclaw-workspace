[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$body = @{
    name = "SuperDamonV2"
    description = "AI assistant helping Winston with daily tasks"
}

$json = ConvertTo-Json $body

try {
    Write-Host "注册SuperDamonV2到Moltbook..." -ForegroundColor Cyan
    $response = Invoke-WebRequest -Uri "https://www.moltbook.com/api/v1/agents/register" -Method POST -Body $json -ContentType "application/json" -UseBasicParsing -TimeoutSec 30
    Write-Host "响应：" -ForegroundColor Green
    Write-Host $response.Content -ForegroundColor White
    
    $data = $response.Content | ConvertFrom-Json
    
    if ($data.agent.api_key) {
        Write-Host "`n`n✅ 注册成功！" -ForegroundColor Green
        Write-Host "API Key: $($data.agent.api_key)" -ForegroundColor Yellow
        Write-Host "Claim URL: $($data.agent.claim_url)" -ForegroundColor Yellow
        Write-Host "Profile URL: $($data.agent.profile_url)" -ForegroundColor Yellow
        
        # 保存凭证
        $credentials = @{
            api_key = $data.agent.api_key
            agent_name = $data.agent.name
            agent_id = $data.agent.id
            profile_url = $data.agent.profile_url
            claim_url = $data.agent.claim_url
            verification_code = $data.agent.verification_code
            registered_at = $data.registered_at
        }
        $credentials | ConvertTo-Json -Depth 10 | Out-File "moltbook\SuperDamonV2-credentials.json" -Encoding UTF8
        
        Write-Host "`n`n✅ 凭证已保存到 moltbook\SuperDamonV2-credentials.json" -ForegroundColor Cyan
        
        # 自动打开Claim URL
        Write-Host "`n`n自动打开Claim URL..." -ForegroundColor Cyan
        Start-Process $data.agent.claim_url
        
        Write-Host "`n`n请使用X账号 @xuwenguang520 完成认领！" -ForegroundColor Yellow
    } else {
        Write-Host "注册失败：$($data.error)" -ForegroundColor Red
    }
} catch {
    Write-Host "错误: $($_.Exception.Message)" -ForegroundColor Red
}
