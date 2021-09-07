# k8s-kong-terraform

Create a Kubernetes cluster using Kong as an ingress running in Azure AKS

This entire project is built using Terraform.

Once deployed, a sample NGINX HTTP application will be up and running for you to test.

## Prerequisites

You will need a few things to use this project:

1. An Azure account (this project uses AKS)
2. [tfenv](https://github.com/tfutils/tfenv)
3. A [Terraform Cloud](https://www.terraform.io/cloud) account to store your TF state remotely
    - See the [`terraform-cloud`](docs/terraform-cloud.md) docs in this repo for more info
4. Azure credentials to run Terraform deployments. An example to create creds can be seen below (easy):
    - `az ad sp create-for-rbac --skip-assignment`
    - Copy the resulting `appId` and `password` to -> `terraform/k8s-cluster/terraform.auto.tfvars.json`
5. You will need to skim through the following files and edit the lines with comments:
    - [`terraform\k8s\versions.tf`](terraform\k8s\versions.tf)
    - [`terraform\k8s-cluster\versions.tf`](terraform\k8s-cluster\versions.tf)
    - [`terraform\k8s\k8s-cluster.tf`](terraform\k8s\k8s-cluster.tf)
    - [`terraform\k8s-cluster\k8s-cluster.tf`](terraform\k8s-cluster\k8s-cluster.tf)

## Usage

Build a K8s cluster with a single command!

```console
$ make build

🔨 Let's build a K8s cluster!
✅ tfenv is installed
✅ terraform/k8s-cluster/terraform.auto.tfvars.json exists
✅ terraform/k8s-cluster/terraform.auto.tfvars.json contains non-default credentials
🚀 Deploying 'terraform/k8s-cluster'...
🚀 Deploying 'terraform/k8s'...
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
💥 Destroying 'terraform/k8s'...
💥 Destroying 'terraform/k8s-cluster'...
✨ Done! ✨
```

## Project Folder Information 📂

- `script/` - Contains various scripts for deployments and maintenance
- `terraform/k8s-cluster` - The main terraform files for building the infrastructure of the K8s cluster. This folder contains configurations for the amount of K8s nodes, their VM size, their storage, etc
- `terraform/k8s` - The main terraform files for how K8s and its related services are configured. In here you will find definitions for Kong and the containers which run in K8s
- `terraform/k8s/modules` - More or less just used as folders for to organize Terraform HCL files
- `terraform/k8s/modules/kong` - The configuration for Kong. Split into the `base`, `plugins`, and `routes`. You will most often be editing the `routes` file for new API routes
- `terraform/k8s/modules/containers` - Each sub folder in this folder is for creating new containers/resources that you want to deploy to your K8s cluster
  - See the `terraform/k8s/modules/containers/nginx_example` folder and view the `terraform/k8s/main.tf` file for how we can create a K8s deployment + service in an organized manner

## Purpose 💡

The purpose of this project/repo is to quickly build a minimal K8s cluster with Kong + Terraform to get a project going.
