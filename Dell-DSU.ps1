If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {   
    Write-Host "Must be run with administrative rights. Ending script." -ForegroundColor Red
    Break
}

if (!(Test-Path "C:\Dell\DELL EMC System Update\DSU.exe") -or (Get-Item "C:\Dell\DELL EMC System Update\DSU.exe").CreationTime -lt "3/20/2018 12:39:22 AM") {
    [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
    $uri = "https://downloads.dell.com/FOLDER04882840M/1/Systems-Management_Application_RT3W9_WN64_1.5.3_A00.EXE"
    $file = "$env:temp/Systems-Management_Application_RT3W9_WN64_1.5.3_A00.EXE"
    Invoke-WebRequest -Uri $uri -Method get -OutFile $file
    Unblock-File $file
    Start-Process -FilePath $file -ArgumentList "/s /f" -Wait 
    rm $file -Force
}
Start-Process -FilePath "C:\Dell\DELL EMC System Update\DSU.exe" -NoNewWindow -wait