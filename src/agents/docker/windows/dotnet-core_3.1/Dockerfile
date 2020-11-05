# escape=`

FROM mcr.microsoft.com/windows/servercore:ltsc2019 AS agent

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

ENV AGENT_VERSION 2.175.2
ENV AGENT_SHA256 B5EC1EC1BB3B4382B0B4DC11A60BBEA5460803B9DB3D1DEE07EFD23155F18D7D

RUN Invoke-WebRequest -OutFile agent.zip https://vstsagentpackage.azureedge.net/agent/$env:AGENT_VERSION/vsts-agent-win-x64-$env:AGENT_VERSION.zip; `
    if ((Get-FileHash agent.zip -Algorithm sha256).Hash -ne $Env:AGENT_SHA256) { `
        Write-Host 'CHECKSUM VERIFICATION FAILED!'; `
        exit 1; `
    }; `
    Expand-Archive -Path agent.zip -DestinationPath C:\BuildAgent ; `
    Remove-Item -Path agent.zip


# ----- toolchain download start -----
# see https://github.com/dotnet/dotnet-docker/blob/master/2.2/sdk/nanoserver-1809/amd64/Dockerfile
FROM mcr.microsoft.com/windows/servercore:ltsc2019 AS toolchain

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# do not bump to 3.0 without changing the next FROM section
ENV DOTNET_SDK_VERSION 3.1.403
ENV DOTNET_SHA512 280c7dee8c6cfa56f1f37efe901d124495ca0a9bdb1f3d535e37ca069ec7bb646cded362517b9d3f63233ecf184914254217914a981037f9050a94480322ad00

RUN Invoke-WebRequest -OutFile dotnet.zip https://download.visualstudio.microsoft.com/download/pr/143c00dc-a1f2-4070-a1fd-5f732e13be1f/b11931ba31bb5af69dce36e39a3014c5/dotnet-sdk-3.1.403-win-x64.zip; `
    if ((Get-FileHash dotnet.zip -Algorithm sha512).Hash -ne $Env:DOTNET_SHA512) { `
        Write-Host 'CHECKSUM VERIFICATION FAILED!'; `
        exit 1; `
    }; `
    Expand-Archive dotnet.zip -DestinationPath C:\dotnet; `
    Remove-Item -Force dotnet.zip
# -----  toolchain download end  -----


FROM mcr.microsoft.com/windows/servercore:ltsc2019

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# ----- toolchain setup start -----
COPY --from=toolchain ["C:/dotnet", "C:/dotnet"]
RUN setx /M PATH $('C:\dotnet;' + $Env:PATH)

# variables to define Capabilities
ENV dotnetcore_3.1=true
# -----  toolchain setup end  -----
# must be passed to run command, we use some bogus values here to highlight what is missing
ENV AZP_URL=azdo.example.com
ENV AZP_TOKEN=invalid_PAT
ENV AZP_POOL=Default
ENV AZP_AGENT_NAME=$env:COMPUTERNAME
ENV AZP_WORK=_work
# VSO_AGENT_IGNORE contains comma delimited list of vars not to publish as capabilities by Agent
ENV VSO_AGENT_IGNORE="VSO_AGENT_IGNORE,AZP_AGENT_NAME,AZP_URL,AZP_TOKEN,AZP_POOL,AZP_WORK"

WORKDIR C:/BuildAgent

COPY --from=agent ["C:/BuildAgent", "C:/BuildAgent"]

ENTRYPOINT .\bin\Agent.Listener.exe configure --unattended `
    --agent "$env:AZP_AGENT_NAME" `
    --url "$env:AZP_URL" `
    --auth PAT `
    --token "$env:AZP_TOKEN" `
    --pool "$env:AZP_POOL" `
    --work "$env:AZP_WORK" `
    --replace; `
    .\bin\Agent.Listener.exe run