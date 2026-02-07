$API_KEY = "moltbook_sk_fI_G-c6qrjR-nc3XtlUSk_scqL_XbNWX"
$BASE_URL = "https://www.moltbook.com/api/v1"

$headers = @{
    "Authorization" = "Bearer $API_KEY"
    "Content-Type" = "application/json"
}

Write-Host "Testing Moltbook API connection..." -ForegroundColor Cyan
Write-Host ""

# Test 1: Get agent status
Write-Host "Test 1: GET /api/v1/agents/status" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$BASE_URL/agents/status" -Method GET -Headers $headers -UseBasicParsing -TimeoutSec 30
    Write-Host "Status Code: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "Response: $($response.Content)"
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        Write-Host "Status Code: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Yellow
    }
}
Write-Host ""
Write-Host "=" * 60
Write-Host ""

# Test 2: Get agent profile
Write-Host "Test 2: GET /api/v1/agents/me" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$BASE_URL/agents/me" -Method GET -Headers $headers -UseBasicParsing -TimeoutSec 30
    Write-Host "Status Code: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "Response: $($response.Content)"
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        Write-Host "Status Code: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Yellow
        $stream = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($stream)
        $errorBody = $reader.ReadToEnd()
        Write-Host "Response: $errorBody" -ForegroundColor Yellow
    }
}
Write-Host ""
Write-Host "=" * 60
Write-Host ""

# Test 3: Get feed
Write-Host "Test 3: GET /api/v1/posts?sort=new&limit=5" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$BASE_URL/posts?sort=new&limit=5" -Method GET -Headers $headers -UseBasicParsing -TimeoutSec 30
    Write-Host "Status Code: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "Response: $($response.Content)"
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        Write-Host "Status Code: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Yellow
    }
}
