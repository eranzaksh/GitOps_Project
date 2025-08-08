variable "private_subnet_ids" {
  description = "Private Subnet IDs"
  type        = list(string)
}
variable "vpc_id" {
  type = string
}

variable "lb_sg_id" {
  type = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "tf-eran"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "coredns_addon_version" {
  description = "Version of the CoreDNS EKS add-on"
  type        = string
  default     = "v1.11.1-eksbuild.4"
}

variable "vpc_cni_addon_version" {
  description = "Version of the VPC CNI EKS add-on"
  type        = string
  default     = "v1.18.1-eksbuild.1"
}
