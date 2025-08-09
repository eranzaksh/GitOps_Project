# Subnets here starts with 10.1 becuase default subnets starts with 10.0 and this is to prevent
# Problems for future vpc peering

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public Subnet CIDR values"
  default     = ["10.1.1.0/24", "10.1.4.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private Subnet CIDR values"
  default     = ["10.1.2.0/24", "10.1.3.0/24"]
}

variable "aws_region" {
  type = string
  description = "AWS region"
  default = "eu-north-1"
}