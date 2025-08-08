output "frontend_pod_sg_id" {
  description = "Security Group ID for Frontend Pods"
  value       = module.security_groups.frontend_pod_sg_id
}

output "backend_pod_sg_id" {
  description = "Security Group ID for Backend Pods"
  value       = module.security_groups.backend_pod_sg_id
}

# kubectl Configuration
output "kubectl_config_command" {
  description = "Run this command to configure kubectl"
  value       = "aws eks update-kubeconfig --region eu-north-1 --name ${module.eks.cluster_name}"
}

# ArgoCD Admin Password
output "argocd_admin_password_command" {
  description = "Run this command to get ArgoCD admin password"
  value       = "kubectl -n ${module.argocd.argocd_namespace} get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
}

# Useful Commands for Developers
output "useful_commands" {
  description = "Useful commands for cluster management"
  value = {
    check_nodes       = "kubectl get nodes"
    check_pods        = "kubectl get pods --all-namespaces"
    check_ingress     = "kubectl get ingress --all-namespaces"
    check_services    = "kubectl get svc --all-namespaces"
  }
}

# Cluster Information
output "cluster_info" {
  description = "EKS cluster information"
  value = {
    cluster_name = module.eks.cluster_name
    region       = "eu-north-1"
    endpoint     = module.eks.eks_endpoint
  }
}
