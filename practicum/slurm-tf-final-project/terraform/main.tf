data "yandex_compute_image" "this" {
  name = "${var.image_name}-${var.image_tag}"
  folder_id = "${var.YC_FOLDER_ID}"
}

data "yandex_vpc_network" "this" {
  network_id = "${yandex_vpc_network.this.id}"
  depends_on = [
    yandex_vpc_subnet.this,
  ]
}

resource "yandex_iam_service_account" "this" {
  name        = "ig-sa"
  description = "service account to manage IG"
}

resource "yandex_resourcemanager_folder_iam_binding" "this" {
  folder_id = "${var.YC_FOLDER_ID}"
  role      = "editor"
  members   = [
    "serviceAccount:${yandex_iam_service_account.this.id}",
  ]
  depends_on = [
    yandex_iam_service_account.this,
  ]
}

resource "yandex_compute_instance_group" "this" {
  name               = "fixed-ig"
  folder_id          = "${var.YC_FOLDER_ID}"
  service_account_id = "${yandex_iam_service_account.this.id}"
  depends_on          = [
    yandex_resourcemanager_folder_iam_binding.this,
  ]
  instance_template {
    platform_id = "standard-v1"
    resources {
      core_fraction = 20
      memory = 1
      cores  = 2
    }
    
    scheduling_policy {
      preemptible = true
    } 
    
    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        #image_id = var.image_id
        image_id = "${data.yandex_compute_image.this.id}"
      }
    }

    network_interface {
      network_id = "${yandex_vpc_network.this.id}"
      subnet_ids = "${data.yandex_vpc_network.this.subnet_ids}"
    }

    metadata = {
      user-data = "${file("./cloud_config.yaml")}"
    }
  }

  scale_policy {
    fixed_scale {
      size = var.vm_count
    }
  }

  allocation_policy {
    zones = var.az
  }

  deploy_policy {
    max_unavailable = 1
    max_expansion = 0
  }
}