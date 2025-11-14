#############################################
# Déploiement des MASTER NODES
#############################################

resource "proxmox_vm_qemu" "masters" {
  for_each = toset(var.master_ips)

  # VMID => concat 3e + 4e octet de l'IP
  vmid = tonumber("${split(".", each.value)[2]}${split(".", each.value)[3]}")

  # Nom => DEVVER-KUB-MASTER-1 / MASTER-2 / MASTER-3 …
  name = "DEVVER-KUB-MASTER-${local.master_map[each.value] + 1}"

  target_node = var.target_node
  agent       = 1

  # CONFIGURATION SPÉCIFIQUE MASTER
  cores       = 4
  memory      = 4096
  clone       = "debian13-cloudinit"

  # IP cloud-init
  ipconfig0 = "ip=${each.value}/24,gw=192.168.45.1"

  serial { id = 0 }

  disks {
    scsi {
      scsi0 {
        disk {
          storage = "SSD-PVE-DATA"
          size    = "40G"
        }
      }
    }
  }

  network {
    id     = 0
    bridge = "vmbr1"
    model  = "virtio"
    tag    = 45
  }
}
