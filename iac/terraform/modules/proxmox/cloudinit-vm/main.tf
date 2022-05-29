resource "proxmox_vm_qemu" "cloudinit-test" {
  for_each    = { for k, v in var.vms : k => merge(var.defaults, v) }
  name        = each.key
  desc        = each.value.desc
  target_node = each.value.target_node

  clone      = each.value.clone
  full_clone = true

  cores   = each.value.cores
  sockets = each.value.sockets
  memory  = each.value.memory

  scsihw  = "virtio-scsi-pci"
  os_type = "cloud-init"

  ciuser    = each.value.user
  ipconfig0 = coalesce(each.value.ipconfig, "ip=dhcp")
  sshkeys   = each.value.sshkeys

  network {
    model   = "virtio"
    bridge  = "vmbr2"
    macaddr = try(each.value.macaddr, null)
  }

  disk {
    type    = "scsi"
    storage = "vm-disks"
    size    = each.value.disk-size
  }

  serial {
    id   = 0
    type = "socket"
  }

}

