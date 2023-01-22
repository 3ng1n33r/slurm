resource "yandex_alb_backend_group" "this" {
  name                     = "backend-group-1"
  depends_on          = [
    yandex_compute_instance_group.this,
  ]
  session_affinity {
    connection {
      source_ip = true
    }
  }

  http_backend {
    name                   = "http-backend-1"
    weight                 = 1
    port                   = 80
    target_group_ids       = ["${yandex_compute_instance_group.this.application_load_balancer.*.target_group_id[0]}"]
    load_balancing_config {
      panic_threshold      = 90
    }    
    healthcheck {
      timeout              = "10s"
      interval             = "2s"
      healthy_threshold    = 10
      unhealthy_threshold  = 15 
      http_healthcheck {
        path               = "/"
      }
    }
  }
}

resource "yandex_alb_http_router" "this" {
  name   = "http-router-1"
  depends_on          = [
    yandex_alb_backend_group.this,
  ]
  labels = {
    tf-label    = "tf-label-value"
    empty-label = ""
  }
}

resource "yandex_alb_virtual_host" "this" {
  name           = "virtual-host-1"
  depends_on          = [
    yandex_alb_http_router.this,
    yandex_alb_backend_group.this,
  ]
  http_router_id = "${yandex_alb_http_router.this.id}"
  route {
    name = "route-1"
    http_route {
      http_route_action {
        backend_group_id = "${yandex_alb_backend_group.this.id}"
        timeout          = "3s"
      }
    }
  }
}

resource "yandex_alb_load_balancer" "this" {
  name        = "l7-load-balancer-1"
  network_id  = "${yandex_vpc_network.this.id}"
  depends_on          = [
    yandex_alb_http_router.this,
  ]

  allocation_policy {
    dynamic "location" {
      for_each = yandex_vpc_subnet.this
      content {
        zone_id   = location.value.zone
        subnet_id = location.value.id
      }
    }
  }

  listener {
    name = "listener-1"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [ 9000 ]
    }
    http {
      handler {
        http_router_id = "${yandex_alb_http_router.this.id}"
      }
    }
  }
}