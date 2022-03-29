# Create an Azure Blob Storage linked to Azure Batch
resource "azurerm_storage_account" "BatchStorageAccount" {
  name                     = "batch${terraform.workspace}storage"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}


# Create a container to store the files related to azure Batch
resource "azurerm_storage_container" "BatchABSContainer" {
  name                  = var.container_name
  storage_account_name  = azurerm_storage_account.BatchStorageAccount.name
  container_access_type = "private"
}


# Retention policy of 1 day in the previously created container
resource "azurerm_storage_management_policy" "storage_management_policy" {
  storage_account_id = azurerm_storage_account.BatchStorageAccount.id

  rule {
    name    = "delete-older-than-n-days"
    enabled = true
    filters {
      prefix_match = ["${var.container_name}/"]
      blob_types   = ["blockBlob"]
    }
    actions {
      base_blob {
        delete_after_days_since_modification_greater_than = var.keep_n_days
      }
      snapshot {
        delete_after_days_since_creation_greater_than = var.keep_n_days
      }
    }
  }
}

# Create an Azure Batch account
resource "azurerm_batch_account" "BatchAccount" {
  name                 = "batchaccount${terraform.workspace}"
  resource_group_name  = var.resource_group_name
  location             = var.location
  pool_allocation_mode = "BatchService"
  storage_account_id   = azurerm_storage_account.BatchStorageAccount.id
}

# Create the pool within the Azure Batch account
resource "azurerm_batch_pool" "BatchPool" {
  name                = "pool-${terraform.workspace}"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_batch_account.BatchAccount.name
  display_name        = "Time-based autoscaled pool"
  vm_size             = var.vm_size
  node_agent_sku_id   = "batch.node.ubuntu 20.04"

  auto_scale {
    evaluation_interval = "PT5M"

    # Autoscale formula (see: https://docs.microsoft.com/en-us/azure/batch/batch-automatic-scaling)
    formula = var.autoscale_formula
  }

  # Warning: only the 'microsoft-azure-batch' publisher provides Docker-compatible images
  storage_image_reference {
    publisher = "microsoft-azure-batch"
    offer     = "ubuntu-server-container"
    sku       = "20-04-lts"
    version   = "latest"
  }

  container_configuration {
    type = "DockerCompatible"
    container_registries {
      # Put informations about your custom image here
      registry_server = var.registry_server
      user_name       = var.registry_username
      password        = var.registry_password
    }
  }

  start_task {
    # Replace the following by the Docker entrypoint
    command_line       = var.command_line
    task_retry_maximum = 1
    wait_for_success   = true

    user_identity {
      auto_user {
        elevation_level = "NonAdmin"
        scope           = "Task"
      }
    }
  }
}