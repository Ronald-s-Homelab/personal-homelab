locals {
  proto = {
    TCP  = 6
    UDP  = 17
    ICMP = 1
    ALL  = "all"
  }
}
resource "oci_core_vcn" "vcn" {
  #Required
  compartment_id = var.compartment_id

  cidr_block   = var.vcn_cidr_block
  display_name = var.vcn_display_name

}

resource "oci_core_internet_gateway" "gw" {
  compartment_id = var.compartment_id
  display_name   = "gw"
  vcn_id         = oci_core_vcn.vcn.id
}

resource "oci_core_nat_gateway" "gw" {
  count = var.enabled_nat ? 1 : 0

  compartment_id = var.compartment_id
  display_name   = "nat_gw"
  vcn_id         = oci_core_vcn.vcn.id
}

resource "oci_core_route_table" "rt" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id

  display_name = format("%s-table", oci_core_vcn.vcn.display_name)

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.gw.id
  }
}

resource "oci_core_route_table" "nat_rt" {
  for_each       = { for k, v in var.subnets : k => v if v.nat }
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id

  display_name = format("%s-table", oci_core_nat_gateway.gw[0].display_name)

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.gw[0].id
  }
}

resource "oci_core_route_table_attachment" "test_route_table_attachment" {
  for_each = { for k, v in var.subnets : k => v if v.nat }

  subnet_id      = oci_core_subnet.subnet[each.key].id
  route_table_id = oci_core_route_table.nat_rt[each.key].id
}

resource "oci_core_route_table_attachment" "public" {
  for_each = { for k, v in var.subnets : k => v if v.nat == false }

  subnet_id      = oci_core_subnet.subnet[each.key].id
  route_table_id = oci_core_route_table.rt.id
}


resource "oci_core_subnet" "subnet" {
  for_each       = var.subnets
  vcn_id         = oci_core_vcn.vcn.id
  compartment_id = var.compartment_id


  cidr_block                 = each.value.cidr_block
  display_name               = each.key
  prohibit_internet_ingress  = each.value.prohibit_internet_ingress
  security_list_ids          = try([for k in each.value.security_lists : oci_core_security_list.sl[k].id], [oci_core_vcn.vcn.default_security_list_id])
  prohibit_public_ip_on_vnic = each.value.prohibit_public_ip_on_vnic

  depends_on = [
    oci_core_vcn.vcn
  ]
}

resource "oci_core_security_list" "sl" {
  for_each = var.security_lists
  #Required
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id

  #Optional
  display_name = each.key

  dynamic "egress_security_rules" {
    for_each = each.value.egress

    content {
      destination      = egress_security_rules.value.dest
      protocol         = local.proto[upper(egress_security_rules.value.proto)]
      destination_type = egress_security_rules.value.destination_type

      dynamic "icmp_options" {
        for_each = egress_security_rules.value.icmp

        content {
          type = icmp_options.value.type
          code = icmp_options.value.code
        }
      }

      dynamic "tcp_options" {
        for_each = upper(egress_security_rules.value.proto) == "TCP" && length(egress_security_rules.value.ports) > 0 ? [egress_security_rules.value.ports] : []

        content {
          max = length(split("-", tcp_options.value)) > 1 ? split("-", tcp_options.value)[1] : tcp_options.value
          min = length(split("-", tcp_options.value)) > 1 ? split("-", tcp_options.value)[0] : tcp_options.value
        }
      }

      dynamic "udp_options" {
        for_each = upper(egress_security_rules.value.proto) == "UDP" && length(egress_security_rules.value.ports) > 0 ? [egress_security_rules.value.ports] : []

        content {
          max = length(split("-", udp_options.value)) > 1 ? split("-", udp_options.value)[1] : udp_options.value
          min = length(split("-", udp_options.value)) > 1 ? split("-", udp_options.value)[0] : udp_options.value
        }
      }
    }
  }

  dynamic "ingress_security_rules" {
    for_each = each.value.ingress

    content {
      source      = ingress_security_rules.value.source
      protocol    = local.proto[upper(ingress_security_rules.value.proto)]
      source_type = ingress_security_rules.value.source_type

      dynamic "icmp_options" {
        for_each = ingress_security_rules.value.icmp

        content {
          type = icmp_options.value.type
          code = icmp_options.value.code
        }
      }

      dynamic "tcp_options" {
        for_each = upper(ingress_security_rules.value.proto) == "TCP" && length(ingress_security_rules.value.ports) > 0 ? [ingress_security_rules.value.ports] : []

        content {
          max = length(split("-", tcp_options.value)) > 1 ? split("-", tcp_options.value)[1] : tcp_options.value
          min = length(split("-", tcp_options.value)) > 1 ? split("-", tcp_options.value)[0] : tcp_options.value
        }
      }

      dynamic "udp_options" {
        for_each = upper(ingress_security_rules.value.proto) == "UDP" && length(ingress_security_rules.value.ports) > 0 ? [ingress_security_rules.value.ports] : []

        content {
          max = length(split("-", udp_options.value)) > 1 ? split("-", udp_options.value)[1] : udp_options.value
          min = length(split("-", udp_options.value)) > 1 ? split("-", udp_options.value)[0] : udp_options.value
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      ingress_security_rules,
      egress_security_rules
    ]
  }
}
