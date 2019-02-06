resource "aws_vpc" "this" {
  cidr_block = "172.16.0.0/16"

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc"
  }
}

resource "aws_subnet" "this" {
  cidr_block = "172.16.0.0/16"
  vpc_id     = "${aws_vpc.this.id}"

  map_public_ip_on_launch = true
  availability_zone       = "eu-central-1a"

  tags = {
    Name = "subnet1"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = "${aws_vpc.this.id}"

  tags = {
    Name = "internet-gateway"
  }
}

resource "aws_route_table" "this" {
  vpc_id = "${aws_vpc.this.id}"

  tags = {
    Name = "route-table-public"
  }
}

resource "aws_route" "this" {
  route_table_id         = "${aws_route_table.this.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.this.id}"
}

resource "aws_route_table_association" "this" {
  route_table_id = "${aws_route_table.this.id}"
  subnet_id      = "${aws_subnet.this.id}"
}
