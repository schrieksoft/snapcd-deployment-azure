provider "snapcd" {
  url                           = var.bootstrap_snapcd_url
  insecure_skip_verify          = true
  health_check_interval_seconds = 5
  health_check_timeout_seconds  = 20
  client_id                     = var.bootstrap_snapcd_client_id
  client_secret                 = var.bootstrap_snapcd_client_secret
  organization_id               = var.bootstrap_snapcd_organization_id
}
