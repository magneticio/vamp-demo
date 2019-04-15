output "cluster_endpoint" {
  value = "${module.gcloud.cluster_endpoint}"
}

output "vamp_endpoint" {
  value = "${module.gcloud.vamp_endpoint}"
}

output "vamp_ip_name" {
  value = "${module.gcloud.vamp_ip_name}"
}

output "vamp_ip_address" {
  value = "${module.gcloud.vamp_ip_address}"
}

output "vga_ip_name" {
  value = "${module.gcloud.vga_ip_name}"
}

output "vga_ip_address" {
  value = "${module.gcloud.vga_ip_address}"
}