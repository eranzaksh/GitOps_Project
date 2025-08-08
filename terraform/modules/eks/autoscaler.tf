# Simple autoscaler setup - just add the required IAM policy to existing node role
resource "aws_iam_policy" "autoscaler_policy" {
  name = "eks-autoscaler-policy"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          "ec2:DescribeInstanceTypes"
        ]
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
