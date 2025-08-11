

resource "aws_iam_policy" "autoscaler_policy" {
  name        = "eks-autoscaler-policy"
  description = "IAM policy for EKS Cluster Autoscaler to manage Auto Scaling Groups"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          # Required to discover all ASGs and filter by cluster tags
          "autoscaling:DescribeAutoScalingGroups",
          # Required to check current instance state across ASGs
          "autoscaling:DescribeAutoScalingInstances",
          # Required to scale ASGs up/down based on pod demands
          "autoscaling:SetDesiredCapacity",
          # Required to terminate specific instances when scaling down
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          # Required to query available EC2 instance types for scaling decisions
          "ec2:DescribeInstanceTypes"
        ]
        # Resource = "*" is necessary because:
        # 1. ASG names contain random suffixes (e.g., eks-private-nodes-abc123def)

        Resource = "*"
      }
    ]
  })
}

# Attach autoscaling policy to existing node role
resource "aws_iam_role_policy_attachment" "nodes-autoscaler-policy" {
  policy_arn = aws_iam_policy.autoscaler_policy.arn
  role       = aws_iam_role.nodes.name
}

# ========================================
# CLUSTER AUTOSCALER HELM DEPLOYMENT
# ========================================

resource "helm_release" "cluster_autoscaler" {
  name       = "cluster-autoscaler"
  namespace  = "kube-system"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  version    = "9.29.0"

  # Helm values configuration
  values = [
    yamlencode({
      # Auto-discovery configuration - finds ASGs tagged for this cluster
      autoDiscovery = {
        clusterName = var.cluster_name  # Uses the cluster name variable
        enabled     = true
      }
      
      # AWS region where the cluster is deployed
      awsRegion = var.aws_region
      
      # RBAC and Service Account configuration
      rbac = {
        serviceAccount = {
          create = true
          name   = "cluster-autoscaler"
          # Links the Kubernetes service account to our IAM role
          annotations = {
            "eks.amazonaws.com/role-arn" = aws_iam_role.nodes.arn
          }
        }
      }
      
      # Scaling behavior configuration
      extraArgs = {
        # Scale down when nodes are less than 50% utilized
        scale-down-utilization-threshold = 0.5
        # Wait 5 minutes after scaling up before considering scale down
        scale-down-delay-after-add      = "5m"
        # Node must be unneeded for 5 minutes before scale down
        scale-down-unneeded-time        = "5m"
        # Maximum time to wait for a node to be provisioned
        max-node-provision-time         = "15m"
        # Logging configuration
        logtostderr     = true
        stderrthreshold = "info"
        v               = 4  # Verbosity level (0-10, higher = more verbose)
      }
      replicaCount = 2
      
    })
  ]

  # Ensure the cluster and IAM policies are ready before deploying autoscaler
  depends_on = [
    aws_eks_node_group.private-nodes,                       # Node group must exist
    aws_iam_role_policy_attachment.nodes-autoscaler-policy  # IAM permissions must be attached
  ]
}
