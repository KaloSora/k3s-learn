variable "secret_id" {
  type = string
  description = "tencent cloud access id"
  default = "Your Access ID"
}

variable "secret_key" {
  type = string
  description = "tencent cloud access key"
  default = "Your Access Key"
}

# variable "password" {
#   type = string
#   description = "tencent cloud instance password"
# }

variable "region" {
  type = string
  description = "tencent cloud region"
  default = "ap-hongkong"
}

variable "availability_zone" {
  type = string
  description = "tencent cvm availability zone"
  default = "ap-hongkong-2"
}

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

variable "charge_type" {
  type = string
  description = "The charge type of the instance. Valid values: POSTPAID_BY_HOUR, SPOTPAID."
  default = "SPOTPAID"
}