data "aws_vpc" "vpc" {
  for_each = var.security_rules

  filter {
    name   = "tag:Name"
    values = [each.value.vpc_name]
  }
}

module "sg" {
  source   = "terraform-aws-modules/security-group/aws"
  for_each = var.security_rules

  name        = each.key
  description = each.value.description
  vpc_id      = data.aws_vpc.vpc[each.key].id

  ingress_with_cidr_blocks = [for i in each.value.ingress_cidr : { for k, v in i : k => v if v != null }]
  egress_with_cidr_blocks  = [for i in each.value.outbound_cidr : { for k, v in i : k => v if v != null }]
}
