# Jenkins on GKE

[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=DevSecOpsSamples_gke-workload-identity&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=DevSecOpsSamples_gke-workload-identity) [![Lines of Code](https://sonarcloud.io/api/project_badges/measure?project=DevSecOpsSamples_gke-workload-identity&metric=ncloc)](https://sonarcloud.io/summary/new_code?id=DevSecOpsSamples_gke-workload-identity)

## Overview

## Objectives

## Table of Contents


## Prerequisites

### Installation

- [Install the gcloud CLI](https://cloud.google.com/sdk/docs/install)
- [Install gsutil](https://cloud.google.com/storage/docs/gsutil_install#install)
- [Install kubectl and configure cluster access](https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl)

### Set environment variables

```bash
PROJECT_ID="sample-project" # replace with your project
COMPUTE_ZONE="us-central1"
```

### Set GCP project

```bash
gcloud config set project ${PROJECT_ID}
gcloud config set compute/zone ${COMPUTE_ZONE}
```

## Step1: Create a GKE cluster

Create an Autopilot GKE cluster. It may take around 9 minutes.

```bash
gcloud container clusters create-auto jenkins --region=${COMPUTE_ZONE}
gcloud container clusters get-credentials jenkins
```

## Step2: Deploy jenkins-master

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


## Cleanup

```bash
kubectl delete -f jenkins-master.yaml
```

```bash
docker system prune -a
```

## References
