module "ec2_instance" {
  source   = "terraform-aws-modules/ec2-instance/aws"
  for_each = var.instances

  name = each.key

  instance_type          = each.value.type
  key_name               = each.value.key_name
  monitoring             = each.value.monitoring
  vpc_security_group_ids = each.value.vpc_security_group_ids
  subnet_id              = each.value.subnet_id

  tags = each.value.tags
}
