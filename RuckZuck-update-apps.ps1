If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {   
    Write-Host "Must be run with administrative rights. Ending script." -ForegroundColor Red
    Break
}

#Check installation status of RuckZuck provider for PowerShell
#Update as needed for new version url and filename
if (!(Test-Path "C:\Program Files\RuckZuck for OneGet\RuckZuckProvider.dll")) {
    Write-Host "Installing RuckZuck provider for PowerShell Packagemanagement…" -ForegroundColor Magenta
    $uri = "https://github.com/rzander/ruckzuck/releases/download/1.6.0.2/RuckZuck.provider.for.OneGet_x64.msi"
    $file = "$env:temp/RuckZuck.provider.for.OneGet_x64.msi"
    Invoke-WebRequest -Uri $uri -Method get -OutFile $file
    Unblock-File $file
    Start-Process -FilePath $file -ArgumentList "/qn" -Wait 
    rm $file -Force
    Write-Information -MessageData "RuckZuck provider for PowerShell Packagemanagement installed." -InformationAction Continue
}

#Perform updates of detected outdated packages
$PackageUpdates = Find-Package -ProviderName RuckZuck -Updates -WarningAction SilentlyContinue
if (!$PackageUpdates) { Write-Host "RuckZuck: No updates found." -ForegroundColor Green}
else {
    foreach ($Package in $PackageUpdates.PackageFilename) {
        Write-Information -messagedata (Find-Package -ProviderName RuckZuck $Package).Name -InformationAction Continue -InformationVariable UpdatedPackage
        Install-Package -ProviderName RuckZuck -Name $Package
    }
}

#Delete icons on "All users" desktop
if (Test-Path "C:\Users\Public\Desktop\*.lnk") {
    Invoke-Command {cmd /c del /F /Q "C:\Users\Public\Desktop\*.lnk"}
}
