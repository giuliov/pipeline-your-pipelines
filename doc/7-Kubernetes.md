
Docker multi-platform
https://medium.com/@mauridb/docker-multi-architecture-images-365a44c26be6

```bash
# Install the aks-preview extension
az extension add --name aks-preview
# Update the extension to make sure you have the latest version installed
az extension update --name aks-preview

# Turn on preview features
az feature register --name MultiAgentpoolPreview --namespace Microsoft.ContainerService
az feature register --name VMSSPreview --namespace Microsoft.ContainerService
az feature register --name AKSAzureStandardLoadBalancer --namespace Microsoft.ContainerService

# Wait for configuration to settle
az feature list -o table --query "[?contains(name, 'Microsoft.ContainerService/MultiAgentpoolPreview')].{Name:name,State:properties.state}"
az feature list -o table --query "[?contains(name, 'Microsoft.ContainerService/VMSSPreview')].{Name:name,State:properties.state}"
az feature list -o table --query "[?contains(name, 'Microsoft.ContainerService/AKSAzureStandardLoadBalancer')].{Name:name,State:properties.state}"

# refresh
az provider register --namespace Microsoft.ContainerService
```

K8S version 1.13.5+
1.13.7
1.14.3

## Kubernets
Two samples
https://anthonychu.ca/post/vsts-agent-docker-kubernetes/
https://www.chrisjohnson.io/2018/07/07/using-azure-kubernetes-service-aks-for-your-vsts-build-agents/
Helm chart!
https://github.com/Azure/helm-vsts-agent
some elements here about security
https://cloudblogs.microsoft.com/opensource/2018/11/27/tutorial-azure-devops-setup-cicd-pipeline-kubernetes-docker-helm/
more tips
https://www.reddit.com/r/devops/comments/ax0ep1/azure_devops_agents_on_kubernetes_cluster_with/?utm_source=share&utm_medium=web2x
more examples from mohitgoyal
https://webcache.googleusercontent.com/search?q=cache:o8GJmeBSfE4J:https://mohitgoyal.co/2019/01/05/running-azure-devops-private-agents-as-docker-containers/+&cd=1&hl=en&ct=clnk&gl=ie&client=firefox-b-d
https://webcache.googleusercontent.com/search?q=cache:ZhaCg0ZIfW4J:https://mohitgoyal.co/2019/01/10/run-azure-devops-private-agents-in-kubernetes-clusters/+&cd=6&hl=en&ct=clnk&gl=ie&client=firefox-b-d

Do not forget to mention Jakob
https://blog.ehn.nu/2019/01/creating-a-windows-container-build-agent-for-azure-pipelines/
and
https://mobilefirstcloudfirst.net/2018/10/containerized-build-pipeline-azure-devops/
and
https://github.com/Lambda3/docker-azure-pipelines-agent/blob/master/agent/Dockerfile
and Pretty good job, how I missed this?
https://medium.com/@brentrobinson5/containerised-ci-cd-pipelines-with-azure-devops-74064c679f20
and this kool one
https://www.danielstechblog.io/using-an-azure-pipelines-agent-on-a-k3s-kubernetes-cluster-on-raspbian/