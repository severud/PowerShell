# https://marckean.com/2016/06/01/use-powershell-to-install-windows-updates/
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {   
    Write-Host "Must be run with administrative rights. Ending script." -ForegroundColor Red
    Break
}

if (!(Test-Path "C:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe")) {
    $uri = "https://downloads.dell.com/FOLDER04358530M/1/Dell-Command-Update_X79N4_WIN_2.3.1_A00.EXE"
    $file = "$env:temp/Dell-Command-Update_X79N4_WIN_2.3.1_A00.EXE"
    Invoke-WebRequest -Uri $uri -Method get -OutFile $file
    Unblock-File $file
    Start-Process -FilePath $file -ArgumentList "/s /f" -Wait 
    rm $file -Force
}
Start-Process -FilePath "C:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe" -NoNewWindow -wait