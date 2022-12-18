# Jenkins on GKE

[![Build](https://github.com/DevSecOpsSamples/gke-jenkins/actions/workflows/build.yml/badge.svg?branch=master)](https://github.com/DevSecOpsSamples/gke-jenkins/actions/workflows/build.yml) [![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=DevSecOpsSamples_gke-jenkins&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=DevSecOpsSamples_gke-jenkins) [![Lines of Code](https://sonarcloud.io/api/project_badges/measure?project=DevSecOpsSamples_gke-jenkins&metric=ncloc)](https://sonarcloud.io/summary/new_code?id=DevSecOpsSamples_gke-jenkins)

## Overview

Build Jenkins with plugins on GKE. Refer to the Pipelines with `podTemplate` in https://github.com/DevSecOpsSamples/jenkins-pipeline.

## Prerequisites

### Installation

- [Install the gcloud CLI](https://cloud.google.com/sdk/docs/install)
- [Install kubectl and configure cluster access](https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl)

### Set environment variables

```bash
COMPUTE_ZONE="us-central1"
PROJECT_ID="sample-project" # replace with your project
```

### Set GCP project

```bash
gcloud config set project ${PROJECT_ID}
gcloud config set compute/zone ${COMPUTE_ZONE}
```

## Step1: Create a GKE cluster

Create an Autopilot GKE cluster. It may take around 9 minutes.

```bash
gcloud container clusters create-auto jenkins-dev --region=${COMPUTE_ZONE}
gcloud container clusters get-credentials jenkins-dev
```

## Step2: Deploy jenkins-master

Create and deploy K8s Deployment, Service, Volume, Ingress, and GKE BackendConfig using a template file.

```bash
sed -e "s|<project-id>|${PROJECT_ID}|g" jenkins-master-template.yaml > jenkins-master.yaml
cat jenkins-master.yaml

kubectl apply -f jenkins-master.yaml
```

Confirm Jenkins credential from logs:

```bash
kubectl describe pods jenkins-master
kubectl logs -l app=jenkins-master
```

## Connect to Jenkins

```bash
LB_IP_ADDRESS=$(gcloud compute forwarding-rules list | grep jenkins-master | awk '{ print $2 }')
echo ${LB_IP_ADDRESS}
```

```bash
curl http://${LB_IP_ADDRESS}/
```

## Cleanup

```bash
kubectl delete -f jenkins-master.yaml
```

```bash
docker system prune -a
```

## References

* https://hub.docker.com/_/jenkins

* https://www.jenkins.io/doc/pipeline/steps/kubernetes/