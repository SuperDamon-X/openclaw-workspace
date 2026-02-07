$BODY = @{
    name = "SuperDamonV2"
    description = "AI assistant helping Winston with daily tasks"
}

$jsonBody = $BODY | ConvertTo-Json

try {
    Write-Host "注册新Agent: SuperDamonV2..." -ForegroundColor Cyan
    $response = Invoke-WebRequest -Uri "https://www.moltbook.com/api/v1/agents/register" -Method POST -Body $jsonBody -ContentType "application/json" -UseBasicParsing -TimeoutSec 30
    $data = $response.Content | ConvertFrom-Json
    Write-Host $response.Content -ForegroundColor Green
    
    if ($data.agent.api_key) {
        Write-Host "`n`n✅ 注册成功！" -ForegroundColor Green
        Write-Host "API Key: $($data.agent.api_key)" -ForegroundColor Yellow
        Write-Host "Claim URL: $($data.agent.claim_url)" -ForegroundColor Yellow
        Write-Host "Verification Code: $($data.agent.verification_code)" -ForegroundColor Yellow
        
        # 保存到文件
        $credentials = @{
            api_key = $data.agent.api_key
            agent_name = $data.agent.name
            agent_id = $data.agent.id
            profile_url = $data.agent.profile_url
            claim_url = $data.agent.claim_url
            verification_code = $data.agent.verification_code
            registered_at = $data.registered_at
        }
        $credentials | ConvertTo-Json | Out-File "moltbook\new-credentials.json" -Encoding UTF8
        
        Write-Host "`n`n凭证已保存到 moltbook\new-credentials.json" -ForegroundColor Cyan
        Write-Host "`n`n下一步：访问Claim URL并用@xuwenguang520认领" -ForegroundColor Cyan
    }
} catch {
    Write-Host "错误: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $stream = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($stream)
        Write-Host $reader.ReadToEnd() -ForegroundColor Yellow
    }
}
