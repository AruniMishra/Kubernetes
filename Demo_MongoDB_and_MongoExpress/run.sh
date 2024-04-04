#!/bin/sh
kubectl apply -f mongo-configmap.yaml
kubectl apply -f mongo-secret.yml
kubectl apply -f mongo.yml
kubectl apply -f mongo-express.yaml
kubectl port-forward svc/mongo-express-service 30000:8081