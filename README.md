# 🚀 GitOps Infrastructure Project

A comprehensive GitOps-based infrastructure project that provides developers with easy-to-use, dynamic, and scalable infrastructure for deploying microservices applications. This project implements modern DevOps practices with automated CI/CD pipelines, infrastructure as code, and GitOps principles.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Infrastructure Components](#infrastructure-components)
- [CI/CD Pipelines](#cicd-pipelines)
- [GitOps Principles](#gitops-principles)
- [Getting Started](#getting-started)
- [End Result](#end-result)
- [Technologies Used](#technologies-used)

## 🎯 Overview

This project demonstrates a complete GitOps workflow for deploying a microservices application (frontend + backend) on AWS EKS with automated infrastructure provisioning, continuous integration, and continuous deployment. The infrastructure is designed to be developer-friendly, scalable, and maintainable.

### What You Get

- **Automated Infrastructure**: Complete AWS EKS cluster with all necessary components
- **GitOps Deployment**: ArgoCD-managed deployments with automatic synchronization
- **CI/CD Pipelines**: Jenkins-based pipelines with security scanning and testing
- **Monitoring & Observability**: Prometheus and Grafana for metrics and monitoring
- **Security**: TLS certificates, secret management, and security groups
- **Scalability**: Auto-scaling capabilities for both infrastructure and applications

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │    Backend      │    │   Monitoring    │
│   (Flask App)   │◄──►│   (Flask API)   │    │  (Prometheus)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │   ArgoCD        │
                    │   (GitOps)      │
                    └─────────────────┘
                                 │
                    ┌─────────────────┐
                    │   EKS Cluster   │
                    │   (AWS)         │
                    └─────────────────┘
```

## 🏛️ Infrastructure Components

### 1. **AWS EKS Cluster** (`terraform/`)
- **VPC & Networking**: Custom VPC with public and private subnets
- **Security Groups**: Isolated security groups for frontend, backend, and load balancer
- **EKS Cluster**: Managed Kubernetes cluster with auto-scaling node groups
- **Load Balancer**: Application Load Balancer for external traffic

### 2. **Kubernetes Components**
- **NGINX Ingress Controller**: Handles external traffic routing
- **Cert-Manager**: Automated TLS certificate management with Let's Encrypt
- **External Secrets Operator**: Secure secret management from GCP Secret Manager
- **Cluster Autoscaler**: Automatic node scaling based on demand (deployed via Terraform)
- **CoreDNS**: Kubernetes DNS service for service discovery
- **VPC CNI**: Amazon VPC Container Network Interface for pod networking
- **Metrics Server**: Kubernetes metrics aggregation for HPA and VPA

### 3. **GitOps Platform** (`helm/argocd/`)
- **ArgoCD**: GitOps continuous deployment tool
- **Application Definitions**: Helm charts for frontend and backend applications
- **Automated Sync**: Automatic deployment when Git repository changes

### 4. **Monitoring Stack** (`helm/prometheus/`)
- **Prometheus**: Metrics collection and storage
- **Grafana**: Visualization and dashboards
- **Service Discovery**: Automatic monitoring of Kubernetes services
- **CoreDNS Monitoring**: Dedicated ServiceMonitor for DNS metrics

### 5. **AWS CloudWatch & Logging** (`terraform/modules/eks/cloudwatch.tf`)
- **CloudWatch Metrics**: Container insights for EKS cluster monitoring
- **Fluent Bit**: Log aggregation and forwarding to CloudWatch
- **Container Insights**: Real-time monitoring of container performance
- **Log Groups**: Centralized logging for application and system logs

### 6. **Applications** (`app/`, `backend/`)
- **Frontend**: Flask web application with service discovery
- **Backend**: Flask API service
- **Docker Images**: Containerized applications with health checks

## 🔄 CI/CD Pipelines

### Frontend CI Pipeline (`jenkins/Jenkinsfile-ci-frontend`)

**Pipeline Stages:**
1. **Clone Repository**
2. **Verify (Parallel)**:
   - Frontend Linting (Pylint)
   - Frontend Security Scan (Bandit)
   - Backend Linting (Pylint)
   - Backend Security Scan (Bandit)
3. **Build (Parallel)**:
   - Build Frontend Docker Image
   - Build Backend Docker Image
4. **Test**:
   - Container Health Check
   - Connectivity Testing
5. **Push**:
   - Push Images to Docker Hub
6. **Trigger CD Pipeline**

### Backend CI Pipeline (`jenkins/Jenkinsfile-ci-backend`)

**Pipeline Stages:**
1. **Clone Repository**
2. **Backend Verify (Parallel)**:
   - Backend Linting (Pylint)
   - Backend Security Scan (Bandit)
3. **Build Backend**
4. **Test Backend**:
   - Container Health Check
   - API Connectivity Testing
5. **Push Backend Image**
6. **Trigger CD Pipeline**

### CD Pipeline (`jenkins/Jenkinsfile-cd`)

**Pipeline Stages:**
1. **Clone Git Repository**
2. **Update Configuration Files**:
   - Update image tags in Helm values
   - Update security group IDs dynamically from AWS
3. **Git Push Changes**
4. **Configure Infrastructure Components**:
   - Install Cert-Manager
   - Install External Secrets
   - Apply Cluster Issuer
   - Deploy ArgoCD and Prometheus
   - *Note: Cluster Autoscaler is deployed via Terraform (infrastructure layer)*
5. **Configure DuckDNS Host**
6. **Create ArgoCD Applications**:
   - Frontend Application
   - Backend Application

## 🎯 GitOps Principles

### 1. **Infrastructure as Code**
- All infrastructure defined in Terraform
- Version-controlled infrastructure changes
- Reproducible deployments

### 2. **Declarative Configuration**
- Kubernetes manifests and Helm charts
- Desired state defined in Git
- ArgoCD ensures actual state matches desired state
- CoreDNS for service discovery and DNS resolution
- VPC CNI for native AWS networking

### 3. **Automated Synchronization**
- ArgoCD automatically syncs when Git changes
- No manual intervention required
- Rollback capabilities through Git history

### 4. **Security First**
- Automated security scanning in CI
- Secret management through External Secrets Operator
- TLS certificates automatically provisioned
- Network security through security groups

### 5. **Observability**
- Comprehensive monitoring with Prometheus and CloudWatch
- Health checks and metrics collection
- Slack notifications for pipeline status
- Centralized logging with Fluent Bit
- Container insights for performance monitoring

## 🚀 Getting Started

### Prerequisites

#### Required Software
- **AWS CLI** (v2.x): Configured with appropriate credentials
- **Terraform** (v1.5+): Infrastructure as Code tool
- **kubectl** (v1.28+): Kubernetes command-line tool
- **Docker** (v20.x+): Container runtime
- **Helm** (v3.x+): Kubernetes package manager

#### Required Accounts & Services
- **AWS Account**: With appropriate IAM permissions
- **Docker Hub Account**: For container registry
- **GitHub Account**: For source code repository
- **GCP Account** (optional): For External Secrets Manager integration
- **DuckDNS Account**: For dynamic DNS

#### Infrastructure Requirements
- **Jenkins Server**: With required plugins (Docker, AWS, Kubernetes, Git)
- **Estimated AWS Costs**: $50-100/month for development environment
- **Deployment Time**: Initial deployment takes approximately 20-30 minutes

### Quick Start
1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/GitOps_Project.git
   cd GitOps_Project
   ```
   > **Note**: Replace `your-username` with your actual GitHub username

2. **Deploy Infrastructure**
   ```bash
   cd terraform
   terraform init
   terraform plan
   terraform apply
   ```

3. **Configure Jenkins Pipelines**
   - Set up Jenkins credentials for AWS, Docker Hub, and GitHub
   - Configure the CI/CD pipelines in Jenkins

4. **Deploy Applications**
   - The CD pipeline will automatically deploy applications via ArgoCD

## 🎉 End Result

### What Developers Get

1. **Zero-Downtime Deployments**: Applications are deployed with zero downtime using rolling updates

2. **Automatic Scaling**: Both infrastructure and applications scale automatically based on demand

3. **Self-Service Deployment**: Developers can deploy by simply pushing to Git - no manual intervention needed

4. **Production-Ready Environment**: 
   - TLS certificates automatically provisioned
   - Monitoring and alerting configured
   - Security scanning integrated
   - Backup and disaster recovery ready

5. **Easy Rollbacks**: Quick rollback to previous versions through Git history

6. **Real-time Monitoring**: 
   - Application metrics and health checks
   - Infrastructure monitoring with CloudWatch
   - Centralized logging with Fluent Bit
   - Slack notifications for deployment status

### Application URLs
- **Frontend**: `https://eranapp.duckdns.org`
- **ArgoCD**: `https://eranargocd.duckdns.org`
- **Grafana**: `https://erangrafana.duckdns.org`

### Developer Outputs & Commands
After infrastructure deployment, developers get access to:

```bash
# Configure kubectl access (replace values from Terraform outputs)
aws eks update-kubeconfig --region us-east-1 --name gitops-eks-cluster

# Get ArgoCD admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d

# Get Terraform outputs for security groups
cd terraform
terraform output frontend_pod_sg_id
terraform output backend_pod_sg_id

# Useful cluster management commands
kubectl get nodes                    # Check cluster nodes
kubectl get pods --all-namespaces   # Check all pods
kubectl get ingress --all-namespaces # Check ingress resources
kubectl get svc --all-namespaces    # Check services

# Monitor deployment status
kubectl get applications -n argocd   # Check ArgoCD applications
kubectl logs -f deployment/frontend -n default  # Follow frontend logs
```

### Key Features
- ✅ **Automated Infrastructure Provisioning**
- ✅ **GitOps Continuous Deployment**
- ✅ **Security Scanning & Compliance**
- ✅ **Auto-scaling Infrastructure & Applications**
- ✅ **TLS Certificate Management**
- ✅ **Secret Management**
- ✅ **Comprehensive Monitoring** (Prometheus + CloudWatch)
- ✅ **Centralized Logging** (Fluent Bit)
- ✅ **Service Discovery** (CoreDNS)
- ✅ **Native AWS Networking** (VPC CNI)
- ✅ **Zero-downtime Deployments**
- ✅ **Easy Rollback Capabilities**
- ✅ **Developer Self-Service**
- ✅ **Container Insights & Performance Monitoring**

## 🛠️ Technologies Used

### Infrastructure
- **AWS EKS**: Managed Kubernetes cluster
- **Terraform**: Infrastructure as Code
- **Helm**: Kubernetes package manager
- **ArgoCD**: GitOps continuous deployment

### CI/CD
- **Jenkins**: CI/CD automation
- **Docker**: Containerization
- **Docker Hub**: Container registry

### Applications
- **Flask**: Python web framework
- **Python**: Programming language

### Security & Monitoring
- **Cert-Manager**: TLS certificate management
- **External Secrets Operator**: Secret management
- **Prometheus**: Metrics collection
- **Grafana**: Visualization
- **CloudWatch**: AWS monitoring and logging
- **Fluent Bit**: Log aggregation
- **Bandit**: Security scanning
- **Pylint**: Code quality

### Networking
- **NGINX Ingress Controller**: Traffic routing
- **CoreDNS**: Kubernetes DNS service
- **VPC CNI**: AWS container networking
- **DuckDNS**: Dynamic DNS
- **Let's Encrypt**: SSL certificates

---

