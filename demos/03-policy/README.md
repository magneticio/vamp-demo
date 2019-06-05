# Demo: Release Policy
This will demostrate the possiblity to release services into production using release policies.

## Setup
For this demo it's required to have the Vamp Release Agent running as workflow. The release agent should contain a valid policy which will be used to release the service.

We deploy the initial state of the demo using the `demo.sh` shell script and specify the environment name.
```sh
./demo.sh deploy -d=03-policy -n={name}
```

Navigate to the Release Agent UI and add the [hotfix-policy.json](hotfix-policy.json) to the release agent.

Verify if the vshop application is running at `http://vshop-policy.{name}.demo.vamp.cloud`

## Demostration

### Failing release
First we 

Add some load to the service using Apache Bench
```sh
ab -n 15000 -c 10 http://vshop-policy.{name}.demo.vamp.cloud/
```

Deploy a new version of the VShop service using the Kubernetes CLI.
```sh
kubectl apply -f ./demos/03-policy/vshop-v2.yaml
```

Once version 2.0.0 services 50% of the traffic, it will start reporting unhealthy. Because of this, the policy will fail the release and restore the traffic to version 1.0.0

## Succesfull release
Now we will release a new version of the service which has fixed the error.

Deploy a new version `2.0.1` of the VShop service using the Kubernetes CLI.
```sh
kubectl apply -f ./demos/03-policy/vshop-v3.yaml
```

You will see that the release is advancing with no problems and that eventually the new service is the currently released version of the service.

## Explanation
It's recommended to explain what the demostration will look like.

### Release Policy file
Show the policy file [hotfix-policy.json](hotfix-policy.json) and it's structure.

**Pointer**
* You can define your own steps.
* Each step has a weight for the source version and target version.
* You can define the metrics and baselines for a release and use that as condition to check before advancing to the next step.
* Once a service has succesfully release, there is the possibility to add a command to call a REST API to notify.

### Vamp Gateway configuration
Show the [Vamp Gateway](vshop-gateway.yaml) and explain how Vamp triggers the release.

**Pointer**
* All things happing within Vamp and the cluster are raised as events
* The Vamp Release Agent listens to those events and reacts.
* When a route has been added to a gateway the release agent will look at the `release.vamp.io/policy` metadata to see if is should trigger a release with that policy.
* The release agent looks a `release.vamp.io/current` metadata to determain what its current release is.
* If no release is found it tags the route with 100% of weight as current release.
* The release agent starts releasing the service according to it's policy.

### Releasing a service
With Vamp we demostrate the difference between deploying a service and releasing a service. We are using the Kubernetes CLI to 
