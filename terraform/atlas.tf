resource "mongodbatlas_project" "this" {
  org_id = "${var.org_id}"
  name   = "example-project"
}

resource "mongodbatlas_container" "this" {
  group            = "${mongodbatlas_project.this.id}"
  atlas_cidr_block = "10.0.0.0/21"
  provider_name    = "AWS"
  region           = "EU_CENTRAL_1"
}

resource "mongodbatlas_cluster" "this" {
  name                  = "example"
  group                 = "${mongodbatlas_project.this.id}"
  mongodb_major_version = "4.0"
  provider_name         = "AWS"
  region                = "EU_CENTRAL_1"
  size                  = "M10"
  disk_gb_enabled       = true
  backup                = false
  depends_on            = ["mongodbatlas_container.this"]
}

resource "mongodbatlas_database_user" "this" {
  username = "application-user"
  password = "application-pw"
  database = "admin"
  group    = "${mongodbatlas_project.this.id}"

  roles {
    name     = "readWrite"
    database = "app"
  }
}

resource "mongodbatlas_vpc_peering_connection" "this" {
  group                  = "${mongodbatlas_project.this.id}"
  aws_account_id         = "${var.aws_account_id}"
  vpc_id                 = "${aws_vpc.this.id}"
  route_table_cidr_block = "${aws_vpc.this.cidr_block}"
  container_id           = "${mongodbatlas_container.this.id}"
}

resource "aws_vpc_peering_connection_accepter" "this" {
  vpc_peering_connection_id = "${mongodbatlas_vpc_peering_connection.this.connection_id}"
  auto_accept               = true
}

resource "aws_route" "mongodb" {
  route_table_id            = "${aws_route_table.this.id}"
  destination_cidr_block    = "${mongodbatlas_container.this.atlas_cidr_block}"
  vpc_peering_connection_id = "${mongodbatlas_vpc_peering_connection.this.connection_id}"
}

resource "mongodbatlas_ip_whitelist" "this" {
  group      = "${mongodbatlas_project.this.id}"
  cidr_block = "${aws_vpc.this.cidr_block}"
  comment    = "Whitelist for the AWS VPC"
}
