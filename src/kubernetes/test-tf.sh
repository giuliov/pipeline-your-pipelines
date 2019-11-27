export KUBECONFIG=~/src/github.com/giuliov/pipeline-your-pipelines/src/kubernetes/terraform/azurek8s.config

kubectl config get-contexts

# deploy the container mix
kubectl apply -f sample/

# open the Dashboard
kubectl create clusterrolebinding kubernetes-dashboard --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard
az extension update --name aks-preview # OPTIONAL
az aks enable-addons --addons kube-dashboard --resource-group pyp-k8s --name pyp-k8s-clu
az aks browse --resource-group pyp-k8s --name pyp-k8s-clu