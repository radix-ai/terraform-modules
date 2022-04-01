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
          $curTime = time();
          $workHours = $curTime.hour >= 8 && $curTime.hour < 18;
          $isWeekday = $curTime.weekday >= 1 && $curTime.weekday <= 5;
          $isWorkingWeekdayHour = $workHours && $isWeekday;
          $TargetDedicatedNodes = $isWorkingWeekdayHour ? 2:1;
          $NodeDeallocationOption = taskcompletion;
  EOF
}