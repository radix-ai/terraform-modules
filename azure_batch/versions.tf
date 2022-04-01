terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.98"
    }
  }
  required_version = ">= 1.1.3"
}

# Plugin used by Terraform uses to create and manage resources.
provider "azurerm" {
  features {}

  # Specify the subscription ID
  subscription_id = "yoursubscriptionid"
}