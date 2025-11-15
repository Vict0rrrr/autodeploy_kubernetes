#############################################
# Déploiement des WORKER NODES
#############################################

resource "proxmox_vm_qemu" "workers" {
  for_each = toset(var.worker_ips)

  # VMID basé sur IP
  vmid = tonumber("${split(".", each.value)[2]}${split(".", each.value)[3]}")

  # Nom : DEVVER-KUB-WORKER-1 / WORKER-2 …
  name = "DEVVER-KUB-WORKER-${local.worker_map[each.value] + 1}"

  target_node = var.target_node
  agent       = 1

  # CONFIGURATION SPÉCIFIQUE WORKER
  cores       = 2
  memory      = 2048
  clone       = "debian13-cloudinit"

  ipconfig0 = "ip=${each.value}/24,gw=192.168.45.254"

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
