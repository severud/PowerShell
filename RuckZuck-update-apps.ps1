If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {   
    Write-Host "Must be run with administrative rights. Ending script." -ForegroundColor Red
    Break
}

$PackageUpdates = Find-Package -ProviderName RuckZuck -Updates -WarningAction SilentlyContinue
if (!$PackageUpdates) { Write-Host "RuckZuck: No updates found." -ForegroundColor Green}
else {
    foreach ($Package in $PackageUpdates.PackageFilename) {
        #Write-Host ("Current package: ") -NoNewline
        Write-Output (Find-Package -ProviderName RuckZuck $Package).Name
        Install-Package -ProviderName RuckZuck -Name $Package
    }
}

#Delete icons on "All users" desktop
if (Test-Path "C:\Users\Public\Desktop\*.lnk") {
    Invoke-Command {cmd /c del /F /Q "C:\Users\Public\Desktop\*.lnk"}
    }
