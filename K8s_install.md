# Kubernetes

- [Kubernetes](#kubernetes)
  - [Installation](#installation)
  - [commmand](#commmand)
    - [create minikube cluster](#create-minikube-cluster)
    - [kubectl](#kubectl)
    - [debugging](#debugging)
    - [create mongo deployment](#create-mongo-deployment)

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

`kubectl get pods`

`kubectl get replicaset`

`kubectl edit deployment nginx-depl`

### debugging

`kubectl logs {pod-name}`

`kubectl exec -it {pod-name} -- bin/bash`

### create mongo deployment

`kubectl create deployment mongo-depl --image=mongo`
