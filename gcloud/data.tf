data "google_dns_managed_zone" "demo" {
  name        = "${var.dns_zone}"
}
