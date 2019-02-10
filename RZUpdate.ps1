If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {   
    Write-Host "Must be run with administrative rights. Ending script." -ForegroundColor Red
    Break
}

$Policy = "RemoteSigned"
If ((get-ExecutionPolicy) -ne $Policy) {
   Set-ExecutionPolicy $Policy -Force
}

[Net.ServicePointManager]::SecurityProtocol = "tls12"

# Download specific version of RZUpdate.exe
# $tag = '1.6.2.13'
# $uri = "https://github.com/rzander/ruckzuck/releases/download/$tag/RZUpdate.exe"
# $file = "RZUpdate.exe"
# Download Package
#    Invoke-WebRequest -Uri $uri -Method get -OutFile $env:temp\$file
#    Unblock-File $env:temp\$file

# Download latest RZUpdate.exe from rzander/ruckzuck release from github
# Reference: https://gist.github.com/MarkTiedemann/c0adc1701f3f5c215fc2c2d5b1d5efd3
$repo = "rzander/ruckzuck"
$file = "RZUpdate.exe"
$releases = "https://api.github.com/repos/$repo/releases"

Write-Host Determining latest release
$tag = (Invoke-WebRequest $releases -UseBasicParsing | ConvertFrom-Json)[0].tag_name

$download = "https://github.com/$repo/releases/download/$tag/$file"

Write-Host Dowloading: RZUpdate.exe $tag
Invoke-WebRequest $download -OutFile $env:temp\$file -UseBasicParsing
Unblock-File $env:temp\$file

Start-Process -FilePath $env:temp\$file -ArgumentList "/Update"  -NoNewWindow -wait

#Delete desktop shortcuts in public folder
if (Get-Item "$env:Public\Desktop\*.lnk") {
    Remove-Item –path C:\users\Public\Desktop\* -include *.lnk
}
 
# Remove file
Remove-Item $env:temp\$file -Force
