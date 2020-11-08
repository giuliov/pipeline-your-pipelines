param(
    $AZP_URL,
    $AZP_TOKEN,
    $AZP_POOL
)

# Format the data disk
Get-Disk |
where partitionstyle -eq 'raw' |
Initialize-Disk -PartitionStyle MBR -PassThru |
New-Partition -DriveLetter 'F' -UseMaximumSize |
Format-Volume -FileSystem NTFS -NewFileSystemLabel "datadisk" -Confirm:$false

mkdir F:\docker-data
'{ "data-root": "F:\\docker-data", "storage-opts": ["size=120GB"] }' | Out-File -Encoding Ascii -Filepath "C:\ProgramData\docker\config\daemon.json"
Restart-Service docker

mkdir F:\Temp
pushd F:\Temp

# Install PowerShell 7
$pkg = 'PowerShell-7.0.3-win-x64.msi'
curl -OutFile $pkg https://github.com/PowerShell/PowerShell/releases/download/v7.0.3/$pkg
if ((Get-FileHash $pkg -Algorithm sha256).Hash -eq 'AD3B4A868D1B7E47A1048E1EB20F7F782D9B95D5066D79A25D02CCC4DD14E79F') {
    msiexec /qb /norestart /i $pkg
} else {
    Write-Error "Downloaded package doesn't match the hash!"
}

# Install Git for Windows
$pkg = 'Git-2.29.2.2-64-bit.exe'
curl -OutFile $pkg https://github.com/git-for-windows/git/releases/download/v2.29.2.windows.2/$pkg
if ((Get-FileHash $pkg -Algorithm sha256).Hash -eq '9ab49d93166d430514b0aaf6dda3fdc6b37e2fe1d0df8ecc04403cd2be40e78b') {
    & "./$pkg" /SILENT
} else {
    Write-Error "Downloaded package doesn't match the hash!"
}

# Install Azure Pipelines Agent
$pkg = 'vsts-agent-win-x64-2.175.2.zip'
curl -OutFile $pkg https://vstsagentpackage.azureedge.net/agent/2.175.2/$pkg
if ((Get-FileHash $pkg -Algorithm sha256).Hash -eq 'B5EC1EC1BB3B4382B0B4DC11A60BBEA5460803B9DB3D1DEE07EFD23155F18D7D') {
    Expand-Archive -Path $pkg -DestinationPath F:\Agents\A1
    cd F:\Agents\A1
    .\config.cmd  --unattended --url $AZP_URL --auth pat --token $AZP_TOKEN --pool $AZP_POOL --agent $env:COMPUTERNAME --replace --acceptTeeEula --runAsService --windowsLogonAccount "NT AUTHORITY\SYSTEM"
} else {
    Write-Error "Downloaded package doesn't match the hash!"
}

popd
