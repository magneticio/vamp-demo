output "cluster_endpoint" {
  value = "${google_container_cluster.demo.endpoint}"
}

output "vamp_ip_name" {
  value = "${google_compute_global_address.demo_vamp.name}"
}

output "vamp_ip_address" {
  value = "${google_compute_global_address.demo_vamp.address}"
}

output "vga_ip_name" {
  value = "${google_compute_address.demo_vga.name}"
}

output "vga_ip_address" {
  value = "${google_compute_address.demo_vga.address}"
}