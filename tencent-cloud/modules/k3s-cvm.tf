module "k3s-cvm" {
  source = "./k3s-cvm"
  cpu_core_count = var.cpu_core_count
  memory_size    = var.memory_size
  availability_zone = var.availability_zone
  charge_type = var.charge_type
  # password = var.password
}