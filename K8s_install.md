# Kubernetes

- [Kubernetes](#kubernetes)
  - [Installation](#installation)
  - [commmand](#commmand)
    - [create minikube cluster](#create-minikube-cluster)
    - [kubectl](#kubectl)
    - [namespace](#namespace)
    - [debugging](#debugging)
    - [create mongo deployment](#create-mongo-deployment)
    - [ingress](#ingress)
    - [Kubernetes dashboard](#kubernetes-dashboard)

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

`kubectl get pods --all-namespaces`

`kubectl get replicaset`

`kubectl edit deployment nginx-depl`

`kubectl apply -f nginx-deployment.yaml`

`kubectl get pod -o wide`

`kubectl delete --all services`

### namespace

`kubectl create namespace my-namespace`

### debugging

`kubectl logs {pod-name}`

`kubectl describe pod {pod-name}`

`kubectl get pod - o wide pod`

`kubectl describe service {service-name}`

`kubectl exec -it {pod-name} -- bin/bash`

`kubectl get all | grep mongodb`

### create mongo deployment

`kubectl create deployment mongo-depl --image=mongo`

### ingress

`minikube addons enable ingress`

`kubectl get pod -n kube-system`

### Kubernetes dashboard

- The Dashboard UI is not deployed by default. To deploy it, run the following command:

`kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.5.0/aio/deploy/recommended.yaml`

Kubectl will make Dashboard available at [http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/]
`Kubectl proxy`

- steps for generating the token
  - Create the dashboard service account

    ```console
    kubectl create serviceaccount dashboard-admin-sa
    ```
  
  This will create a service account named dashboard-admin-sa in the default namespace

  - Next bind the dashboard-admin-service-account service account to the cluster-admin role

    ```shell
    kubectl create clusterrolebinding dashboard-admin-sa --clusterrole=cluster-admin --serviceaccount=default:dashboard-admin-sa
    ```

  - When we created the dashboard-admin-sa service account Kubernetes also created a secret for it. List secrets using:

    ```bash
    kubectl get secrets
    ```

  - Use kubectl describe to get the access token:

    ``` properties
    kubectl describe secret dashboard-admin-sa-token-kw7vn
    ```
