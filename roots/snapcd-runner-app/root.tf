terraform {
  required_providers {
    tls = {
      source  = "hashicorp/tls"
      version = "4.1.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.0.2"
    }
  }
}
