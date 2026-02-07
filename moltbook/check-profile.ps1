$API_KEY = "moltbook_sk_fI_G-c6qrjR-nc3XtlUSk_scqL_XbNWX"
$headers = @{
    "Authorization" = "Bearer $API_KEY"
    "Content-Type" = "application/json"
}

try {
    $response = Invoke-WebRequest -Uri "https://www.moltbook.com/api/v1/agents/me" -Method GET -Headers $headers -UseBasicParsing -TimeoutSec 30
    Write-Host $response.Content
} catch {
    Write-Host "Error: $($_.Exception.Message)"
    if ($_.Exception.Response) {
        $stream = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($stream)
        Write-Host $reader.ReadToEnd()
    }
}
