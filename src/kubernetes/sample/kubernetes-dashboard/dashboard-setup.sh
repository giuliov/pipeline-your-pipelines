# Docker for Mac instructions
## source https://github.com/kubernetes/dashboard/
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml
kubectl proxy
## source https://github.com/kubernetes/dashboard/wiki/Creating-sample-user
kubectl apply -f dashboard-adminuser.yaml
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}')
# use the token to login