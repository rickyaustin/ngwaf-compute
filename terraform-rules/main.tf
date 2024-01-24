# Terraform 0.13.x
terraform {
  required_providers {
    sigsci = {
      source = "signalsciences/sigsci"
    }
  }
}

provider "sigsci" {
  corp = var.sigsci_corp
  email = var.NGWAF_EMAIL
  auth_token = var.NGWAF_TOKEN
}
















