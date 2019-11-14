# Vamp Demo Environment

This repository contains the required infrastructure, service and artifacts to demo Vamp.

> Current Version: 1.2.0 (untested)

## Installation

Please make sure that the following tools are available on your machine:

- Vamp CLI: [Installation](https://vamp.io/documentation/cli/using-the-cli/)
- Kubernetes CLI: [Installation](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- Google Cloud CLI \*: [Installation](https://cloud.google.com/sdk/docs/#install_the_latest_cloud_tools_version_cloudsdk_current_version)

_\* Not needed for local usage_

> Note: Currently only MacOS 10.14+ is tested

### Local

Skips the creation of a Kubernetes cluster and deploys Vamp and it's services to the current context defined by kubectl.

```sh
./demo.sh create
```

### Google Cloud Platform

Used Google Cloud's GKE (Google Kubernetes Engine) for cluster creation.

```sh
./demo.sh create -c=gcloud -n=vamp$RANDOM
```

> Note: If you start with a fresh cluster you are asked to provide your Docker Hub username and password which are used to fetch the Vamp container image. This will change when we enable support for public releases.

## Demos

### 01: Canary Release

This demonstrates a canary release using a scripted Vamp workflow.

- [Guide](./demos/01-canary/README.md)
- [Resources](./demos/01-canary)

```sh
./demo.sh deploy -d=01-canary
```

### 02: A/B Experiment

This demonstrates how to perform a A/B Test driven release with custom metrics

- [Guide](./demos/02-experiment/README.md)
- [Resources](./demos/02-experiment)

```sh
./demo.sh deploy -d=02-experiment
```

### 03: Release Policies

This demonstrates the usage of releasing service using custom release policies.

- [Guide](./demos/03-policy/README.md)
- [Resources](./demos/03-policy)

```sh
./demo.sh deploy -d=03-policy
```

### 04: Particles

This visually demonstrates the usage of releasing services using custom release policies.

- [Guide](./demos/04-particles/README.md)
- [Resources](./demos/04-particles)

```sh
./demo.sh deploy -d=04-particles
```

## Usage

The `demo.sh` script is used to create, update, deploy and destroy the environment and demos.

### Commands

| Command  | Description                                               | Example                                    |
| -------- | --------------------------------------------------------- | ------------------------------------------ |
| create   | Creates a new demo environment                            | ./demo.sh create -c=gcloud -n=vamp\$RANDOM |
| update   | Updates the demo environment's resources and installation | ./demo.sh update                           |
| destroy  | Destroys the demo environment and created cluster         | ./demo.sh destroy                          |
| deploy   | Deploys a demo into the demo environment                  | ./demo.sh deploy -d=01-canary              |
| run      | Runs a demo                                               | ./demo.sh run -d=04-policies               |
| undeploy | Removes a demo from the demo environment                  | ./demo.sh undeploy -d=01-canary            |

### Parameters

| Command        | Description                                                                                  | Example                                    |
| -------------- | -------------------------------------------------------------------------------------------- | ------------------------------------------ |
| -c/--cloud     | Specifies the cloud where the Kubernetes cluster will be created                             | ./demo.sh create -c=gcloud                 |
| -n/--name      | Specifies the name which is used in the demos and generated URLs                             | ./demo.sh create -c=gcloud -n=vamp\$RANDOM |
| -v/--version   | Specifies the Vamp version which will be deployed in the environment. Defaults to the latest | ./demo.sh create -v=ci-750-master          |
| -d/--demo      | Specifies the demo which will be deployed to the demo environment                            | ./demo.sh deploy -d=01-canary              |
| --skip-cluster | Skips the creation of a cluster and goes directly to deploying Vamp                          | ./demo.sh deploy -c=gcloud --skip-cluster  |

## Teardown

```sh
./demo.sh destroy
```

## Vamp Health
The Vamp Health metric is a composite of:
- The ratio of service errors (5xx responses) to all other responses. 5xx errors are a good indication that the service is unhealthy
- Stability of the Kubernetes Deployment. Not being able to attain or maintain the requested number of replicas is another good indication that the service is unhealthy

### Deployment Stability
- Having the minimum replicas available
- Variance in Pod restart count
- Difference between requested and available replicas

The current calculation is documented here: in readme for the quntification workflow
