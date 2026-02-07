$langList = Get-WinUserLanguageList
$lang = $langList[0]
Write-Host "Current input methods:"
$lang.InputMethodTips | ForEach-Object { Write-Host $_ }
Write-Host ""

$wubiId = "0804:{4B3F6C0F-7F28-4462-8E78-C2E9C7F9B04C}"
if ($lang.InputMethodTips -contains $wubiId) {
    Write-Host "Wubi is already installed."
} else {
    $lang.InputMethodTips.Add($wubiId)
    Set-WinUserLanguageList $langList -Force
    Write-Host "Wubi added successfully."
}
