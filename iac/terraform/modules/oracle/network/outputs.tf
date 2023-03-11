output "subnet_ocid" {
  value = { for k, v in oci_core_subnet.subnet : k => v.id }
}

output "vcn_id" {
  value = oci_core_vcn.vcn.id
}
