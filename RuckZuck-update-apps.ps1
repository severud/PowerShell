If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {   
    Write-Host "Must be run with administrative rights. Ending script." -ForegroundColor Red
    Break
}

#Check for RuckZuck provider for PowerShell installation status
if (!(Test-Path "C:\Program Files\RuckZuck for OneGet\RuckZuckProvider.dll")) {
    Write-Host "Installing RuckZuck provider for PowerShell Packagemanagement…" -ForegroundColor Magenta
    $uri = "https://download-codeplex.sec.s-msft.com/Download/Release?ProjectName=ruckzuck&DownloadId=1457985&FileTime=131329510729830000&Build=21053"
    $file = "$env:temp/RuckZuck provider for OneGet_x64.msi"
    Invoke-WebRequest -Uri $uri -Method get -OutFile $file
    Unblock-File $file
    Start-Process -FilePath $file -ArgumentList "/qn" -Wait 
    rm $file -Force
} else {
    Write-Host "RuckZuck provider for PowerShell Packagemanagement previously installed ;-)" -ForegroundColor Green
}

$PackageUpdates = Find-Package -ProviderName RuckZuck -Updates -WarningAction SilentlyContinue
if (!$PackageUpdates) { Write-Host "RuckZuck: No updates found." -ForegroundColor Green}
else {
    foreach ($Package in $PackageUpdates.PackageFilename) {
        Write-Information -messagedata (Find-Package -ProviderName RuckZuck $Package).Name -InformationAction Continue
        Install-Package -ProviderName RuckZuck -Name $Package
    }
}

#Delete icons on "All users" desktop
if (Test-Path "C:\Users\Public\Desktop\*.lnk") {
    Invoke-Command {cmd /c del /F /Q "C:\Users\Public\Desktop\*.lnk"}
    }
