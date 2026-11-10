// Generated straight into the Runner's Key Vault, so the private key is never in state.
resource "azrandom_cryptographic_key" "ssh" {
  name      = "${var.name}-ssh-private-key"
  algorithm = "RSA"
  rsa_bits  = 4096
  keepers   = var.keepers
}
