# Meta-pipelines - Part 5 - Automating the Host Environment

Looking back at the previous parts of this series, we have been able to manually setup two hosts, a Windows one and a Linux one, and a simple pipeline to automatically deploy new Azure DevOps/TFS Agents in Docker containers on such hosts and even update them.

In this post we will look how to provision the hosts using a tool like Terraform and invoke it from Azure Pipelines so we can automate host creation in Azure.

If you need a Terraform primer there is plenty of resources, from the excellent [Terraform: Up & Running](https://www.terraformupandrunning.com/) to the [official documentation](https://www.terraform.io/docs/index.html), Pluralsight courses, etc.



## Blueprinting

Terraform will provision the virtual machines to host our Docker containers. The full source code is in the [repository](https://github.com/giuliov/pipeline-your-pipelines), here we will highlight and comment some major points.

The blueprint will have a Resource Group for these Hosts, two sets of Virtual Machines, one for Windows, one for Linux, an Azure Container Registry to store the agent images and a Key Vault for passwords and certificates.

```terraform

```

## Applying the blueprint
TODO 

