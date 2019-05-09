provider "google" {
  project = "${var.project}"
  region  = "${var.region}"
}

resource "google_container_cluster" "demo" {
  name     = "${var.name}"
  location = "${var.region}"

  remove_default_node_pool = true
  initial_node_count       = 3

  # Setting an empty username and password explicitly disables basic auth
  master_auth {
    username = ""
    password = ""
  }

  node_config {
    preemptible  = true
    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}

resource "google_container_node_pool" "primary" {
  name               = "${var.name}-primary"
  location           = "${var.region}"
  cluster            = "${google_container_cluster.demo.name}"
  node_count         = 2

  node_config {
    preemptible  = true
    machine_type = "n1-standard-2"

    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}

resource "google_compute_address" "demo_vamp" {
  name = "${var.name}-vamp"
}

resource "google_compute_address" "demo_vga" {
  name = "${var.name}-vga"
}

resource "google_dns_record_set" "demo_vamp" {
  name = "${var.name}.${data.google_dns_managed_zone.demo.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = "${data.google_dns_managed_zone.demo.name}"

  rrdatas = ["${google_compute_address.demo_vamp.address}"]
}

resource "google_dns_record_set" "demo_vga" {
  name = "*.${var.name}.${data.google_dns_managed_zone.demo.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = "${data.google_dns_managed_zone.demo.name}"

  rrdatas = ["${google_compute_address.demo_vga.address}"]
}
