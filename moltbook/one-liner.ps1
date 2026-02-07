[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$json = "{`"name`":`"SuperDamonV3`",`"description`":`"AI assistant helping Winston with daily tasks`"}"
$response = Invoke-WebRequest -Uri "https://www.moltbook.com/api/v1/agents/register" -Method POST -Body $json -ContentType "application/json" -UseBasicParsing -TimeoutSec 30
$content = $response.Content
Write-Host $content
Out-File -InputObject $content -FilePath "moltbook\response.txt" -Encoding UTF8
