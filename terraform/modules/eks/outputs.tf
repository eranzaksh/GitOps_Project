
output "eks_endpoint" {
    value = aws_eks_cluster.tf-eran.endpoint
}

output "cluster_ca" {
  value = aws_eks_cluster.tf-eran.certificate_authority[0].data
}

output "cluster_name" {
  value = aws_eks_cluster.tf-eran.name
}