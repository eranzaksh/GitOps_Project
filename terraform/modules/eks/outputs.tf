// change all names to leumi

output "eks_endpoint" {
    value = aws_eks_cluster.tf-leumi.endpoint
}

output "cluster_ca" {
  value = aws_eks_cluster.tf-leumi.certificate_authority[0].data
}

output "cluster_name" {
  value = aws_eks_cluster.tf-leumi.name
}