terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.46.0"
    }
    local = {
      source = "hashicorp/local"
      version = "2.3.0"
    }
  }
}

provider "azurerm" {
  features {}
}