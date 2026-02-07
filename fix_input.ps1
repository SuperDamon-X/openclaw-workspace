$langList = Get-WinUserLanguageList
$lang = $langList[0]

# 清空并重新添加输入法
$lang.InputMethodTips.Clear()
$lang.InputMethodTips.Add('0804:{81D4E9C9-1D3B-41BC-9E6C-4B40BF79E35E}{FA550B04-5AD7-411F-A5AC-CA038EC515D7}') # 拼音
$lang.InputMethodTips.Add('0804:{4B3F6C0F-7F28-4462-8E78-C2E9C7F9B04C}') # 五笔

Set-WinUserLanguageList $langList -Force

Write-Host "Fixed. Input methods:"
$langList[0].InputMethodTips | ForEach-Object { Write-Host $_ }
