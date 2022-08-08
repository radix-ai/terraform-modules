# Variables related to the resource group
variable "resource_group_name" {
  description = "Name of the resource group within which resources will be created"
  type        = string
  default     = "rg-batch-computing"
}

variable "resource_group_location" {
  description = "Region name for the resources"
  type        = string
  default     = "West Europe"
}

# Variables related to the storage
variable "container_name" {
  description = "Name of the container on Azure Blob Storage"
  type        = string
  default     = "inputcontainer"
}

variable "keep_inp_files_during_n_days" {
  description = "Number of days to keep files on the Azure Blob Storage container"
  type        = number
  default     = 1
}

# Variables related to the VM size
variable "vm_size" {
  description = "Virtual Machine size (see: https://azure.microsoft.com/en-us/pricing/details/batch/)"
  type        = string
  default     = "Standard_A1_V2"
}

# Variables related to the container registry
variable "container_registry_login_server" {
  description = "Login server for the container registry"
  type        = string
}

variable "container_registry_username" {
  description = "Username for the container registry"
  type        = string
}

variable "container_registry_password" {
  description = "Password for the container registry"
  type        = string
}

# Variables related to the custom Docker image
variable "image_name" {
  description = "Name of the custom Docker image"
  type        = string
  default     = "python"
}

variable "image_tag" {
  description = "Tag of the custom Docker image"
  type        = string
  default     = "3.8"
}


# Variable related to the container configuration
variable "command_line" {
  description = "Command line given to the provided container"
  type        = string
  default     = "echo 'Node started...'"
}


# Variable related to the autoscale of the pool
variable "autoscale_formula" {
  description = "Autoscale formula for the pool"
  type        = string
  default     = <<EOF
          startingNumberOfVMs = 0;
          maxNumberofVMs = 10;
          pendingTaskSamplePercent = $PendingTasks.GetSamplePercent(180 * TimeInterval_Second);
          pendingTaskSamples = pendingTaskSamplePercent < 70 ? startingNumberOfVMs : avg($PendingTasks.GetSample(180 * TimeInterval_Second));
          $TargetDedicatedNodes=min(maxNumberofVMs, pendingTaskSamples);
          $NodeDeallocationOption = taskcompletion;
  EOF
}