#!/bin/bash
set -e

echo "PROJECT_ID: ${PROJECT_ID}"

docker build -t jenkins-master . --platform linux/amd64
docker tag jenkins-master:latest gcr.io/${PROJECT_ID}/jenkins-master:latest
docker push gcr.io/${PROJECT_ID}/jenkins-master:latest

kubectl scale deployment jenkins-master --replicas=0
kubectl scale deployment jenkins-master --replicas=1
sleep 3
kubectl get pods