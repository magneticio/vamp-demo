module "gcloud" {
  source = "./gcloud"

  enabled = "${var.cloud == "gcloud"}"

  name = "${var.name}"
}
