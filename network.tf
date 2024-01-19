// Create VPC networks for segments
resource "yandex_vpc_network" "vpc" {
  name  = "disk-testing"
  folder_id = var.folder_id
}

// Create subnets for segments
resource "yandex_vpc_subnet" "subnet" {
  name           = "subnet-${substr(var.az_name, -1, -1)}"
  folder_id      = var.folder_id
  zone           = var.az_name
  network_id     = yandex_vpc_network.vpc.id
  v4_cidr_blocks = var.subnet_prefix
}

