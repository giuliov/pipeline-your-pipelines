IMAGE_NAME=caddy-test
IMAGE_VERSION=1.0.1

docker manifest create --amend                    \
  $ACR_HOSTNAME/$IMAGE_NAME:$IMAGE_VERSION        \
  $ACR_HOSTNAME/$IMAGE_NAME:$IMAGE_VERSION-linux  \
  $ACR_HOSTNAME/$IMAGE_NAME:$IMAGE_VERSION-windows
docker manifest annotate --os linux $ACR_HOSTNAME/$IMAGE_NAME:$IMAGE_VERSION $ACR_HOSTNAME/$IMAGE_NAME:$IMAGE_VERSION-linux
docker manifest annotate --os windows $ACR_HOSTNAME/$IMAGE_NAME:$IMAGE_VERSION $ACR_HOSTNAME/$IMAGE_NAME:$IMAGE_VERSION-windows

docker manifest push $ACR_HOSTNAME/$IMAGE_NAME:$IMAGE_VERSION
