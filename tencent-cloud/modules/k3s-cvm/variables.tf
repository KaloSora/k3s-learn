# variable "password" {
#   type = string
#   description = "The password of the instance."
# }

variable "cpu_core_count" {
  type = number
  description = "The CPU core count of the instance."
  default = 4
}

variable "memory_size" {
  type = number
  description = "The memory size(GB) of the instance."
  default = 8
}

variable "availability_zone" {
  type = string
  description = "The availability zone of the instance."
}

variable "charge_type" {
  type = string
  description = "The charge type of the instance."
  default = "SPOTPAID"
}