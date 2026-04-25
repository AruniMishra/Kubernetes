# Kubernetes Learning Repository Documentation

## Overview

This repository is a comprehensive Kubernetes learning and configuration resource containing example deployments, configurations, and guides for setting up various Kubernetes workloads. It includes Nginx deployments, MongoDB with MongoExpress setups, Kubernetes dashboard configurations, and CKAD (Certified Kubernetes Application Developer) learning materials.

---

## Table of Contents

1. [Repository Structure](#repository-structure)
2. [Core Components](#core-components)
3. [Configuration Modules](#configuration-modules)
4. [Setup Guides](#setup-guides)
5. [Command Reference](#command-reference)
6. [Troubleshooting](#troubleshooting)

---

## Repository Structure

```
Kubernetes/
├── K8s_install.md                 # Installation & command reference guide
├── nginx-deployment.yaml          # Nginx deployment configuration
├── nginx-service.yaml             # Nginx service configuration
├── ckad/                          # CKAD exam preparation materials
│   ├── editPod.md                # Pod editing guide
│   └── misc.md                    # Miscellaneous CKAD notes
├── dashboard/                     # Kubernetes dashboard setup
│   ├── dashboard-adminuser.yaml   # Dashboard service account
│   └── dashboard-clusterRoleBinding.yaml  # RBAC binding for dashboard admin
├── kubernetes-ingress/            # Ingress configurations
│   └── dashboard-ingress.yaml     # Dashboard ingress routing
├── Demo_MongoDB_and_MongoExpress/ # Full MongoDB + MongoExpress stack
│   ├── docker-compose.yml         # Docker Compose alternative
│   ├── mongo.yml                  # MongoDB deployment
│   ├── mongo-express.yaml         # MongoExpress deployment
│   ├── mongo-configmap.yaml       # MongoDB connection config
│   ├── mongo-secret.yml           # MongoDB credentials
│   └── run.sh                     # Automated deployment script
└── images/                        # Image assets directory
```

---

## Core Components

### 1. Nginx Deployment & Service

#### [nginx-deployment.yaml](nginx-deployment.yaml)

**Purpose**: Creates a scalable Nginx web server deployment.

**Configuration Details**:
- **API Version**: `apps/v1`
- **Kind**: Deployment
- **Replicas**: 2 (load balanced across 2 pod instances)
- **Container Image**: `nginx` (latest)
- **Container Port**: 8080
- **Selector**: `app: nginx`

**Key Fields**:
- `metadata.name`: `nginx-deployment` - identifies the deployment
- `spec.replicas`: Number of desired pod replicas
- `spec.selector.matchLabels`: Pod selector for deployment management
- `spec.template`: Pod template specification
- `spec.template.spec.containers`: Container configuration details

**Usage Example**:
```bash
# Deploy Nginx
kubectl apply -f nginx-deployment.yaml

# Verify deployment
kubectl get deployment nginx-deployment

# Scale deployment to 3 replicas
kubectl scale deployment nginx-deployment --replicas=3

# View pod distribution
kubectl get pods -o wide
```

---

#### [nginx-service.yaml](nginx-service.yaml)

**Purpose**: Exposes the Nginx deployment to the cluster via a Service.

**Configuration Details**:
- **API Version**: `v1`
- **Kind**: Service
- **Service Type**: ClusterIP (default, internal-only access)
- **Selector**: Routes traffic to pods with label `app: nginx`
- **Protocol**: TCP
- **Port**: 80 (external)
- **Target Port**: 8080 (pod port)

**Key Fields**:
- `metadata.name`: `nginx-service` - service identifier
- `spec.selector`: Maps to Nginx deployment pods
- `spec.ports`: Defines port mapping (external:internal)

**Usage Example**:
```bash
# Create the service
kubectl apply -f nginx-service.yaml

# Check service endpoints
kubectl get svc nginx-service
kubectl describe service nginx-service

# Access service from within cluster
kubectl exec -it <pod-name> -- curl nginx-service:80

# Port forward to local machine
kubectl port-forward service/nginx-service 8080:80
```

---

### 2. Kubernetes Dashboard Configuration

#### [dashboard-adminuser.yaml](dashboard/dashboard-adminuser.yaml)

**Purpose**: Creates a service account with admin privileges for dashboard access.

**Configuration Details**:
- **Kind**: ServiceAccount
- **Namespace**: `kubernetes-dashboard`
- **Name**: `admin-user`

**Components**:
- Creates a new service account named `admin-user`
- Automatically generates associated authentication tokens
- Used for secure dashboard access

**Usage Example**:
```bash
# Apply the service account
kubectl apply -f dashboard-adminuser.yaml

# Generate authentication token
kubectl -n kubernetes-dashboard create token admin-user

# Save token for login
kubectl -n kubernetes-dashboard create token admin-user > dashboard-token.txt
```

---

#### [dashboard-clusterRoleBinding.yaml](dashboard/dashboard-clusterRoleBinding.yaml)

**Purpose**: Binds the dashboard admin service account to cluster-admin role for full cluster access.

**Configuration Details**:
- **API Version**: `rbac.authorization.k8s.io/v1`
- **Kind**: ClusterRoleBinding
- **Role**: `cluster-admin` (highest privilege level)
- **Subject**: `admin-user` service account in `kubernetes-dashboard` namespace

**Key Fields**:
- `roleRef.kind`: ClusterRole
- `roleRef.name`: cluster-admin
- `subjects[].kind`: ServiceAccount
- `subjects[].name`: admin-user
- `subjects[].namespace`: kubernetes-dashboard

**Security Implications**:
- Grants full cluster administrative privileges
- Should be restricted to trusted administrators
- Consider using more granular roles in production

**Usage Example**:
```bash
# Apply the role binding
kubectl apply -f dashboard-clusterRoleBinding.yaml

# Verify the binding
kubectl describe clusterrolebinding admin-user

# List all cluster role bindings
kubectl get clusterrolebindings | grep admin
```

---

### 3. Dashboard Ingress Configuration

#### [kubernetes-ingress/dashboard-ingress.yaml](kubernetes-ingress/dashboard-ingress.yaml)

**Purpose**: Routes HTTP requests to the Kubernetes dashboard via hostname-based routing.

**Configuration Details**:
- **API Version**: `networking.k8s.io/v1`
- **Kind**: Ingress
- **Namespace**: `kubernetes-dashboard`
- **Ingress Class**: `nginx`
- **Host**: `dashboard.com`
- **Path**: `/` (root path)
- **Path Type**: `Exact` (exact path matching)

**Service Routing**:
- **Backend Service**: `kubernetes-dashboard-api`
- **Service Port**: 80

**Usage Example**:
```bash
# Enable Ingress addon in Minikube
minikube addons enable ingress

# Apply the ingress configuration
kubectl apply -f dashboard-ingress.yaml

# Verify ingress status
kubectl get ingress -n kubernetes-dashboard
kubectl describe ingress dashboard-ingress -n kubernetes-dashboard

# Get Minikube IP and add to /etc/hosts
minikube ip  # Returns IP address
# Add to /etc/hosts: <MINIKUBE_IP> dashboard.com

# Access dashboard
curl http://dashboard.com/
```

---

## Configuration Modules

### MongoDB & MongoExpress Stack

This module provides a complete containerized MongoDB database with MongoExpress web UI, deployable to Kubernetes.

#### [Demo_MongoDB_and_MongoExpress/mongo-secret.yml](Demo_MongoDB_and_MongoExpress/mongo-secret.yml)

**Purpose**: Stores MongoDB credentials securely using Kubernetes Secrets.

**Configuration Details**:
- **Kind**: Secret
- **Type**: Opaque (generic key-value data)
- **Namespace**: default

**Stored Credentials** (base64 encoded):
- `mongo-root-username`: `dXNlcm5hbWU=` (decodes to: `username`)
- `mongo-root-password`: `cGFzc3dvcmQ=` (decodes to: `password`)

**Security Notes**:
- Base64 encoding is NOT encryption - secrets at rest require etcd encryption
- See [misc.md](ckad/misc.md) for etcd encryption details
- Restrict access via RBAC policies

**Usage Example**:
```bash
# Apply the secret
kubectl apply -f mongo-secret.yml

# View secret metadata (values hidden)
kubectl get secret mongodb-secret
kubectl describe secret mongodb-secret

# Decode secret value
kubectl get secret mongodb-secret -o jsonpath='{.data.mongo-root-username}' | base64 -d

# Delete secret
kubectl delete secret mongodb-secret
```

---

#### [Demo_MongoDB_and_MongoExpress/mongo-configmap.yaml](Demo_MongoDB_and_MongoExpress/mongo-configmap.yaml)

**Purpose**: Stores non-sensitive MongoDB configuration data.

**Configuration Details**:
- **Kind**: ConfigMap
- **Data Key**: `database_url`
- **Data Value**: `mongodb-service` (service name for internal DNS routing)

**Key Differences from Secrets**:
- ConfigMaps are not encrypted
- Suitable for non-sensitive configuration
- Can store up to 1MB of data
- Updated without restarting pods (with proper setup)

**Usage Example**:
```bash
# Apply the ConfigMap
kubectl apply -f mongo-configmap.yaml

# View ConfigMap contents
kubectl get configmap mongodb-configmap
kubectl describe configmap mongodb-configmap

# Edit ConfigMap
kubectl edit configmap mongodb-configmap

# Create ConfigMap from literal values
kubectl create configmap my-config --from-literal=key=value

# Create ConfigMap from file
kubectl create configmap my-config --from-file=config.conf
```

---

#### [Demo_MongoDB_and_MongoExpress/mongo.yml](Demo_MongoDB_and_MongoExpress/mongo.yml)

**Purpose**: Deploys MongoDB database with persistent data storage and secure credential management.

**Deployment Configuration**:
- **API Version**: `apps/v1`
- **Kind**: Deployment
- **Name**: `mongodb-deployment`
- **Replicas**: 1
- **Image**: `mongo` (latest)
- **Container Port**: 27017 (MongoDB default)

**Environment Variables** (from Secrets):
- `MONGO_INITDB_ROOT_USERNAME`: Retrieved from `mongodb-secret`
- `MONGO_INITDB_ROOT_PASSWORD`: Retrieved from `mongodb-secret`

**Service Configuration**:
- **Name**: `mongodb-service`
- **Type**: ClusterIP (internal)
- **Port**: 27017
- **Target Port**: 27017
- **Selector**: `app: mongodb`

**Key Features**:
- Two-part YAML file: Deployment + Service
- Secret reference for credentials
- Internal service for pod-to-pod communication

**Usage Example**:
```bash
# Deploy MongoDB
kubectl apply -f mongo.yml

# Verify deployment
kubectl get deployment mongodb-deployment
kubectl get pods -l app=mongodb
kubectl get svc mongodb-service

# Check MongoDB logs
kubectl logs deployment/mongodb-deployment

# Connect to MongoDB pod
kubectl exec -it <mongo-pod-name> -- mongosh

# Port forward for local access
kubectl port-forward svc/mongodb-service 27017:27017

# Test connection
mongo --username username --password password --host localhost:27017
```

---

#### [Demo_MongoDB_and_MongoExpress/mongo-express.yaml](Demo_MongoDB_and_MongoExpress/mongo-express.yaml)

**Purpose**: Deploys MongoExpress web UI for MongoDB database management.

**Deployment Configuration**:
- **API Version**: `apps/v1`
- **Kind**: Deployment
- **Name**: `mongo-express`
- **Replicas**: 1
- **Image**: `mongo-express:1.0-20-alpine3.17`
- **Container Port**: 8081

**Environment Variables**:
- `ME_CONFIG_MONGODB_ADMINUSERNAME`: From `mongodb-secret`
- `ME_CONFIG_MONGODB_ADMINPASSWORD`: From `mongodb-secret`
- `ME_CONFIG_MONGODB_SERVER`: From `mongodb-configmap`

**Service Configuration**:
- **Name**: `mongo-express-service`
- **Type**: LoadBalancer (external access)
- **Port**: 8081 (external)
- **Target Port**: 8081 (pod port)

**Key Features**:
- Alpine-based image for small footprint
- LoadBalancer service for external access
- References to ConfigMap and Secret for configuration
- Web UI for database administration

**Usage Example**:
```bash
# Deploy MongoExpress
kubectl apply -f mongo-express.yaml

# Get external service endpoint
kubectl get svc mongo-express-service

# View service details
kubectl describe svc mongo-express-service

# Check logs
kubectl logs deployment/mongo-express

# Access MongoExpress in browser
# For Minikube: minikube service mongo-express-service --url
# For cloud: use external IP from LoadBalancer service

# Port forward to local machine
kubectl port-forward svc/mongo-express-service 8081:8081
# Access at http://localhost:8081
```

---

#### [Demo_MongoDB_and_MongoExpress/docker-compose.yml](Demo_MongoDB_and_MongoExpress/docker-compose.yml)

**Purpose**: Provides Docker Compose alternative for local MongoDB + MongoExpress development without Kubernetes.

**Services**:

**MongoDB Service**:
- **Image**: `mongo`
- **Container Name**: `mongo`
- **Restart Policy**: Always
- **Environment**:
  - `MONGO_INITDB_ROOT_USERNAME`: root
  - `MONGO_INITDB_ROOT_PASSWORD`: example

**MongoExpress Service**:
- **Image**: `mongo-express`
- **Port Mapping**: 8081:8081
- **Restart Policy**: Always
- **Dependencies**: Requires MongoDB service
- **Environment**:
  - `ME_CONFIG_MONGODB_ADMINUSERNAME`: root
  - `ME_CONFIG_MONGODB_ADMINPASSWORD`: example
  - `ME_CONFIG_MONGODB_URL`: MongoDB connection string

**Usage Example**:
```bash
# Start services
docker-compose up -d

# View running services
docker-compose ps

# Access MongoExpress
# Navigate to http://localhost:8081

# Stop services
docker-compose down

# View logs
docker-compose logs mongo
docker-compose logs mongo-express

# Clean up volumes
docker-compose down -v
```

---

#### [Demo_MongoDB_and_MongoExpress/run.sh](Demo_MongoDB_and_MongoExpress/run.sh)

**Purpose**: Automated deployment script for the complete MongoDB stack on Kubernetes.

**Script Steps**:
1. Apply ConfigMap configuration
2. Apply Secret credentials
3. Deploy MongoDB
4. Deploy MongoExpress
5. Port forward MongoExpress service to port 30000

**Script Content**:
```bash
#!/bin/sh
kubectl apply -f mongo-configmap.yaml
kubectl apply -f mongo-secret.yml
kubectl apply -f mongo.yml
kubectl apply -f mongo-express.yaml
kubectl port-forward svc/mongo-express-service 30000:8081
```

**Usage Example**:
```bash
# Make script executable
chmod +x run.sh

# Execute script to deploy stack
./run.sh

# Script automatically port-forwards, so access at:
# http://localhost:30000

# In another terminal, view deployment status
kubectl get all

# Clean up
kubectl delete deployment mongodb-deployment mongo-express
kubectl delete svc mongodb-service mongo-express-service
kubectl delete configmap mongodb-configmap
kubectl delete secret mongodb-secret
```

---

## CKAD Learning Materials

### [ckad/editPod.md](ckad/editPod.md)

**Purpose**: Guide for editing Pod specifications in Kubernetes, crucial for CKAD exam preparation.

**Key Concepts**:

**Non-Editable Pod Fields**:
- Service accounts
- Resource limits
- Image pull policy
- Environment variables

**Editable Pod Fields**:
- `spec.containers[*].image`
- `spec.initContainers[*].image`
- `spec.activeDeadlineSeconds`
- `spec.tolerations`

**Editing Methods**:

**Method 1: Live Edit with Temporary Backup**:
```bash
# Edit pod live
kubectl edit pod <pod-name>

# If edit fails due to immutable field:
# - Save temporary file location noted by kubectl
# - Delete original pod
# - Create new pod from temporary file
kubectl delete pod <pod-name>
kubectl create -f /tmp/kubectl-edit-xxxxx.yaml
```

**Method 2: Export and Recreate**:
```bash
# Export pod to YAML
kubectl get pod <pod-name> -o yaml > my-pod.yaml

# Edit the file
vi my-pod.yaml

# Delete and recreate
kubectl delete pod <pod-name>
kubectl create -f my-pod.yaml
```

**For Deployments** (Easier Alternative):
```bash
# Deployments allow editing any pod template field
kubectl edit deployment <deployment-name>
# Changes automatically roll out as new pod replicas
```

---

### [ckad/misc.md](ckad/misc.md)

**Purpose**: Miscellaneous Kubernetes security and administration topics.

**Content**: Secret Data Encryption at Rest

**Topic**: Encrypting etcd Database

**Overview**: Kubernetes stores all cluster data in etcd. By default, data is unencrypted, requiring manual encryption configuration for security compliance.

**Setup Instructions**:

**1. SSH into Cluster Node**:
```bash
minikube ssh
cd /etc/kubernetes/manifests/
```

**2. Install Required Tools**:
```bash
# Install utilities
sudo apt-get update
sudo apt-get install bsdmainutils etcd-client

# Install hex dump utility
sudo apt-get install bsdmainutils
```

**3. Query Encrypted Data**:
```bash
sudo ETCDCTL_API=3 etcdctl \
  --cacert=/var/lib/minikube/certs/etcd/ca.crt \
  --cert=/var/lib/minikube/certs/etcd/server.crt \
  --key=/var/lib/minikube/certs/etcd/server.key \
  get /registry/secrets/default/my-secret | hexdump -C
```

**Security Considerations**:
- Base64 encoding (as shown in Secrets) is NOT encryption
- Implement etcd encryption for production environments
- Reference: [Kubernetes Encryption Docs](https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/)

---

## Setup Guides

### Complete Kubernetes Setup

#### Installation

**Prerequisites**:
1. Docker (for container runtime)
2. Minikube or similar Kubernetes distribution

**Installation Steps**:

**1. Install Minikube**:
```bash
# Download and install Minikube
# Follow: https://minikube.sigs.k8s.io/docs/start/

# Verify installation
minikube version
```

**2. Install kubectl**:
```bash
# Install kubectl CLI
# Follow: https://kubernetes.io/docs/tasks/tools/

# Verify installation
kubectl version --client
```

---

### Cluster Initialization

```bash
# Delete previous cluster (if exists)
minikube delete --all

# Start new Minikube cluster with Docker driver
minikube start --driver=docker

# Verify cluster status
minikube status

# Get cluster info
kubectl version
kubectl get nodes
kubectl get pods --all-namespaces
```

---

### MongoDB Stack Deployment

**Quick Start**:
```bash
cd Demo_MongoDB_and_MongoExpress/
./run.sh
```

**Manual Deployment**:
```bash
# Navigate to demo directory
cd Demo_MongoDB_and_MongoExpress/

# Deploy in order
kubectl apply -f mongo-configmap.yaml
kubectl apply -f mongo-secret.yml
kubectl apply -f mongo.yml
kubectl apply -f mongo-express.yaml

# Port forward service
kubectl port-forward svc/mongo-express-service 8081:8081

# Access at http://localhost:8081
```

---

### Kubernetes Dashboard Setup

**Prerequisites**:
- Kubernetes cluster running
- Helm installed (for newer dashboard versions)

**Method: Service Account + Token**

**1. Create Service Account and Bindings**:
```bash
kubectl apply -f dashboard/dashboard-adminuser.yaml
kubectl apply -f dashboard/dashboard-clusterRoleBinding.yaml
```

**2. Generate Login Token**:
```bash
kubectl -n kubernetes-dashboard create token admin-user
# Save the token for dashboard login
```

**3. Install Dashboard** (if not present):
```bash
# Using Helm
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
helm upgrade --install kubernetes-dashboard \
  kubernetes-dashboard/kubernetes-dashboard \
  --create-namespace --namespace kubernetes-dashboard
```

**4. Access Dashboard**:

**Option A: Port Forward**:
```bash
kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy 8443:443
# Access at https://localhost:8443
```

**Option B: Using kubectl proxy**:
```bash
kubectl proxy
# Access at http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
```

**5. Login**:
- Use the token generated in step 2
- Paste when prompted

---

### Ingress Setup

**1. Enable Ingress Addon**:
```bash
minikube addons enable ingress

# Verify ingress controller
kubectl get pods -n ingress-nginx
```

**2. Configure Ingress Rules**:
```bash
kubectl apply -f kubernetes-ingress/dashboard-ingress.yaml
```

**3. Local Access Setup**:
```bash
# Get Minikube IP
MINIKUBE_IP=$(minikube ip)

# Add to hosts file (adjust for your OS)
echo "$MINIKUBE_IP dashboard.com" | sudo tee -a /etc/hosts

# Access
curl http://dashboard.com/
```

---

## Command Reference

### Cluster Management

```bash
# Cluster Status
kubectl version                          # Display Kubernetes version
kubectl get nodes                        # List all nodes
kubectl cluster-info                     # Display cluster info
minikube status                          # Minikube cluster status

# Cluster Initialization
minikube delete --all                    # Delete all Minikube clusters
minikube start --driver=docker           # Start cluster with Docker driver
minikube ip                              # Get Minikube IP address
```

---

### Namespace Management

```bash
# Create namespace
kubectl create namespace my-namespace

# List namespaces
kubectl get namespace

# Set default namespace
kubectl config set-context --current --namespace=my-namespace

# Get all resources in namespace
kubectl get all -n my-namespace

# Query namespaced vs cluster resources
kubectl api-resources --namespaced=true
kubectl api-resources --namespaced=false
```

---

### Deployment Management

```bash
# Create deployment
kubectl create deployment nginx-depl --image=nginx

# List deployments
kubectl get deployment

# View deployment YAML
kubectl get deployment nginx-depl -o yaml

# Edit deployment
kubectl edit deployment nginx-depl

# Scale deployment
kubectl scale deployment nginx-depl --replicas=5

# Apply configuration file
kubectl apply -f nginx-deployment.yaml

# Delete deployment
kubectl delete deployment nginx-depl
```

---

### Pod Management

```bash
# List pods
kubectl get pods
kubectl get pods --all-namespaces
kubectl get pods -o wide                 # Show node placement

# Pod details
kubectl describe pod <pod-name>
kubectl logs <pod-name>                  # View pod logs
kubectl logs -f <pod-name>               # Follow logs

# Pod execution
kubectl exec -it <pod-name> -- /bin/bash # Interactive shell
kubectl exec <pod-name> -- command       # Run command

# Edit pod (limited fields)
kubectl edit pod <pod-name>

# Delete pod
kubectl delete pod <pod-name>
```

---

### Service Management

```bash
# List services
kubectl get service
kubectl get svc                          # Short form

# Service details
kubectl describe service <service-name>
kubectl get svc <service-name> -o yaml

# Port forwarding
kubectl port-forward svc/<service-name> 8080:80

# Expose deployment
kubectl expose deployment nginx --port=80 --target-port=8080

# Delete service
kubectl delete service <service-name>
```

---

### Resource Inspection

```bash
# List resource types
kubectl api-resources

# Get all resources
kubectl get all
kubectl get all | grep mongodb

# Describe resources
kubectl describe <resource-type> <resource-name>

# Export YAML
kubectl get <resource-type> <resource-name> -o yaml > backup.yaml
```

---

### Replication Set Management

```bash
# List replication sets
kubectl get replicaset

# View replica set details
kubectl describe replicaset <replicaset-name>

# Scale replication set
kubectl scale replicaset <replicaset-name> --replicas=3
```

---

### Secret and ConfigMap Management

```bash
# ConfigMap operations
kubectl create configmap <name> --from-literal=key=value
kubectl get configmap
kubectl describe configmap <name>
kubectl edit configmap <name>

# Secret operations
kubectl create secret generic <name> --from-literal=username=user --from-literal=password=pass
kubectl get secrets
kubectl describe secret <name>
kubectl get secret <name> -o jsonpath='{.data.key}' | base64 -d

# From files
kubectl create configmap my-config --from-file=config.conf
kubectl create secret generic my-secret --from-file=certs/cert.pem
```

---

### Ingress Management

```bash
# Enable ingress addon (Minikube)
minikube addons enable ingress

# List ingress resources
kubectl get ingress --all-namespaces

# Ingress details
kubectl describe ingress <ingress-name> -n <namespace>

# Apply ingress configuration
kubectl apply -f kubernetes-ingress/dashboard-ingress.yaml

# Delete ingress
kubectl delete ingress <ingress-name>
```

---

### Cleanup Commands

```bash
# Delete all services
kubectl delete --all services

# Delete all resources in namespace
kubectl delete daemonsets,replicasets,services,deployments,pods,rc,ingress --all --all-namespaces

# Delete everything and reset
minikube delete --all
```

---

## Troubleshooting

### Common Issues and Solutions

#### Pod Not Starting

**Symptoms**: Pod remains in Pending, CrashLoopBackOff, or ImagePullBackOff state

**Diagnosis**:
```bash
# View pod events
kubectl describe pod <pod-name>

# Check logs
kubectl logs <pod-name>
kubectl logs <pod-name> --previous    # For crashed pods

# Check node resources
kubectl top nodes
kubectl top pods
```

**Solutions**:
- Verify image availability: `docker pull <image-name>`
- Check resource requests vs. node capacity
- Review pod events for specific errors
- Ensure service dependencies are running

---

#### Service Connection Issues

**Symptoms**: Cannot connect to service or pod

**Diagnosis**:
```bash
# Verify service exists and has endpoints
kubectl get svc <service-name>
kubectl describe svc <service-name>
kubectl get endpoints <service-name>

# Test DNS resolution from pod
kubectl exec -it <pod-name> -- nslookup <service-name>

# Test connectivity
kubectl exec -it <pod-name> -- curl http://<service-name>:port
```

**Solutions**:
- Ensure selector labels match pod labels
- Verify target port matches container port
- Check firewall/network policies
- Confirm service namespace configuration

---

#### Secret/ConfigMap Reference Errors

**Symptoms**: Pod fails with "secret/configmap not found"

**Diagnosis**:
```bash
# Verify secret/configmap exists
kubectl get secret <secret-name>
kubectl get configmap <configmap-name>

# Check correct namespace
kubectl get secret -n <namespace>

# Verify key names
kubectl describe secret <secret-name>
```

**Solutions**:
- Ensure secret/configmap is in correct namespace
- Verify key names match pod references
- Confirm secret/configmap applied before deployment
- Check YAML indentation in references

---

#### Deployment Not Updating

**Symptoms**: Changes to deployment don't trigger pod rollout

**Cause**: Kubernetes only rolls out when pod template changes

**Solutions**:
```bash
# Force rollout
kubectl rollout restart deployment <deployment-name>

# Check rollout status
kubectl rollout status deployment <deployment-name>

# View rollout history
kubectl rollout history deployment <deployment-name>

# Rollback to previous version
kubectl rollout undo deployment <deployment-name>
```

---

#### Resource Access Denied (RBAC)

**Symptoms**: "Error from server (Forbidden)" when accessing resources

**Diagnosis**:
```bash
# Check current permissions
kubectl auth can-i list pods
kubectl auth can-i create deployments

# Check service account bindings
kubectl get rolebinding
kubectl get clusterrolebinding

# Describe role/clusterrole
kubectl describe role <role-name>
kubectl describe clusterrole <clusterrole-name>
```

**Solutions**:
- Verify service account has required role binding
- Check role/clusterrole permissions
- Apply appropriate RoleBinding or ClusterRoleBinding
- Use example configurations (e.g., `dashboard-clusterRoleBinding.yaml`)

---

### Health Checks

**Verify All Components**:
```bash
# Complete cluster health check
minikube status                          # Cluster status
kubectl get nodes                        # Node status
kubectl get pods --all-namespaces        # Pod status
kubectl get all                          # All resources
kubectl top nodes                        # Node resource usage
kubectl top pods --all-namespaces        # Pod resource usage
```

---

## Best Practices

1. **Use Labels and Selectors**: Organize resources with meaningful labels for easy management
2. **Separate Configuration**: Use ConfigMaps for configuration and Secrets for sensitive data
3. **Resource Requests/Limits**: Define CPU and memory requests for proper scheduling
4. **RBAC**: Implement least-privilege access control for service accounts
5. **Namespaces**: Use namespaces to organize and isolate environments
6. **Health Checks**: Configure liveness and readiness probes
7. **Documentation**: Keep YAML files well-documented with comments
8. **Version Control**: Track all configuration in Git
9. **Testing**: Test configurations locally before production deployment
10. **Security**: Encrypt secrets at rest and enforce network policies

---

## Additional Resources

- [Kubernetes Official Documentation](https://kubernetes.io/docs/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [CKAD Exam Guide](https://www.cncf.io/certification/ckad/)
- [Kubernetes Dashboard Repository](https://github.com/kubernetes/dashboard)
- [Docker Compose Documentation](https://docs.docker.com/compose/)

---

## Document Information

- **Last Updated**: January 2026
- **Repository**: Kubernetes Learning Repository
- **Purpose**: Comprehensive documentation for K8s learning and configuration

