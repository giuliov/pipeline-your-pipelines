FROM alpine AS agent

ENV AGENT_VERSION 2.175.2
ENV AGENT_SHA256 4a7e74002f5f5764bf123d03952cb029fa6789f105f894d9b865f34fc04ed5c1

WORKDIR /agent

RUN apk add --no-cache curl

RUN curl -o vsts-agent-linux-x64.tgz https://vstsagentpackage.azureedge.net/agent/${AGENT_VERSION}/vsts-agent-linux-x64-${AGENT_VERSION}.tar.gz \
    && echo "${AGENT_SHA256} *vsts-agent-linux-x64.tgz" | sha256sum -c - \
    && tar zxvf vsts-agent-linux-x64.tgz \
    && rm vsts-agent-linux-x64.tgz


# ----- toolchain start -----
FROM node:12.19.0
# ----- toolchain end -----

# Azure Pipelines agent require git 2.9 or later
RUN apt-get install git -y

COPY --from=agent ["/agent", "/agent"]

USER root
WORKDIR /agent
COPY ./start.sh .
RUN chmod 755 start.sh

ENTRYPOINT ["/bin/bash", "-c","/agent/start.sh"]