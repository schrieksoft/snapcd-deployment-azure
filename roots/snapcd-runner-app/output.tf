// Add as a deploy key wherever the Runner clones from over SSH.
output "snapcd_runner_ssh_public_key_openssh" {
  value = local.use_akv ? var.snapcd_runner_ssh_public_key_openssh : try(trimspace(tls_private_key.ssh[0].public_key_openssh), "")
}
