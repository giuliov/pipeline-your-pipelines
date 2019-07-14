param(
    $AZP_URL,
    $AZP_TOKEN,
    $AZP_POOL,
    $AgentsFolder
)

mkdir $AgentsFolder
cd $AgentsFolder

# Install PowerShell 6
$pkg = 'PowerShell-6.2.1-win-x64.msi'
curl -OutFile $pkg https://github.com/PowerShell/PowerShell/releases/download/v6.2.1/$pkg
if ((Get-FileHash $pkg -Algorithm sha256).Hash -eq 'C24406CA8F65440FA0381E417B05A16161227276EB3B77091FDB9D174B7F3144') {
    msiexec /qb /norestart /i $pkg
} else {
    Write-Error "Downloaded package doesn't match the hash!"
}

# Install Git for Windows
$pkg = 'Git-2.22.0-64-bit.exe'
curl -OutFile $pkg https://github.com/git-for-windows/git/releases/download/v2.22.0.windows.1/$pkg
if ((Get-FileHash $pkg -Algorithm sha256).Hash -eq '0c314a62f0f242c64fe1bdae20ab113fef990fb7e3323d0989478b6ed396d00b') {
    & "./$pkg" /SILENT
} else {
    Write-Error "Downloaded package doesn't match the hash!"
}

# Install Azure Pipelines Agent
$pkg = 'vsts-agent-win-x64-2.154.1.zip'
curl -OutFile $pkg https://vstsagentpackage.azureedge.net/agent/2.154.1/$pkg
if ((Get-FileHash $pkg -Algorithm sha256).Hash -eq '67634CC6B9D0A7F373940F08E6F76FE8A04CE3B765FAF9E693836F35289A08B1') {
    Expand-Archive -Path $pkg -DestinationPath ${AgentsFolder}\A1
    cd ${AgentsFolder}\A1
    .\config.cmd  --unattended --url $AZP_URL --auth pat --token $AZP_TOKEN --pool $AZP_POOL --agent $env:COMPUTERNAME --replace --acceptTeeEula --runAsService --windowsLogonAccount "NT AUTHORITY\SYSTEM"
} else {
    Write-Error "Downloaded package doesn't match the hash!"
}
