variable "token" {
  type = string
}
variable "cloud_id" {
  type = string
}
variable "folder_id" {
  type = string
}
variable "zone" {
  type = string
}

provider "yandex" {
  token = "${var.token}"
  cloud_id = "${var.cloud_id}"
  folder_id = "${var.folder_id}"
  zone = "${var.zone}"
}

resource "yandex_compute_instance" "vm-1" {
  name = "ubuntu-2204-lts"
  platform_id = "standard-v1"
  zone = "${var.zone}"
 
  resources {
    cores  = 2
    memory = 4
    core_fraction = 20
  }
 
  boot_disk {
    initialize_params {
      image_id = "fd8smb7fj0o91i68s15v"
      size = 10
      type = "network-hdd"
    }
  }
  
  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }
 
  metadata = {
    user-data = "${file("./cloud_config.yaml")}"
  }
  
  scheduling_policy {
    preemptible = true
  }
  
  provisioner "local-exec" {
    command = "echo \"[stack]\nvm-1 ansible_host=${yandex_compute_instance.vm-1.network_interface.0.nat_ip_address} ansible_user=s045724\" | tee hosts.ini"
  }
}

resource "yandex_vpc_network" "network-1" {}

resource "yandex_vpc_subnet" "subnet-1" {
  zone           = "${var.zone}"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["10.2.0.0/16"]
}

output "external_ip_address_vm_1" {
  value = "${yandex_compute_instance.vm-1.network_interface.0.nat_ip_address}" 
}