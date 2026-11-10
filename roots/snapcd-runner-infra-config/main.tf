// Generated straight into the Runner's Key Vault. Add the public key as a deploy key where the Runner clones from.
resource "azrandom_cryptographic_key" "ssh" {
  name      = "snapcd-runner-ssh-private-key"
  algorithm = "RSA"
  rsa_bits  = 4096
  keepers   = var.keepers
}
