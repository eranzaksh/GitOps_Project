output "lb_sg_id" {
  value = aws_security_group.lb_sg.id
}

output "frontend_pod_sg_id" {
  value = aws_security_group.frontend_pod_sg.id
}

output "backend_pod_sg_id" {
  value = aws_security_group.backend_pod_sg.id
}
