module "vpc" {
  source   = "terraform-aws-modules/vpc/aws"
  version  = "5.1.2"
  for_each = var.vpc

  name = each.key
  cidr = each.value.cidr

  azs             = each.value.azs
  private_subnets = each.value.private_subnets
  public_subnets  = each.value.public_subnets == null ? [] : each.value.public_subnets

  enable_dns_hostnames          = each.value.enable_dns_hostnames
  enable_dns_support            = each.value.enable_dns_support
  map_public_ip_on_launch       = each.value.map_public_ip_on_launch
  manage_default_security_group = each.value.manage_default_security_group
  manage_default_network_acl    = each.value.manage_default_network_acl

  enable_nat_gateway     = each.value.enable_nat_gateway
  single_nat_gateway     = each.value.single_nat_gateway
  one_nat_gateway_per_az = each.value.one_nat_gateway_per_az

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}

resource "aws_vpc_ipv4_cidr_block_association" "this" {
  for_each = { for k,v in var.vpc: k => v if v.secondary_cidr != null }

  vpc_id = module.vpc[each.key].vpc_id

  cidr_block = each.value.secondary_cidr
}

module "vpc_endpoints" {
  source   = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  for_each = { for k, v in var.vpc : k => v if v.endpoints_enabled }
  version  = "~> 5.1"

  vpc_id = module.vpc[each.key].vpc_id

  # Security group
  create_security_group      = true
  security_group_name_prefix = "${module.vpc[each.key].name}-vpc-endpoints-"
  security_group_description = "VPC endpoint security group"
  security_group_rules = {
    ingress_https = {
      description = "HTTPS from VPC"
      cidr_blocks = [module.vpc[each.key].vpc_cidr_block]
    }
  }

  endpoints = merge({
    s3 = {
      service         = "s3"
      service_type    = "Gateway"
      route_table_ids = module.vpc[each.key].private_route_table_ids
      tags = {
        Name = "${module.vpc[each.key].name}-s3"
      }
    }
    },
    { for service in toset(["autoscaling", "ecr.api", "ecr.dkr", "ec2", "ec2messages", "elasticloadbalancing", "sts", "kms", "logs", "ssm", "ssmmessages"]) :
      replace(service, ".", "_") =>
      {
        service             = service
        subnet_ids          = module.vpc[each.key].private_subnets
        private_dns_enabled = true
        tags                = { Name = "${module.vpc[each.key].name}-${service}" }
      }
  })
}
