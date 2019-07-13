FROM alpine AS agent

ENV AGENT_VERSION 2.153.2
ENV AGENT_SHA256 59566e23ee745f47a8391b59f9e3de596abb5cdf425dbcd2aba155e43b6f0ab9

WORKDIR /agent

RUN apk add --no-cache curl

RUN curl -o vsts-agent-linux-x64.tgz https://vstsagentpackage.azureedge.net/agent/${AGENT_VERSION}/vsts-agent-linux-x64-${AGENT_VERSION}.tar.gz \
    && echo "${AGENT_SHA256} *vsts-agent-linux-x64.tgz" | sha256sum -c - \
    && tar zxvf vsts-agent-linux-x64.tgz \
    && rm vsts-agent-linux-x64.tgz


# ----- toolchain start -----
FROM node:12.6.0
# ----- toolchain end -----

# Azure Pipelines agent require git 2.9 or later
RUN apt-get install git -y

COPY --from=agent ["/agent", "/agent"]

USER root
WORKDIR /agent
COPY ./start.sh .
RUN chmod 755 start.sh

ENTRYPOINT ["/bin/bash", "-c","/agent/start.sh"]