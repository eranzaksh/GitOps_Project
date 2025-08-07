output "frontend_pod_sg_id" {
  description = "Security Group ID for Frontend Pods"
  value       = module.security_groups.frontend_pod_sg_id
}

output "backend_pod_sg_id" {
  description = "Security Group ID for Backend Pods"
  value       = module.security_groups.backend_pod_sg_id
}
