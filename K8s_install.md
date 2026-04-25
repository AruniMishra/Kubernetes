# Kubernetes

- [Kubernetes](#kubernetes)
  - [Installation](#installation)
  - [commmand](#commmand)
    - [create minikube cluster](#create-minikube-cluster)
    - [kubectl](#kubectl)
    - [namespace](#namespace)
    - [debugging](#debugging)
    - [create mongo deployment](#create mongo db deployment(docker pull mongo))
    - [ingress](#ingress)
    - [Kubernetes dashboard](#kubernetes-dashboard)

## Installation

- install minikube
- install kubectl

## commmand

### create minikube cluster

`minikube delete --all`

`minikube start --driver=docker`

`minikube status`

`kubectl version`

`kubectl get nodes`

`kubectl get pod`

`kubectl get services`

### kubectl

`kubectl get deployment`

`kubectl get service`

`kubectl get pods`

`kubectl get pods --all-namespaces`

`kubectl get replicaset`

`kubectl edit deployment nginx-depl`

`kubectl apply -f nginx-deployment.yaml`

`kubectl get pod -o wide`

`kubectl delete --all services`

`kubectl delete daemonsets,replicasets,services,deployments,pods,rc,ingress --all --all-namespaces`

### namespace

`kubectl create namespace my-namespace`

`kubectl api-resources --namespaced=false`

`kubectl api-resources --namespaced=true`

### debugging

`kubectl logs {pod-name}`

`kubectl describe pod {pod-name}`

`kubectl get pod - o wide pod`

`kubectl describe service {service-name}`

`kubectl exec -it {pod-name} -- bin/bash`

`kubectl get all | grep mongodb`

### create mongo db deployment(docker pull mongo)

`kubectl create deployment mongo-depl --image=mongo`

`kubectl get deployment nginx-deployment -o yaml > ngnix-deployment-result.yaml`

### create nginx deployment(docker pull nginx)

`kubectl create deployment nginx-depl --image=nginx`

### ingress

`minikube addons enable ingress`

`kubectl get pods -n ingress-nginx`

### Kubernetes dashboard

- OLD

  - The Dashboard UI is not deployed by default. To deploy it, run the following command:

  `kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.5.0/aio/deploy/recommended.yaml`

  Kubectl will make Dashboard available at [http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/]  
  `Kubectl proxy`

  - kubectl port-forward  
    Instead of kubectl proxy, you can use kubectl port-forward and access dashboard with simpler URL than using kubectl proxy
    
    To access Kubernetes Dashboard go to:

    ```shell
    https://localhost:8080
    ```

  - Reference [https://github.com/kubernetes/dashboard/blob/master/docs/user/accessing-dashboard/README.md]

- NEW

  - install [helm](https://helm.sh/docs/intro/install/)

  - create a service account
    - create dashboard-adminuser.yaml and use kubectl apply -f dashboard-adminuser.yaml to create them.

    ```bash
    # Add kubernetes-dashboard repository
    helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
    
    # Deploy a Helm Release named "kubernetes-dashboard" using the kubernetes-dashboard chart
    helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --create-namespace --namespace kubernetes-dashboard
    
    ```

  - kubectl -n NAMESPACE create token SERVICE_ACCOUNT
    ```bash
    kubectl -n kubernetes-dashboard create token admin-user

    
    kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy 8443:443
    ```

- steps for generating the token
  - Create the dashboard service account

    ```console
    kubectl create serviceaccount dashboard-admin-sa
    ```
  
    This will create a service account named dashboard-admin-sa in the default namespace

  - Next bind the dashboard-admin-service-account service account to the cluster-admin role

    ```console
    kubectl create clusterrolebinding dashboard-admin-sa --clusterrole=cluster-admin --serviceaccount=default:dashboard-admin-sa
    ```

  - When we created the dashboard-admin-sa service account Kubernetes also created a secret for it. List secrets using:

    ```console
    kubectl get secrets
    ```

  - Use kubectl describe to get the access token:

    ```console
    kubectl describe secret dashboard-admin-sa-token-kw7vn
    ```

- get all namespaces

`kubectl get ingress --all-namespaces`
`kubectl describe ingress dashboard-ingress -n kubernetes-dashboard`

