output "argocd_namespace" {
  description = "ArgoCD namespace name"
  value       = kubernetes_namespace.argocd.metadata[0].name
}

output "argocd_release_name" {
  description = "ArgoCD Helm release name"
  value       = helm_release.argocd.name
}

output "argocd_release_version" {
  description = "ArgoCD Helm release version"
  value       = helm_release.argocd.version
}
