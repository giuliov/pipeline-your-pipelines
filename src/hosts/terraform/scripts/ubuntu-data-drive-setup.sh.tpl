#!/bin/bash
#set -x # uncomment to debug
set -e

AZP_URL=${azuredevops_url}
AZP_TOKEN=${azuredevops_pat}
AZP_POOL=${azuredevops_pool_hosts}

# mount data disk
parted --script /dev/sdc mklabel gpt
parted --script --align optimal /dev/sdc mkpart primary 0% 100%
blockdev --rereadpt -v /dev/sdc
mke2fs -q -t ext4 -L "dockerdata" /dev/sdc1
mkdir -p /docker-data
echo "UUID=$(blkid | grep /dev/sdc1 | cut -d\" -f4)   /docker-data   ext4   defaults,nofail   1   2" >> /etc/fstab
mount -a

export DEBIAN_FRONTEND=noninteractive

apt-get -qq -o=Dpkg::Use-Pty=0 install -qy docker.io
# move docker working directory
chown root:root /docker-data && chmod 701 /docker-data
cat >/etc/docker/daemon.json <<EOL
{
    "data-root": "/docker-data"
}
EOL
service docker restart
## see https://docs.docker.com/install/linux/linux-postinstall/
usermod -aG docker $(whoami)

# install Powershell 6
# see https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux?view=powershell-6
wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb
dpkg -i packages-microsoft-prod.deb
apt-get -qq -o=Dpkg::Use-Pty=0 update -qy
add-apt-repository -y universe
apt-get -qq -o=Dpkg::Use-Pty=0 install -qy powershell

unset DEBIAN_FRONTEND

# finally get and configure the agent
curl https://vstsagentpackage.azureedge.net/agent/2.175.2/vsts-agent-linux-x64-2.175.2.tar.gz -o vsts-agent-linux-x64-2.175.2.tar.gz
echo "4a7e74002f5f5764bf123d03952cb029fa6789f105f894d9b865f34fc04ed5c1 *vsts-agent-linux-x64-2.175.2.tar.gz" | sha256sum -c -
if [ $? != 0 ]; then
  echo "Downloaded package doesn't match the hash!"
  exit 1
fi
mkdir pipeline-agent
cd pipeline-agent
tar zxvf ../vsts-agent-linux-x64-2.175.2.tar.gz
# ./bin/installdependencies.sh
export AGENT_ALLOW_RUNASROOT=1
./config.sh --unattended --url $AZP_URL --auth pat --token $AZP_TOKEN --pool $AZP_POOL --agent $(hostname) --replace --acceptTeeEula
./svc.sh install
./svc.sh start
