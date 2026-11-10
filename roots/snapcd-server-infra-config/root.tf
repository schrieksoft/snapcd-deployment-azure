terraform {
  required_providers {
    azrandom = {
      source  = "registry.terraform.io/schrieksoft/azrandom"
      version = "0.1.3"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.20.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
  }
}
