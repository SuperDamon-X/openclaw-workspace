$langList = Get-WinUserLanguageList
Write-Host "Current input methods:"
$langList[0].InputMethodTips | ForEach-Object { Write-Host $_ }
