#!/bin/bash
set -e

echo "PROJECT_ID: ${PROJECT_ID}"

docker build -t jenkins-master . --platform linux/amd64
docker tag jenkins-master:latest gcr.io/${PROJECT_ID}/jenkins-master:latest
docker push gcr.io/${PROJECT_ID}/jenkins-master:latest

kubectl scale deployment jenkins-master --replicas=0
kubectl rollout status deployment jenkins-master
kubectl scale deployment jenkins-master --replicas=1
kubectl rollout status deployment jenkins-master
kubectl get pods