resource "proxmox_lxc" "basic" {
  for_each = { for k, v in var.lxc : k => merge(var.defaults, v) }

  target_node     = each.value.target_node
  hostname        = each.key
  ostemplate      = each.value.ostemplate
  unprivileged    = each.value.unprivileged
  ssh_public_keys = each.value.sshkeys

  cores  = each.value.cores
  memory = each.value.memory

  // Terraform will crash without rootfs defined
  rootfs {
    storage = "local-lvm"
    size    = each.value.disk-size
  }

  network {
    bridge   = each.value.bridge
    firewall = false
    hwaddr   = each.value.macaddr
    ip       = "dhcp"
    name     = "eth0"
    type     = "veth"
  }
}
