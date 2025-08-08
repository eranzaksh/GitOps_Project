output "ingress_controller_namespace" {
  description = "Ingress controller namespace"
  value       = helm_release.nginx_ingress.namespace
}

output "ingress_controller_release_name" {
  description = "Ingress controller Helm release name"
  value       = helm_release.nginx_ingress.name
}

output "ingress_controller_release_version" {
  description = "Ingress controller Helm release version"
  value       = helm_release.nginx_ingress.version
}

output "load_balancer_hostname" {
  description = "Load balancer hostname for ingress controller"
  value       = try(data.kubernetes_service.nginx_ingress_lb.status[0].load_balancer[0].ingress[0].hostname, null)
}

output "load_balancer_ip" {
  description = "Load balancer IP for ingress controller"
  value       = try(data.kubernetes_service.nginx_ingress_lb.status[0].load_balancer[0].ingress[0].ip, null)
}
