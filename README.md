# Jenkins on GKE

[![Build](https://github.com/DevSecOpsSamples/gke-jenkins/actions/workflows/build.yml/badge.svg?branch=master)](https://github.com/DevSecOpsSamples/gke-jenkins/actions/workflows/build.yml) [![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=DevSecOpsSamples_gke-jenkins&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=DevSecOpsSamples_gke-jenkins) [![Lines of Code](https://sonarcloud.io/api/project_badges/measure?project=DevSecOpsSamples_gke-jenkins&metric=ncloc)](https://sonarcloud.io/summary/new_code?id=DevSecOpsSamples_gke-jenkins)

## Overview

Build Jenkins with plugins on GKE. Refer to the Pipelines with `podTemplate` in https://github.com/DevSecOpsSamples/jenkins-pipeline.

## Table of Contents


- [Prerequisites](#prerequisites)
- [Step1: Create a GKE cluster](#step1-create-a-gke-cluster)
- [Step2: Create a GCP service account and Kubernetes service account](#step2-create-a-gcp-service-account-and-kubernetes-service-account)
- [Step3: Build a Dokcer image](#step3-build-a-dokcer-image)
- [Step4: Deploy the jenkins-master](#step4-deploy-the-jenkins-master)
- [Cleanup](#cleanup)

## Prerequisites

### Installation

Before you begin, you need to install the following:

- [Install the gcloud CLI](https://cloud.google.com/sdk/docs/install)
- [Install kubectl and configure cluster access](https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl)

### Set environment variables

```bash
# echo "export PROJECT_ID=<your-project-id>" >> ~/.bashrc
PROJECT_ID="<your-project-id>"
COMPUTE_ZONE="us-central1"
ENV="dev"
```

### Set GCP project

```bash
gcloud config set project ${PROJECT_ID}
gcloud config set compute/zone ${COMPUTE_ZONE}
```

## Step1: Create a GKE cluster

Create an Autopilot GKE cluster. This process may take around 9 minutes.

```bash
gcloud container clusters create-auto jenkins-${ENV} --region=${COMPUTE_ZONE}
gcloud container clusters get-credentials jenkins-${ENV}
```

## Step2: Create a GCP service account and Kubernetes service account

```bash
SERVICE_ACCOUNT="jenkins-worker"
echo "PROJECT_ID: ${PROJECT_ID}, ENV: ${ENV}, SERVICE_ACCOUNT: ${SERVICE_ACCOUNT}"
```

```bash
gcloud iam service-accounts create ${SERVICE_ACCOUNT} --display-name="Jenkins service account for workload identity"
kubectl create namespace jenkins-${ENV}
kubectl create serviceaccount --namespace jenkins-${ENV} ${SERVICE_ACCOUNT}
```

```bash
kubectl annotate serviceaccount --namespace jenkins-${ENV} jenkins-worker \
        iam.gke.io/gcp-service-account=${SERVICE_ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com
```

- Grant the 'container.developer' role to run a Jenkins Job as a new Pod in a GKE cluster.

```bash
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member serviceAccount:${SERVICE_ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com \
  --role roles/container.developer
```

## Step3: Build a Dokcer image

```bash
docker build -t jenkins-master:v1 . --platform linux/amd64
docker tag jenkins-master:v1 gcr.io/${PROJECT_ID}/jenkins-master:v1
docker push gcr.io/${PROJECT_ID}/jenkins-master:v1
```

## Step4: Deploy the jenkins-master

Create and deploy K8s Deployment, Service, Volume, Ingress, and GKE BackendConfig using a template file.

```bash
sed -e "s|<project-id>|${PROJECT_ID}|g" jenkins-master-template.yaml > jenkins-master.yaml
cat jenkins-master.yaml
```

```bash
echo "PROJECT_ID: ${PROJECT_ID}, ENV: ${ENV}, SERVICE_ACCOUNT: ${SERVICE_ACCOUNT}"
kubectl get namespaces
# In general, namespace use the suffix per stage such as jenkins-dev, jenkins-stg nad jenkins-prod. You HAVE TO check the namespace with 'kubectl get namespaces' command before apexecuting the command.
kubectl apply -f jenkins-master.yaml --dry-run=server -n jenkins-${ENV}
```

```bash
kubectl apply -f jenkins-master.yaml -n jenkins-${ENV}
```

Confirm Jenkins credential from logs:

```bash
kubectl describe pods jenkins-master -n jenkins-${ENV}
kubectl logs -l app=jenkins-master -n jenkins-${ENV}
```

### Connect to Jenkins

```bash
LB_IP_ADDRESS=$(gcloud compute forwarding-rules list | grep jenkins-master | awk '{ print $2 }')
echo ${LB_IP_ADDRESS}
```

```bash
curl http://${LB_IP_ADDRESS}/
```

## Cleanup

```bash
kubectl delete -f jenkins-master.yaml -n jenkins-${ENV}
kubectl delete namespace jenkins-${ENV}
```

```bash
docker system prune -a
```

## References

* https://hub.docker.com/_/jenkins

* https://www.jenkins.io/doc/pipeline/steps/kubernetes/