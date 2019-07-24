# escape=`

ARG tag=ltsc2019


FROM mcr.microsoft.com/windows/servercore:$tag AS download
ENV CADDY_VERSION 1.0.1
RUN powershell -Command $ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue'; `
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 ; `
    Invoke-WebRequest $('https://github.com/mholt/caddy/releases/download/v{0}/caddy_v{0}_windows_amd64.zip' -f $env:CADDY_VERSION) -OutFile 'caddy.zip' -UseBasicParsing ; `
    Expand-Archive -Path caddy.zip -DestinationPath C:\caddy -Force ; `
    rm caddy.zip


FROM mcr.microsoft.com/windows/servercore:$tag
COPY --from=download /caddy /caddy

WORKDIR C:\caddy

EXPOSE 80 443


COPY Caddyfile.windows C:\caddy\conf\Caddyfile
COPY web\ C:\wwwroot\

ENTRYPOINT [ "C:\\caddy\\caddy.exe" ]

# Run caddy pointing to the mounted Caddyfile
CMD [ "-conf", "C:\\caddy\\conf\\Caddyfile" ]