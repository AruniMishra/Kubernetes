# Kubernetes

- [Kubernetes](#kubernetes)
  - [Installation](#installation)
  - [commmand](#commmand)
    - [create minikube cluster](#create-minikube-cluster)
    - [kubectl](#kubectl)
    - [debugging](#debugging)
    - [create mongo deployment](#create-mongo-deployment)
    - [arch](#arch)

## Installation

- install minikube
- install kubectl

## commmand

### create minikube cluster

`minikube start --driver=docker`

`minikube status`

`kubectl version`

`kubectl get nodes`

`kubectl get pod`

`kubectl get services`

### kubectl

`kubectl create deployment nginx-depl --image=nginx`

`kubectl get deployment`

`kubectl get service`

`kubectl get pods`

`kubectl get replicaset`

`kubectl edit deployment nginx-depl`

`kubectl apply -f nginx-deployment.yaml`

`kubectl get pod -o wide`

`kubectl delete --all services`

### debugging

`kubectl logs {pod-name}`

`kubectl describe pod {pod-name}`

`kubectl get pod - o wide pod`

`kubectl describe service {service-name}`

`kubectl exec -it {pod-name} -- bin/bash`

`kubectl get all | grep mongodb`

### create mongo deployment

`kubectl create deployment mongo-depl --image=mongo`

### arch
