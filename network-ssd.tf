// Create network-ssd disk
resource "yandex_compute_disk" "network-ssd" {
  folder_id  = var.folder_id
  name       = "network-ssd"
  type       = "network-ssd"
  zone       = var.az_name
  size       = 1280
}

// Create network-ssd-vm
resource "yandex_compute_instance" "network-ssd-vm" {
  folder_id = var.folder_id
  name        = "network-ssd-vm"
  hostname    = "network-ssd-vm"
  platform_id = "standard-v3"
  zone        = var.az_name

  resources {
    cores  = var.vm_vCPU
    memory = var.vm_RAM
  }

  boot_disk {
    initialize_params {
      image_id = "fd877fuskeokm2plco89"
      type     = "network-ssd"
      size     = 20
    }
  }

  secondary_disk {
    disk_id = yandex_compute_disk.network-ssd.id
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.subnet.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.vm-sg.id] 
  }

  metadata = {
    user-data = templatefile("./templates/cloud-init_vm.tpl.yaml",
    {
      vm_ssh_key_pub = "${chomp(tls_private_key.ssh.public_key_openssh)}",
      vm_admin_username = var.vm_admin_username,
      device = "vdb"
    })
  }
}

// Wait for SSH connection to network-ssd-vm
resource "null_resource" "wait_for_ssh_network-ssd-vm" {
  connection {
    type = "ssh"
    user = "${var.vm_admin_username}"
    private_key = local_file.private_key.content
    host = yandex_compute_instance.network-ssd-vm.network_interface.0.nat_ip_address
  }
 
 // Wait for fio test to be completed
  provisioner "remote-exec" {
    inline = [
      "sudo timedatectl set-timezone Europe/Moscow",
      "while ! yum list installed fio; do sleep 5; echo \"Waiting for fio to be installed...\"; done",
      "while ! mount | grep /app; do sleep 5; echo \"Waiting for /app to be mounted...\"; done",
      "sudo fio --filename=/app/fiotest.dat --rw=randread --size=${floor(var.disk_fill_percent/100*yandex_compute_disk.network-ssd.size)}G --ioengine=libaio --bs=8k --iodepth=256 --numjobs=1 --runtime=120 --group_reporting --direct=1 --name=random-read --output-format=json --output=network-ssd_rand-read_$(date \"+%Y.%m.%d_%H-%M-%S\")_${yandex_compute_instance.network-ssd-vm.id}_${yandex_compute_disk.network-ssd.id}.json",
      "sleep 2m",
      "sudo fio --filename=/app/fiotest.dat --rw=randwrite --size=${floor(var.disk_fill_percent/100*yandex_compute_disk.network-ssd.size)}G --ioengine=libaio --bs=8k --iodepth=256 --numjobs=1 --runtime=120 --group_reporting --direct=1 --name=random-write --output-format=json --output=network-ssd_rand-write_$(date \"+%Y.%m.%d_%H-%M-%S\")_${yandex_compute_instance.network-ssd-vm.id}_${yandex_compute_disk.network-ssd.id}.json"
    ]
  }
 
  depends_on = [
    yandex_compute_instance.network-ssd-vm,
    local_file.private_key
  ]
}

// Download fio tests results from network-ssd-vm
resource "null_resource" "get_network-ssd-vm_test-results" {
  provisioner "local-exec" {
    command = "scp -i pt_key.pem -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r ${var.vm_admin_username}@${yandex_compute_instance.network-ssd-vm.network_interface.0.nat_ip_address}:~/*.json results"
  }
 
  depends_on = [
    null_resource.wait_for_ssh_network-ssd-vm
  ]
}

