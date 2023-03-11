data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

resource "oci_containerengine_cluster" "k8s_cluster" {
  compartment_id     = var.compartment_id
  kubernetes_version = var.kubernetes_version
  name               = var.name
  vcn_id             = var.vcn_id

  endpoint_config {
    is_public_ip_enabled = true
    subnet_id            = var.subnets.lb_subnet
  }

  options {

    add_ons {
      is_kubernetes_dashboard_enabled = false
      is_tiller_enabled               = false
    }

    kubernetes_network_config {
      pods_cidr     = var.network_conf.pods_cidr
      services_cidr = var.network_conf.services_cidr
    }
    service_lb_subnet_ids = [var.subnets.lb_subnet]
  }
}

resource "oci_containerengine_node_pool" "k8s_node_pool" {
  for_each           = var.node_pool_config
  cluster_id         = oci_containerengine_cluster.k8s_cluster.id
  compartment_id     = var.compartment_id
  kubernetes_version = each.value.node_kube_version
  name               = each.key

  node_config_details {
    dynamic "placement_configs" {
      for_each = data.oci_identity_availability_domains.ads.availability_domains

      content {
        availability_domain = placement_configs.value.name
        subnet_id           = var.subnets.private
      }
    }
    size = each.value.size
  }

  node_shape = each.value.shape

  node_shape_config {
    memory_in_gbs = each.value.mem_gbs
    ocpus         = each.value.ocpus
  }
  node_source_details {
    image_id    = var.source_ids[each.value.shape]
    source_type = each.value.source_type
  }

  ssh_public_key = each.value.ssh_public_key
}
