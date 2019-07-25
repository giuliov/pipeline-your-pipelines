$IMAGE_NAME = "caddy-test"
$IMAGE_VERSION = "1.0.1"

docker build --platform windows -t $ACR_HOSTNAME/$IMAGE_NAME:$IMAGE_VERSION-windows .
docker login $ACR_HOSTNAME
# use azurerm_client_id & azurerm_client_secret
docker push $ACR_HOSTNAME/$IMAGE_NAME