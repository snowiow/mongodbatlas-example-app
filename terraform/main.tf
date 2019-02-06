provider "aws" {
  region  = "eu-central-1"
  version = "1.54"
}

provider "mongodbatlas" {
  username = "${var.username}"
  api_key  = "${var.api_key}"
}
