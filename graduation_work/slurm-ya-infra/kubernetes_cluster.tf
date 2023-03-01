resource "yandex_kubernetes_cluster" "k8s-zonal" {
  network_id = yandex_vpc_network.this.id
  master {
    version = "1.22"
    public_ip = true
    
    zonal {
      zone      = yandex_vpc_subnet.this.zone
      subnet_id = yandex_vpc_subnet.this.id
    }
    
    maintenance_policy {
      auto_upgrade = false
    }
  }
  service_account_id      = yandex_iam_service_account.this.id
  node_service_account_id = yandex_iam_service_account.this.id
  
  depends_on = [
    yandex_iam_service_account.this,
    yandex_resourcemanager_folder_iam_binding.k8s-clusters-agent,
    yandex_resourcemanager_folder_iam_binding.vpc-public-admin,
    yandex_resourcemanager_folder_iam_binding.images-puller
  ]
  
  kms_provider {
    key_id = yandex_kms_symmetric_key.this.id
  }
}

resource "yandex_iam_service_account" "this" {
  name        = "sa-account"
  description = "K8S zonal service account"
}

resource "yandex_resourcemanager_folder_iam_binding" "k8s-clusters-agent" {
  # Сервисному аккаунту назначается роль "k8s.clusters.agent".
  folder_id = var.YC_FOLDER_ID
  role      = "k8s.clusters.agent"
  members = [
    "serviceAccount:${yandex_iam_service_account.this.id}"
  ]
}

resource "yandex_resourcemanager_folder_iam_binding" "vpc-public-admin" {
  # Сервисному аккаунту назначается роль "vpc.publicAdmin".
  folder_id = var.YC_FOLDER_ID
  role      = "vpc.publicAdmin"
  members = [
    "serviceAccount:${yandex_iam_service_account.this.id}"
  ]
}

resource "yandex_resourcemanager_folder_iam_binding" "load-balancer-admin" {
  # Сервисному аккаунту назначается роль "load-balancer.admin".
  folder_id = var.YC_FOLDER_ID
  role      = "load-balancer.admin"
  members = [
    "serviceAccount:${yandex_iam_service_account.this.id}"
  ]
}

resource "yandex_resourcemanager_folder_iam_binding" "images-puller" {
  # Сервисному аккаунту назначается роль "container-registry.images.puller".
  folder_id = var.YC_FOLDER_ID
  role      = "container-registry.images.puller"
  members = [
    "serviceAccount:${yandex_iam_service_account.this.id}"
  ]
}

resource "yandex_kms_symmetric_key" "this" {
  # Ключ для шифрования важной информации, такой как пароли, OAuth-токены и SSH-ключи.
  name              = "kms-key"
  default_algorithm = "AES_128"
  rotation_period   = "8760h" # 1 год.
}

resource "yandex_kms_symmetric_key_iam_binding" "this" {
  symmetric_key_id = yandex_kms_symmetric_key.this.id
  role             = "viewer"
  members = [
    "serviceAccount:${yandex_iam_service_account.this.id}",
  ]
}

resource "yandex_kubernetes_node_group" "this" {
  cluster_id  = "${yandex_kubernetes_cluster.k8s-zonal.id}"
  name        = "node-group-1"
  version     = "1.22"
  
  instance_template {
    platform_id = "standard-v2"

    network_interface {
      nat                = true
      subnet_ids         = ["${yandex_vpc_subnet.this.id}"]
    }

    resources {
      memory = 2
      cores  = 2
    }

    boot_disk {
      type = "network-hdd"
      size = 64
    }

    scheduling_policy {
      preemptible = false
    }

    container_runtime {
      type = "containerd"
    }
  }

  scale_policy {
    fixed_scale {
      size = 2
    }
  }

  allocation_policy {
    location {
      zone = var.az
    }
  }

  maintenance_policy {
    auto_upgrade = false
    auto_repair  = true
  }
}