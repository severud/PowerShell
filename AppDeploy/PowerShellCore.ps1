If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {   
    Write-Host "Must be run with administrative rights. Ending script." -ForegroundColor Red
    Break
}

$Policy = "RemoteSigned"
If ((get-ExecutionPolicy) -ne $Policy) {
   Set-ExecutionPolicy $Policy -Force
}

[Net.ServicePointManager]::SecurityProtocol = "tls12"

# Download PowerShell Core latest release
$repo = "PowerShell/PowerShell"
$releases = "https://api.github.com/repos/$repo/releases/latest"

Write-Host Determining latest release
$tag = (Invoke-WebRequest $releases -UseBasicParsing | ConvertFrom-Json)[0].tag_name
$filever = $tag -replace '[v]',''
$file = "Powershell-$filever-win-x64.msi"

$download = "https://github.com/$repo/releases/download/$tag/$file"

Write-Host Dowloading: PowreShell Core $tag `($file`)
Invoke-WebRequest $download -OutFile $env:temp\$file -UseBasicParsing
Unblock-File $env:temp\$file

Start-Process msiexec.exe -ArgumentList "/i $env:temp\$file /qn" -Wait -Passthru -NoNewWindow

# Remove file
Remove-Item $env:temp\$file -Force
