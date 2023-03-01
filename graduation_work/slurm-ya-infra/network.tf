resource "yandex_vpc_network" "this" {
  name = "network-1"
}

resource "yandex_vpc_subnet" "this" {
  name = "subnet-1"
  v4_cidr_blocks = ["10.1.0.0/16"]
  zone           = var.az
  network_id     = yandex_vpc_network.this.id
}
