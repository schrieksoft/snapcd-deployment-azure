// Generated straight into the Runner's Key Vault, with key_vault_enabled. Without it, snapcd_runner_app generates the key.
resource "azrandom_cryptographic_key" "ssh" {
  count     = var.key_vault_enabled ? 1 : 0
  name      = "${var.name}-ssh-private-key"
  algorithm = "RSA"
  rsa_bits  = 4096
  keepers   = var.keepers
}
