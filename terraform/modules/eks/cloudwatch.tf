resource "kubernetes_namespace" "amazon_cloudwatch" {
  metadata {
    name = "amazon-cloudwatch"
  }

  depends_on = [aws_eks_cluster.tf-eran]
}
# to see cloudwatch metrics in grafana need to use built in aws data source
resource "helm_release" "aws_cloudwatch_metrics" {
  name       = "aws-cloudwatch-metrics"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-cloudwatch-metrics"
  namespace  = kubernetes_namespace.amazon_cloudwatch.metadata[0].name

  set {
    name  = "clusterName"
    value = var.cluster_name
  }
}

resource "helm_release" "aws_for_fluent_bit" {
  name       = "aws-for-fluent-bit"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-for-fluent-bit"
  namespace  = kubernetes_namespace.amazon_cloudwatch.metadata[0].name

  set {
    name  = "cloudWatchLogs.region"
    value = var.aws_region
  }

  set {
    name  = "cloudWatchLogs.logGroupName"
    value = "/aws/containerinsights/${var.cluster_name}/application"
  }
}
