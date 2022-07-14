variable "project_name" {
  type = string
}

locals {
  tags = {
    owner = "terraform"
  }
}

module "kubernetes" {
  source          = "./modules/eks"
  name            = var.project_name
  cluster_version = "1.22"
  tags            = local.tags
}

module "aws_load_balancer" {
  source                = "./modules/aws-load-balancer"
  eks_cluster_name      = var.project_name
  eks_oidc_provider_arn = module.kubernetes.oidc_provider_arn
  tags                  = local.tags
}
