variable "folder_id" {
  type        = string
  description = "folder id for resources"
  default     = null
}

variable "az_name" {
  type        = string
  description = "Availability zone name for resources"
  default     = "ru-central1-a"
}

variable "subnet_prefix" {
  type        = list(string)
  description = "Prefix for subnet"
  default     = ["10.160.0.0/24"]
}

variable "trusted_ip_for_access" {
  type        = list(string)
  description = "List of trusted public IP addresses for connection to VM"
  default     = null
}

variable "vm_admin_username" {
  type        = string
  description = "VM admin username"
  default     = "admin" 
}

variable "vm_vCPU" {
  type      = number
  description = "number of vCPU for test VMs"
  default   = 10
}

variable "vm_RAM" {
  type      = number
  description = "RAM in GB for test VMs"
  default   = 10
}

variable "disk_fill_percent" {
  type      = number
  description = "Percent of total disk size to fill in with data during fio test. The more percent to fill in disk with test data the more time test takes to run."
  default   = 10
}

