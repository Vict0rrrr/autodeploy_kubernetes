resource "tls_private_key" "sshkey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}