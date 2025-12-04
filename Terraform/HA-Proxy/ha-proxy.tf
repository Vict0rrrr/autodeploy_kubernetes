resource "proxmox_vm_qemu" "debian_vm" {
  name        = "HA-PROXY"
  target_node = var.target_node
  clone       = "debian13-cloud-init"

  vmid    = 02005
  cores   = 2
  sockets = 1
  memory  = 2048

  # --- Cloud-init NETWORK ---
  ipconfig0 = "ip=192.168.20.5/24,gw=192.168.20.200"

  # --- Cloud-init USER DATA ---
  ciuser     = "user"
  cipassword = "user"

  # --- Network interface ---
  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr1"
    tag = 20
  }

 cicustom   = "vendor=local:snippets/qemu-guest-agent.yml" # /var/lib/vz/snippets/qemu-guest-agent.yml
 ciupgrade  = true
 skip_ipv6  = true
 nameserver = "1.1.1.1 8.8.8.8"
 sshkeys = local.public_key
  # --- Root disk ---
  disk {
    slot    = 0
    size    = "20G"
    type    = "scsi"
    storage = "SSD-PVE-DATA"
  }

  # --- Cloud-init disk (OBLIGATOIRE) ---
  # Le storage doit supporter les images cloud-init (local-lvm ok)
  disks {
    scsi {
      scsi0 {
        disk {
          storage = "SSD-PVE-DATA"
          size    = "40G"
        }
      }
    }

    ide {
      # Some images require a cloud-init disk on the IDE controller, others on the SCSI or SATA controller
      ide1 {
        cloudinit {
          storage = "SSD-PVE-DATA"
        }
      }
    }

  # Boot order pour éviter les erreurs
  boot = "order=scsi0;ide2"
}
