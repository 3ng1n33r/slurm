resource "yandex_mdb_postgresql_cluster" "this" {
  name                = "postgresql-1"
  environment         = "PRESTABLE"
  network_id          = yandex_vpc_network.this.id
  deletion_protection = false

  config {
    version = 12
    
    access {
      web_sql = true
    }
    
    resources {
      resource_preset_id = "b1.micro"
      disk_type_id       = "network-hdd"
      disk_size          = "10"
    }
  }

  host {
    zone      = var.az
    name      = "yelb-db"
    subnet_id = yandex_vpc_subnet.this.id
  }
}

resource "yandex_mdb_postgresql_database" "this" {
  cluster_id = yandex_mdb_postgresql_cluster.this.id
  name       = "yelbdatabase"
  owner      = "yelbuser"
  depends_on          = [
    yandex_mdb_postgresql_cluster.this,
    yandex_mdb_postgresql_user.this,
  ]
}

resource "yandex_mdb_postgresql_user" "this" {
  cluster_id = yandex_mdb_postgresql_cluster.this.id
  name       = "yelbuser"
  password   = "yelbpassword"
  depends_on          = [
    yandex_mdb_postgresql_cluster.this,
  ]
}
