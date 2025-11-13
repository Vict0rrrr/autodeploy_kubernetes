resource "proxmox_vm_qemu" "debian_test" {
  name        = "debian-test-01"
  target_node = "PROXMOX-PVE1"
  clone       = "debian-12-template-cloud"
  full_clone  = true


 # Configuration matérielle
  cores       = 1
  sockets     = 1
  memory      = 2048
  scsihw      = "virtio-scsi-pci"
  bootdisk    = "scsi0"

  disk {
    slot     = 0
    size     = "50G"
    type     = "scsi"
    storage  = "SSD-PVE-DATA"
    iothread = true
  
  }

  # Réseau
  network {
    model  = "virtio"
    bridge = "vmbr1"
    tag    = 40
  }

  # Cloud-init
  ciuser      = "debian"
  cipassword  = "debian"

   # DHCP automatique
  ipconfig0 = "ip=dhcp"
}