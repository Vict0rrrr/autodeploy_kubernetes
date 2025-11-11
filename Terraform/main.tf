terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "~> 2.10"
    }
  }
}

provider "proxmox" {
  pm_api_url      = "https://192.168.5.3:8006/api2/json"
  pm_user         = {{secrets.PM_USER}}
  pm_password     = {{secrets.PM_PASSWORD}}
  pm_tls_insecure = true   # si certificat auto-signé
}
