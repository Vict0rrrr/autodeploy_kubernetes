# Variables
variable "vm_name" {
  default = "k8s-node-1"
}

variable "vm_memory" {
  default = 1024
}

variable "vm_cores" {
  default = 1
}

variable "vm_disk_size" {
  default = "20G"
}

variable "ssh_pub_key" {
  default = "~/.ssh/id_rsa.pub" # chemin de ta clé SSH publique
}

variable "network_vlan" {
  default = 45
}

variable "network_bridge" {
  default = "vmbr1"
}

variable "cloud_image_path" {
  default = "/var/lib/vz/template/qcow2/debian-12-genericcloud-amd64.qcow2"
}

variable "user_name" {
  default = "user"
}


# Génération automatique d'une clé SSH pour cette VM
resource "tls_private_key" "vm_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Stocker la clé privée localement
resource "local_file" "private_key" {
  content  = tls_private_key.vm_ssh_key.private_key_pem
  filename = "./${var.vm_name}_id_rsa"
  file_permission = "0600"
}

# Ressource VM
resource "proxmox_vm_qemu" "debian_vm" {
  name        = var.vm_name
  target_node = "PROXMOX-PVE-1"
  cores       = var.vm_cores
  memory      = var.vm_memory
  sockets     = 1

  # Import du disque cloud-init
  disk {
    type    = "scsi"
    storage = "SSD-PVE-DATA"
    size    = var.vm_disk_size
    file    = var.cloud_image_path
  }

  # Configuration réseau avec VLAN
  network {
    model  = "virtio"
    bridge = var.network_bridge
    tag    = var.network_vlan   # VLAN
  }

  # Cloud-init: utilisateur et clé SSH
  ciuser    = var.user_name
  sshkeys   = file(var.ssh_pub_key)
  ipconfig0 = "ip=192.168.45.20/24,gw=192.168.45.200,dns=1.1.1.1"

  # Optionnel : démarrer la VM après création
  onboot = true
}