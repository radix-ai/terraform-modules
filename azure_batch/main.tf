/*

# Purpose

Create an Azure Batch account [1] with a pool populated of Docker-compatible compute nodes [2].

# Notes

1. Create a storage account [3] to store files used by the compute nodes to perform any backend 
   calculation.
2. Create a container within the above-mentioned storage account with a user-tunable retention 
   policy of n days [4].
3. Create the Batch account. Warning: it is not possible to create more then a single Batch Account
   per subscription and per region due to quota limitations (see Ref. [5]). Consider increasing that
   if needed.
4. Create a pool made of Docker-compatible nodes whose size is user-chosen [6]. Warning: by default, 
   only a very limited array of VMs is available (10 VMs chosen amonst the Av2 Series, DSv3 Series, 
   Dv3 Series, ESv3 Series and Ev3 Series). Should you need other types of VMs or more of them, 
   consider asking for an increase of quota for your Azure subscription (see Ref. [5]).

# Usage

module "azure_batch_service" {
  source              = "./modules/batch-account"

  resource_group_name = azurerm_resource_group.BatchResourceGroup.name
  container_name      = "inputcontainer"
  keep_n_days         = 1
  vm_size             = "Standard_A1_V2"
  registry_server     = "myregistry.io"
  registry_username   = "myusername"
  registry_password   = "registrypassword"
  command_line        = "python starting_script.py"
  autoscale_formula   = "write autoscale formula here if needed"
}

# References

[1] https://docs.microsoft.com/en-gb/azure/batch/
[2] https://docs.microsoft.com/en-us/azure/batch/nodes-and-pools
[3] https://docs.microsoft.com/en-us/azure/storage/common/storage-account-overview
[4] https://docs.microsoft.com/en-us/azure/storage/blobs/immutable-time-based-retention-policy-overview
[5] https://docs.microsoft.com/en-us/azure/batch/batch-quota-limit
[6] https://docs.microsoft.com/en-us/azure/batch/batch-docker-container-workloads

*/

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.98" # Don't allow increment until this is fixed: https://github.com/hashicorp/terraform-provider-azurerm/issues/15811
    }
  }
  required_version = ">= 1.1.0"
}

# Plugin used by Terraform uses to create and manage resources.
provider "azurerm" {
  features {}

  # Specify the subscription ID
  subscription_id = "yoursubscriptionid"
}


# Create a resource group that gathers all needed resources 
resource "azurerm_resource_group" "BatchResourceGroup" {
  name     = "rg-${terraform.workspace}"
  location = "West Europe"
}