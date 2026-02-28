variable "disk_image" {
  type        = string
  description = "Image id for all vm boot disks"
  default     = "fd84mnbiarffhtfrhnog"
}

variable "instances" {
  type        = map(any)
  description = "VM instances to be created for Wikimedia project infrastructure"
  default = {
    "balancer"    = true
    "wikimedia-1" = false
    "wikimedia-2" = false
    "db-1"        = false
    "db-2"        = false
    "monitoring"  = true
  }
}

variable "is_test" {
  type        = bool
  description = "Is infrastructure on test. If true then allow to stop VMs"
  default     = true
}
