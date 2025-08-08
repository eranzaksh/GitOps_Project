output "cert_manager_namespace" {
  description = "Cert-manager namespace name"
  value       = kubernetes_namespace.cert-manager.metadata[0].name
}

output "cert_manager_release_name" {
  description = "Cert-manager Helm release name"
  value       = helm_release.cert_manager.name
}

output "cert_manager_release_version" {
  description = "Cert-manager Helm release version"
  value       = helm_release.cert_manager.version
}
