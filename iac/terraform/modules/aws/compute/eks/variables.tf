variable "region" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "cluster_version" {
  type = string
}

variable "create_iam_role" {
  type    = bool
  default = true
}

variable "create_cluster_security_group" {
  type    = bool
  default = false
}

variable "create_node_security_group" {
  type    = bool
  default = false
}

variable "iam_role_arn" {
  type    = string
  default = null
}

variable "vpc_name" {
  type = string
}

variable "subnets" {
  type = list(string)
}

variable "cluster_addons" {
  type = map(any)
}

variable "cluster_security_group_id" {
  type    = string
  default = null
}

variable "enable_aws_load_balancer_controller" {
  type    = bool
  default = false
}

variable "node_groups" {
  type = map(object({
    min_size        = number
    max_size        = number
    desired_size    = number
    instance_types  = list(string)
    capacity_type   = optional(string)
    create_iam_role = optional(bool, true)
    iam_role_arn    = optional(string)
  }))
}
