az role definition list --custom-role-only true
az role definition create --role-definition powersp.json

SP_NAME="terraform-power"
APP_ID=$(az ad sp list --display-name $SP_NAME -o json --query "[0].appId")
az role assignment create --assignee ${APPID//\"} --role "Nice Service Principal"

#######

az aks show --resource-group pyp-k8s --name pyp-k8s-clu --query agentPoolProfiles

export KUBECONFIG=~/src/github.com/giuliov/pipeline-your-pipelines/src/kubernetes/terraform/azurek8s.config

kubectl config get-contexts

# deploy the container mix
kubectl apply -f sample/

# open the Dashboard
kubectl create clusterrolebinding kubernetes-dashboard --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard
az extension update --name aks-preview # OPTIONAL
az aks enable-addons --addons kube-dashboard --resource-group pyp-k8s --name pyp-k8s-clu
az aks browse --resource-group pyp-k8s --name pyp-k8s-clu