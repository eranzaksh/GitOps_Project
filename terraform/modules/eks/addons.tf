# CoreDNS Add-on
resource "aws_eks_addon" "coredns" {
  cluster_name                = aws_eks_cluster.tf-eran.name
  addon_name                  = "coredns"
  addon_version               = var.coredns_addon_version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  
  depends_on = [
    aws_eks_cluster.tf-eran,
    aws_eks_node_group.private-nodes
  ]

  tags = {
    Name = "coredns-addon"
  }
}

# VPC CNI Add-on
resource "aws_eks_addon" "vpc_cni" {
  cluster_name                = aws_eks_cluster.tf-eran.name
  addon_name                  = "vpc-cni"
  addon_version               = var.vpc_cni_addon_version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  
  depends_on = [
    aws_eks_cluster.tf-eran
  ]

  tags = {
    Name = "vpc-cni-addon"
  }
}
