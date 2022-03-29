# Variables related to the resource group
variable "resource_group_name" {
  description = "Name of the resource group within which resources will be created"
  type        = string
  default     = "example_rg"
}

variable "location" {
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

variable "keep_n_days" {
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
variable "registry_server" {
  description = "Link to the container registry"
  type        = string
}

variable "registry_username" {
  description = "Username of the container registry"
  type        = string
}

variable "registry_password" {
  description = "Password of the container registry"
  type        = string
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