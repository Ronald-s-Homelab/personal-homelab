data "oci_identity_availability_domains" "ad" {
  compartment_id = var.compartment_id
}

resource "oci_core_instance" "vm" {

  display_name        = var.name
  compartment_id      = var.compartment_id
  shape               = var.shape.shape
  availability_domain = data.oci_identity_availability_domains.ad.availability_domains[0].name

  create_vnic_details {
    assign_public_ip = var.public
    subnet_id        = var.subnet_id
  }

  shape_config {
    memory_in_gbs = var.shape.mem_gbs
    ocpus         = var.shape.ocpus
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }

  source_details {
    source_id   = "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaawyqwfxyjb2ujxv7qwabgp77sstxkf6fzxlgu4kjegkhigqpyoeca"
    source_type = "image"
  }

  preserve_boot_volume = var.preserve_boot_volume
}
