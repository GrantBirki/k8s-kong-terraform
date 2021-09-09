# k8s-kong-terraform

Create a Kubernetes cluster using Kong as an ingress running in Azure AKS using Terraform! (and a mix of K8s manifests 😉)

Once deployed, a sample NGINX HTTP application will be up and running for you to test.

## What you will create

- A Kubernetes Cluster running on Azure Kubernetes Service (AKS)
- A K8s ingress that uses [Kong](https://konghq.com/)
- Grafana/Prometheus dashboards for viewing network metrics from Kong (made for you)
- A sample NGINX application which serves HTTP requests (loadbalanced by Kong)

## Prerequisites

You will need a few things to use this project:

1. An Azure account (this project uses AKS)
1. [tfenv](https://github.com/tfutils/tfenv) (for managing Terraform versions)
1. [kubectl](https://kubernetes.io/docs/tasks/tools/) (for applying K8s manifests)
1. [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
1. A [Terraform Cloud](https://www.terraform.io/cloud) account to store your TF state remotely
    - See the [`terraform-cloud`](docs/terraform-cloud.md) docs in this repo for more info
1. Azure credentials to run Terraform deployments. An example to create creds can be seen below (easy):
    - `az ad sp create-for-rbac --skip-assignment`
    - Copy the resulting `appId` and `password` to -> `terraform/k8s-cluster/terraform.auto.tfvars.json`
1. You will need to skim through the following files and edit the lines with comments:
    - [`terraform\k8s-cluster\versions.tf`](terraform\k8s-cluster\versions.tf)
    - [`terraform\k8s-cluster\variables.tf`](terraform\k8s-cluster\variables.tf)

## Usage

Build a K8s cluster with a single command!

```console
$ make build

🔨 Let's build a K8s cluster!
✅ tfenv is installed
✅ Azure CLI is installed
✅ kubectl is installed
✅ terraform/k8s-cluster/terraform.auto.tfvars.json exists
✅ terraform/k8s-cluster/terraform.auto.tfvars.json contains non-default credentials
🚀 Deploying 'terraform/k8s-cluster'...
⛵ Configuring kubectl environment
🔨 Time to build K8s resources and apply their manifests on the cluster!
✅ All manifests applied successfully
🦍 Kong LoadBalancer IP: 123.123.123.123
📊 Run 'script/grafana' to connect to the Kong metrics dashboard
✨ Done! ✨
```

The K8s cluster uses Kong as a Kubernetes Ingress Controller and comes with a sample NGINX backend to serve HTTP requests

To get the external IP of your `kong-proxy`, log into your Azure account and check your `Services and Ingresses` section of your newly deployed K8s cluster. You will see a link to the extranal IP of your new LoadBalancer to make an HTTP request for testing.

When you are done using your K8s cluster, you may destroy it by executing the following command:

```console
$ make destroy

💥 Let's DESTROY your K8s cluster!
Continue with the complete destruction of your K8s cluster (y/n)? y
✅ Approval for destroy accepted
✅ tfenv is installed
✅ terraform/k8s-cluster/terraform.auto.tfvars.json exists
✅ terraform/k8s-cluster/terraform.auto.tfvars.json contains non-default credentials
💥 Destroying 'terraform/k8s-cluster'...
✨ Done! ✨
```

## Project Folder Information 📂

- `script/` - Contains various scripts for deployments and maintenance
- `terraform/k8s-cluster` - The main terraform files for building the infrastructure of the K8s cluster. This folder contains configurations for the amount of K8s nodes, their VM size, their storage, etc
- `k8s/*` - Kubernetes deployment manifests for Kong, Grafana/Prometheus, and the NGINX example http server

## Purpose 💡

The purpose of this project/repo is to quickly build a minimal K8s cluster with Kong + Terraform to get a project going.
