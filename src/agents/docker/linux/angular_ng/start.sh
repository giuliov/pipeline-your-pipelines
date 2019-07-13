#!/bin/bash
set -e

if [ -z "$AZP_URL" ]; then
  echo 1>&2 error: missing AZP_URL environment variable
  exit 1
fi

if [ -z "$AZP_TOKEN_FILE" ]; then
  if [ -z "$AZP_TOKEN" ]; then
    echo 1>&2 error: missing AZP_TOKEN environment variable
    exit 1
  fi
  AZP_TOKEN_FILE=/agent/.token
  echo -n $AZP_TOKEN > "$AZP_TOKEN_FILE"
fi
unset AZP_TOKEN

if [ -n "$AZP_AGENT_NAME" ]; then
  export AZP_AGENT_NAME="$(eval echo $AZP_AGENT_NAME)"
fi

if [ -n "$AZP_WORK" ]; then
  export AZP_WORK="$(eval echo $AZP_WORK)"
  mkdir -p "$AZP_WORK"
fi

cd /agent

export VSO_AGENT_IGNORE=_,MAIL,OLDPWD,PATH,PWD,AZP_AGENT_NAME,AZP_URL,AZP_TOKEN_FILE,AZP_TOKEN,AZP_POOL,AZP_WORK,VSO_AGENT_IGNORE
if [ -n "$VSTS_AGENT_IGNORE" ]; then
  export VSO_AGENT_IGNORE=$VSO_AGENT_IGNORE,VSTS_AGENT_IGNORE,$VSTS_AGENT_IGNORE
fi

source ./env.sh

./bin/Agent.Listener configure --unattended \
  --agent "${AZP_AGENT_NAME:-$(hostname)}" \
  --url "$AZP_URL" \
  --auth PAT \
  --token $(cat "$AZP_TOKEN_FILE") \
  --pool "${AZP_POOL:-Default}" \
  --work "${AZP_WORK:-_work}" \
  --replace & wait $!

./bin/Agent.Listener run & wait $!