locals {

  source_url = "git@github.com:schrieksoft/snapcd-deployment-azure.git"

  public_gateway_domain_name_label = "snapcd"

  // Charts from oci://ghcr.io/schrieksoft/charts, used for the Server, Runner and Agent.
  snapcd_chart_version = "0.1.16"

  before_hook_base = <<EOT
EOT


}
