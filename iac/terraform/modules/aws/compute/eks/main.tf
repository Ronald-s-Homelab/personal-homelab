data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

data "aws_subnet" "subnets" {
  for_each = toset(var.subnets)
  filter {
    name   = "tag:Name"
    values = [each.value]
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1"
      command     = "aws"
      args = [
        "eks",
        "get-token",
        "--cluster-name",
        module.eks.cluster_name
      ]
    }
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.16.0"

  cluster_endpoint_public_access = true
  manage_aws_auth_configmap      = false

  cluster_name                  = var.cluster_name
  cluster_version               = var.cluster_version
  cluster_security_group_id     = var.cluster_security_group_id
  create_cluster_security_group = var.create_cluster_security_group
  create_node_security_group    = var.create_node_security_group
  create_iam_role               = var.create_iam_role
  iam_role_arn                  = var.iam_role_arn
  subnet_ids                    = [for k, v in data.aws_subnet.subnets : v.id]
  vpc_id                        = data.aws_vpc.vpc.id

  eks_managed_node_groups = var.node_groups
}

module "eks_blueprints_addons" {
  source = "aws-ia/eks-blueprints-addons/aws"

  cluster_name                        = module.eks.cluster_name
  cluster_endpoint                    = module.eks.cluster_endpoint
  cluster_version                     = module.eks.cluster_version
  oidc_provider_arn                   = module.eks.oidc_provider_arn
  eks_addons                          = var.cluster_addons
  enable_aws_load_balancer_controller = var.enable_aws_load_balancer_controller
}
