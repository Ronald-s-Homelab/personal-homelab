variable "compartment_id" {
  type = string
}

variable "name" {
  type = string
}

variable "kubernetes_version" {
  type = string
}

variable "vcn_id" {
  type = string
}

variable "network_conf" {
  type = object({
    pods_cidr     = string
    services_cidr = string
  })
}

variable "subnets" {
  type = map(string)
}

variable "source_ids" {
  type = map(string)
  default = {
    "VM.Standard.A1.Flex"    = "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaarbvtai3sxdzkhya7wd5laqsoa53gng2cjr4ya437o3mvfcyi6lbq"
    "VM.Standard.E2.1.Micro" = "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaamvxipgtbsj4eocdxihklbgkem5rwmtxewgm5sxnr4hrd72qpp3fq"
  }
}

variable "node_pool_config" {
  type = map(object({
    size              = number
    shape             = string
    mem_gbs           = number
    ocpus             = number
    source_type       = optional(string, "image")
    ssh_public_key    = optional(string)
    node_kube_version = string
  }))
}
