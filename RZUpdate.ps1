If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {   
    Write-Host "Must be run with administrative rights. Ending script." -ForegroundColor Red
    Break
}

$Policy = "RemoteSigned"
If ((get-ExecutionPolicy) -ne $Policy) {
   Set-ExecutionPolicy $Policy -Force
}

[Net.ServicePointManager]::SecurityProtocol = "tls12"

$uri = "https://github.com/rzander/ruckzuck/releases/download/1.6.1.6/RZUpdate.exe"
 
$file = "$env:temp\RZUpdate.exe"
 
# Download Package
    Invoke-WebRequest -Uri $uri -Method get -OutFile $file
    Unblock-File $file

Start-Process -FilePath $file -ArgumentList "/Update"  -NoNewWindow -wait

#Delete desktop shortcuts in public folder
if (Get-Item "$env:Public\Desktop\*.lnk") {
    Invoke-Command {cmd.exe /c del /F /Q "C:\Users\Public\Desktop\*.lnk"} -ErrorAction SilentlyContinue
}
 
# Remove file
Remove-Item $file -Force