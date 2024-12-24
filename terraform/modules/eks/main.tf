resource "aws_iam_role" "tf-eks" {
  name = "eks-tf-argocd-prometheus"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "tf-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.tf-eks.name
}

resource "aws_eks_cluster" "tf-eks" {
  name     = "tf-eks"
  role_arn = aws_iam_role.tf-eks.arn

  vpc_config {
    subnet_ids = var.private_subnet_ids
    security_group_ids = [var.lb_sg_id]
  }
  upgrade_policy {
    support_type = "STANDARD"
  }
  depends_on = [aws_iam_role_policy_attachment.tf-AmazonEKSClusterPolicy]
}
