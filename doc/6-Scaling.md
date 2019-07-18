# Meta-pipelines - Part 6 - Organising

## Multiple hosts for the same Platform
TODO
The check for running container works for a single host!
There is no load balancing!
Use Capabilities to partition and organise your agent within a platform.

## Running builds
TODO
Wait for any running build to finish before nuking the container

## Kubernets
Two samples
https://anthonychu.ca/post/vsts-agent-docker-kubernetes/
https://www.chrisjohnson.io/2018/07/07/using-azure-kubernetes-service-aks-for-your-vsts-build-agents/
Helm chart!
https://github.com/Azure/helm-vsts-agent
some elements here about security
https://cloudblogs.microsoft.com/opensource/2018/11/27/tutorial-azure-devops-setup-cicd-pipeline-kubernetes-docker-helm/
more tips
https://www.reddit.com/r/devops/comments/ax0ep1/azure_devops_agents_on_kubernetes_cluster_with/?utm_source=share&utm_medium=web2x
more examples from mohitgoyal
https://webcache.googleusercontent.com/search?q=cache:o8GJmeBSfE4J:https://mohitgoyal.co/2019/01/05/running-azure-devops-private-agents-as-docker-containers/+&cd=1&hl=en&ct=clnk&gl=ie&client=firefox-b-d
https://webcache.googleusercontent.com/search?q=cache:ZhaCg0ZIfW4J:https://mohitgoyal.co/2019/01/10/run-azure-devops-private-agents-in-kubernetes-clusters/+&cd=6&hl=en&ct=clnk&gl=ie&client=firefox-b-d

## Code organisation

To avoid repetitions you can refactor your code in 

I will exemplify using the Dockerfile for Windows from Part 1.

The original code becomes three Dockerfiles:
- Downloaded agent
- .Net Core SDK
- The composition of the two




```Dockerfile
# escape=`

FROM mcr.microsoft.com/windows/servercore:ltsc2019 AS agent

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

ENV AGENT_VERSION 2.154.1
ENV AGENT_SHA256 67634CC6B9D0A7F373940F08E6F76FE8A04CE3B765FAF9E693836F35289A08B1

RUN Invoke-WebRequest -OutFile agent.zip https://vstsagentpackage.azureedge.net/agent/$env:AGENT_VERSION/vsts-agent-win-x64-$env:AGENT_VERSION.zip; `
    if ((Get-FileHash agent.zip -Algorithm sha256).Hash -ne $Env:AGENT_SHA256) { `
        Write-Host 'CHECKSUM VERIFICATION FAILED!'; `
        exit 1; `
    }; `
    Expand-Archive -Path agent.zip -DestinationPath C:\BuildAgent ; `
    Remove-Item -Path agent.zip
```

build the image `my/azure-pipeline-agent:2.154.1`

```Dockerfile
# see https://github.com/dotnet/dotnet-docker/blob/master/2.2/sdk/nanoserver-1809/amd64/Dockerfile
FROM mcr.microsoft.com/windows/servercore:ltsc2019 AS toolchain

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# do not bump to 3.0 without changing the next FROM section
ENV DOTNET_SDK_VERSION 2.2.105
ENV DOTNET_SHA512 d58b0b3f2f82f3960b84e1a7ee36c4febc28db9e08bb99a6dd0b61e5812631d935c471a5ba2f90c966fbcddb208454948339ee5c0d7fbaee4168f3fe6c0827f4

RUN Invoke-WebRequest -OutFile dotnet.zip https://dotnetcli.blob.core.windows.net/dotnet/Sdk/$Env:DOTNET_SDK_VERSION/dotnet-sdk-$Env:DOTNET_SDK_VERSION-win-x64.zip; `
    if ((Get-FileHash dotnet.zip -Algorithm sha512).Hash -ne $Env:DOTNET_SHA512) { `
        Write-Host 'CHECKSUM VERIFICATION FAILED!'; `
        exit 1; `
    }; `
    Expand-Archive dotnet.zip -DestinationPath C:\dotnet; `
    Remove-Item -Force dotnet.zip


FROM mcr.microsoft.com/windows/servercore:ltsc2019

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

COPY --from=toolchain ["C:/dotnet", "C:/dotnet"]
RUN setx /M PATH $('C:\dotnet;' + $Env:PATH)

# variables to define Capabilities
ENV dotnetcore_2.2=true
```

build the image `my/dotnetcore:2.2`

```Dockerfile
FROM my/azure-pipeline-agent:latest AS agent

FROM my/dotnetcore:2.2

# must be passed to run command, we use some bogus values here to highlight what is missing
ENV TFS_URL=tfs.example.com
ENV VSTS_TOKEN=invalid_PAT
ENV VSTS_POOL=Default
ENV VSTS_AGENT=$env:COMPUTERNAME
# VSO_AGENT_IGNORE contains comma delimited list of vars not to publish as capabilities by Agent
ENV VSO_AGENT_IGNORE="VSO_AGENT_IGNORE,VSTS_AGENT,TFS_URL,VSTS_TOKEN,VSTS_POOL"

WORKDIR C:/BuildAgent

COPY --from=agent ["C:/BuildAgent", "C:/BuildAgent"]

ENTRYPOINT .\bin\Agent.Listener.exe configure --unattended `
    --agent "$env:VSTS_AGENT" `
    --url "$env:TFS_URL" `
    --auth PAT `
    --token "$env:VSTS_TOKEN" `
    --pool "$env:VSTS_POOL" `
    --work "_work" `
    --replace; `
    .\bin\Agent.Listener.exe run
```

now build the image `my/azure-pipeline-dotnetcore:2.2`



See [Understand how ARG and FROM interact](https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact)

```Dockerfile
ARG  CODE_VERSION=latest
FROM base:${CODE_VERSION}
```