Write-Host "Install OpenSSH.Server"
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
Write-Host "Start OpenSSH.Server"
Start-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'