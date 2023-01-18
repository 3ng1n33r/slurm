output "private_ip" {
  value = yandex_compute_instance_group.this.instances.*.network_interface.0.ip_address
}
output "lb_ip_address" {
  value = yandex_alb_load_balancer.this.listener.*.endpoint[0].*.address[0].*.external_ipv4_address[0].*.address[0]
}