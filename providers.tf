provider "snapcd" {
  url                           = var.snapcd_url
  insecure_skip_verify          = true
  health_check_interval_seconds = 5
  health_check_timeout_seconds  = 20
  client_id                     = var.snapcd_client_id
  client_secret                 = var.snapcd_client_secret
  organization_id               = var.snapcd_organization_id
}
