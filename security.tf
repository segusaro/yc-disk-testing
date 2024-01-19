//Create Security Groups-------------------

// Create security group for VM
resource "yandex_vpc_security_group" "vm-sg" {
  name        = "vm-sg"
  description = "Security group for Jump VM"
  folder_id   = var.folder_id
  network_id  = yandex_vpc_network.vpc.id

  ingress {
    protocol            = "TCP"
    description         = "SSH from trusted public IP addresses"
    port                = 22
    v4_cidr_blocks      = var.trusted_ip_for_access
  }

  egress {
    protocol       = "ANY"
    description    = "outbound traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

