variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public Subnet CIDR values"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private Subnet CIDR values"

}

variable "vpc_cidr_block" {
  type = string
  description = "VPC cidr_block"
  default = "10.1.0.0/16"
  
}