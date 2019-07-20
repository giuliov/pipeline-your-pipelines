#!/bin/bash
set -e

AZP_URL=${azuredevops_url}
AZP_TOKEN=${azuredevops_pat}
AZP_POOL=${azuredevops_pool_hosts}

export AGENT_ALLOW_RUNASROOT=1
export DEBIAN_FRONTEND=noninteractive

sudo apt-get install -qy docker.io
## see https://docs.docker.com/install/linux/linux-postinstall/
sudo usermod -aG docker $(whoami)

# install Powershell 6
# see https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux?view=powershell-6
wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt-get update -qy
sudo add-apt-repository -y universe
sudo apt-get install -qy powershell

unset DEBIAN_FRONTEND

# finally get and configure the agent
curl https://vstsagentpackage.azureedge.net/agent/2.153.2/vsts-agent-linux-x64-2.153.2.tar.gz -o vsts-agent-linux-x64-2.153.2.tar.gz
echo "59566e23ee745f47a8391b59f9e3de596abb5cdf425dbcd2aba155e43b6f0ab9 *vsts-agent-linux-x64-2.153.2.tar.gz" | sha256sum -c -
if [ $? != 0 ]; then
  echo "Downloaded package doesn't match the hash!"
  exit 1
fi
mkdir pipeline-agent
cd pipeline-agent
tar zxvf ../vsts-agent-linux-x64-2.153.2.tar.gz
echo AAA AGENT DOWNLOADED
sudo ./bin/installdependencies.sh
echo AAA DEPENDENCIES INSTALLED
./config.sh --unattended --url $AZP_URL --auth pat --token $AZP_TOKEN --pool $AZP_POOL --agent $(hostname) --replace --acceptTeeEula
echo AAA SETTING UP AGENT SERVICE
sudo ./svc.sh install
sudo ./svc.sh start
echo AAA AGENT INSTALLED
