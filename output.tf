output "path_for_private_ssh_key" {
  value = "./pt_key.pem"
}

output "network-ssd-vm_public-ip" {
  value = yandex_compute_instance.network-ssd-vm.network_interface.0.nat_ip_address 
}

output "nrd-vm_public-ip" {
  value = yandex_compute_instance.nrd-vm.network_interface.0.nat_ip_address 
}

output "network-ssd-io-vm_public-ip" {
  value = yandex_compute_instance.network-ssd-io-m3-vm.network_interface.0.nat_ip_address 
}

output "local-ssd-vm_public-ip" {
  value = yandex_compute_instance.local-ssd-vm.network_interface.0.nat_ip_address 
}
