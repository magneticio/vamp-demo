# Vamp Demo Environment
This repository contains the required infrastructure, service and artifacts to demo Vamp.

## Installation
Please make sure that the following tools are available on your machine:
* Vamp CLI: [Installation](https://vamp.io/documentation/cli/using-the-cli/)
* Terraform *: [Download](https://www.terraform.io/downloads.html) | [Homebrew](https://formulae.brew.sh/formula/terraform)
* Kubernetes CLI: [Installation](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
* Google Cloud CLI *: [Installation](https://cloud.google.com/sdk/docs/#install_the_latest_cloud_tools_version_cloudsdk_current_version)

_* Not needed for local usage_

> Note: Currently only MacOS 10.14+ is tested

## Clouds

### Local
Skips the creation of a Kubernetes cluster and deploys Vamp and it's services to the current context defined by kubectl.

```sh
./demo.sh build -c=local
```

### Google Cloud Platform
```sh
./demo.sh build -c=gcloud
```

> Note: If you start with a fresh cluster you are asked to provide your Docker Hub username and password which are used to fetch the Vamp container image. This will change when we enable support for public releases.

## Teardown

```sh
./demo.sh destroy -c=local
```
