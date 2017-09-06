<#
.SYNOPSIS
   Update Dell TPM firmware
.DESCRIPTION
   Disable TPM autoprovision until next reboot, suspend bitlocker, clear TPM owner, reboot, run this script a second time to flash firmware.
   Must be present at computer to hit F12 to accept clearing of TPM.
.VARIABLES
   Modify $tpmMinVer, $uri, $file for desired TPM firmware version and file source/destination
#>

If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {   
    Write-Host "Must be run with administrative rights. Ending script." -ForegroundColor Red
    Break
}

$tpmMinVer = [version] '1.3.2.8'
$uri = "https://downloads.dell.com/FOLDER04166647M/1/DellTpm2.0_Fw1.3.2.8_V1_64.exe"
$file = "$env:temp/DellTpm2.0_Fw1.3.2.8_V1_64.exe"

$TPMprovisioning = (get-tpm).AutoProvisioning

$TPMVer = [version] (Get-WmiObject -Class Win32_Tpm -Namespace root\CIMV2\security\MicrosoftTpm).ManufacturerVersionFull20
Write-Host "Current TPM version :" $TPMVer -ForegroundColor Yellow
Write-Host "Target TPM version  :" $tpmMinVer -ForegroundColor green

if ($TPMVer -ge $tpmMinVer) {
    Write-Host "No update required ;-)" -ForegroundColor Blue
    Break
}

If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {   
    Write-Host "Must be run with administrative rights. Ending script." -ForegroundColor Red
    Break
}

Function ClearTPM {
    #Declare Local Memory
    Set-Variable -Name ClassName -Value "Win32_Tpm" -Scope Local -Force
    Set-Variable -Name Computer -Value $env:COMPUTERNAME -Scope Local -Force
    Set-Variable -Name NameSpace -Value "ROOT\CIMV2\Security\MicrosoftTpm" -Scope Local -Force
    Set-Variable -Name oTPM -Scope Local -Force
	
    $oTPM = Get-WmiObject -Class $ClassName -ComputerName $Computer -Namespace $NameSpace
    #$oTPM.SetPhysicalPresenceRequest(16)  
    #$oTPM.SetPhysicalPresenceRequest(18)
    $Output = "Clearing TPM Ownership....."
    Write-Host "Clearing TPM Ownership....." -NoNewline
    $Temp = $oTPM.SetPhysicalPresenceRequest(5)
    If ($Temp.ReturnValue -eq 0) {
        $Output = "Success"
        Write-Host "Success" -ForegroundColor Yellow
    }
    else {
        $Output = "Failure"
        Write-Host "Failure" -ForegroundColor Red
        $Global:Errors++
    }

    #Cleanup Local Memory
    Remove-Variable -Name oTPM -Scope Local -Force
}

$secureBiosPwd = Read-Host "Enter BIOS Admin Password" -AsSecureString

#Check for NuGet Package Provider installation status and version
$NuGetPackageSource = Find-PackageProvider -Name nuget
$NuGetPackageInstalled = Get-PackageProvider | Where-Object {$_.name -contains "NuGet"}

if (!($NuGetPackageInstalled)) {
     Install-PackageProvider -Name NuGet -Force
} elseif  ($NuGetPackageInstalled.version -lt $NuGetPackageSource.version) {
    Write-Host "Current NuGet version:" $NuGetPackageInstalled.version -ForegroundColor Yellow
    Write-Host "Updating NuGet to version: " $NuGetPackageSource.version -ForegroundColor Green
    Install-PackageProvider -Name NuGet -Force
} else {Write-Host "Current NuGet version:" $NuGetPackageInstalled.version -ForegroundColor Green}

if (Test-Path "C:\Program Files\WindowsPowerShell\Modules\DellBIOSProvider\") {
    Import-Module -Name DellBIOSProvider} else {
        Install-Module -Name DellBIOSProvider -force
		Import-Module -Name DellBIOSProvider
    }

if ((Get-Module DellBIOSProvider).version -lt (Find-Module -Name DellBiosProvider -Repository PSGallery).version) {
		Remove-Module -Name DellBIOSProvider -ErrorAction SilentlyContinue
		Install-Module -Name DellBIOSProvider -force
		Import-Module -Name DellBIOSProvider
	}

if(!(Read-DellBIOSPassword -ErrorAction SilentlyContinue)){
    Write-DellBIOSPassword -Password $secureBiosPwd
}
$biospwd = Read-DellBIOSPassword

#Disable TPM autoprovisioning, suspend BitLocker, and reboot system. Must be present at system to confirm clearing of TPM owner.
if ($TPMprovisioning -eq 'Enabled' -and $TPMVer -lt $tpmMinVer) {
    #Disable TPM auto provisioning
    Disable-TpmAutoProvisioning

    #Suspend BitLocker, set flag to clear TPM, and restart computer
    Set-Item -Path DellSmbios:\VirtualizationSupport\TrustExecution disabled -PasswordSecure $biospwd
    Suspend-BitLocker -MountPoint "C:" -RebootCount 3
    ClearTPM
    Restart-Computer
}

#Update TPM firmware
if ($TPMprovisioning -eq 'Disabled' -and $TPMVer -lt $tpmMinVer) {
    Get-Item -Path DellSmbios:\VirtualizationSupport\TrustExecution | Format-Table -AutoSize
    Set-Item -Path DellSmbios:\VirtualizationSupport\TrustExecution enabled -PasswordSecure $biospwd
    $biosPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureBiosPwd))
    Invoke-WebRequest -Uri $uri -Method get -OutFile $file
    Unblock-File $file
    Invoke-Expression ("cmd /c $file /s /f /p=$biosPassword")
    Enable-TpmAutoProvisioning
    Restart-Computer
}
