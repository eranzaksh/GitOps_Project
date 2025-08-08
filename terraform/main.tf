terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.70"
    }
  }

  required_version = ">= 1.2.0"
}
provider "aws" {
  region = "eu-north-1"
  # profile = "eran"
}

data "aws_eks_cluster_auth" "cluster_token" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = module.eks.eks_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_ca)
  token                  = data.aws_eks_cluster_auth.cluster_token.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks.eks_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_ca)
    token                  = data.aws_eks_cluster_auth.cluster_token.token
  }
}
module "vpc" {
  source               = "./modules/vpc"
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "security_groups" {
  source   = "./modules/security_groups"
  vpc_id   = module.vpc.vpc_id
  vpc_cidr = module.vpc.vpc_cidr
}

module "eks" {
  source   = "./modules/eks"
  vpc_id   = module.vpc.vpc_id
  lb_sg_id = module.security_groups.lb_sg_id

  private_subnet_ids = module.vpc.private_subnets
  cluster_name       = "tf-eran"
  aws_region         = "eu-north-1"
}

module "nginx_ingress" {
  source     = "./modules/ingress_controller"
  depends_on = [module.prometheus]
}

module "argocd" {
  source     = "./modules/argocd"
  depends_on = [module.nginx_ingress]
}

module "prometheus" {
  source     = "./modules/prometheus"
  depends_on = [module.eks]
}

module "cert-manager" {
  source     = "./modules/cert_manager"
  depends_on = [module.eks]
}
      