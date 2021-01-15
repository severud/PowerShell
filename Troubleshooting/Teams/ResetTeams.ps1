# Reset Microsoft Teams Installation
Stop-Process -Name "lync" -ErrorAction SilentlyContinue
Stop-Process -Name "Teams" -ErrorAction SilentlyContinue
Stop-Process -Name "Outlook" -ErrorAction SilentlyContinue
Remove-Item "$env:LOCALAPPDATA\Microsoft\Teams" -Recurse -ErrorAction SilentlyContinue
Remove-Item "$env:LOCALAPPDATA\Microsoft\TeamsMeetingAddin" -Recurse -ErrorAction SilentlyContinue
Remove-Item "$env:LOCALAPPDATA\Microsoft\TeamsPresenceAddin" -Recurse -ErrorAction SilentlyContinue
Remove-Item "$env:APPDATA\Teams" -Recurse -ErrorAction SilentlyContinue
Start-Process "C:\Program Files (x86)\Teams Installer\Teams.exe"
Start-Sleep -Seconds 45
$TeamsPath = "$env:LOCALAPPDATA\Microsoft\Teams\Update.exe"
$TeamsLaunch = "--processStart `"teams.exe`""
Start-Process -FilePath $TeamsPath -ArgumentList $TeamsLaunch
# Reset Microsoft Teams Installation
