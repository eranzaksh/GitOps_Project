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
