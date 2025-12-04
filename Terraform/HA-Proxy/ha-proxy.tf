resource "proxmox_vm_qemu" "ha-proxy" {
  name        = "HA-PROXY"
  target_node = var.target_node
  clone       = "debian13-cloud-init"

  vmid    = 2005
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
    tag    = 20
  }

  cicustom   = "vendor=local:snippets/qemu-guest-agent.yml"
  ciupgrade  = true
  skip_ipv6  = true
  nameserver = "1.1.1.1 8.8.8.8"
  sshkeys = local.public_key

  ####################################################
  # DISKS (seul bloc autorisé)
  ####################################################
  disks {

    # --- Disque principal (root) ---
    scsi {
      scsi0 {
        disk {
          storage = "SSD-PVE-DATA"
          size    = "30G"
        }
      }
    }

    # --- Cloud-init disk ---
    ide {
      ide1 {
        cloudinit {
          storage = "SSD-PVE-DATA"
        }
      }
    }
  }

  # Boot order
  boot = "order=scsi0;ide1"
}
