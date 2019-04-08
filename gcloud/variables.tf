variable "name" {}

variable "region" {
  default = "europe-west4"
}

variable "project" {
  default = "vamp-177714"
}

variable "credentials" {
  default = "~/.gcloud/vamp-demo.json"
}

variable "enabled" {}
