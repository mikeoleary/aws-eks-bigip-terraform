#
# VPC Resources
#  * VPC
#  * Subnets
#  * Internet Gateway
#  * Route Table
#

resource "aws_vpc" "demo" {
  cidr_block = "${var.vpc_cidr_block}"
  enable_dns_hostnames = true
  tags = "${
    map(
      "Name", "terraform-eks-demo-node",
      "kubernetes.io/cluster/${var.cluster-name}", "shared",
    )
  }"
}

resource "aws_subnet" "public" {
  count                   = 2
  availability_zone       = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block              = "10.0.${count.index}.0/24"
  vpc_id                  = "${aws_vpc.demo.id}"
  map_public_ip_on_launch = true

  tags = "${
    map(
      "Name", "terraform-eks-demo-node",
      "kubernetes.io/cluster/${var.cluster-name}", "shared",
    )
  }"
}
resource "aws_subnet" "private" {
  count = 2
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "10.0.${(count.index+2)}.0/24"
  vpc_id            = "${aws_vpc.demo.id}"
  map_public_ip_on_launch = true

  tags = "${
    map(
      "Name", "terraform-eks-demo-node",
      "kubernetes.io/cluster/${var.cluster-name}", "shared",
    )
  }"
}
resource "aws_subnet" "mgmt" {
  count = 2
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "10.0.${(count.index+4)}.0/24"
  vpc_id            = "${aws_vpc.demo.id}"
  map_public_ip_on_launch = true

  tags = "${
    map(
      "Name", "terraform-eks-demo-node",
      "kubernetes.io/cluster/${var.cluster-name}", "shared",
    )
  }"
}
resource "aws_internet_gateway" "demo" {
  vpc_id = "${aws_vpc.demo.id}"

  tags = {
    Name = "terraform-eks-demo"
  }
}
resource "aws_eip" "natgwA" {
  vpc = true
}
resource "aws_nat_gateway" "natgwA" {
  allocation_id = "${aws_eip.natgwA.id}"
  subnet_id     = "${aws_subnet.private[0].id}"
}
resource "aws_eip" "natgwB" {
  vpc = true
}
resource "aws_nat_gateway" "natgwB" {
  allocation_id = "${aws_eip.natgwB.id}"
  subnet_id     = "${aws_subnet.private[1].id}"
}


resource "aws_route_table" "demo" {
  vpc_id = "${aws_vpc.demo.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.demo.id}"
  }
}
resource "aws_route_table" "privateA" {
  vpc_id = "${aws_vpc.demo.id}"

  route {
    cidr_block = "0.0.0.0/0"
    #gateway_id = "${aws_nat_gateway.natgwA.id}"
    gateway_id = "${aws_internet_gateway.demo.id}"
    
  }
}
resource "aws_route_table" "privateB" {
  vpc_id = "${aws_vpc.demo.id}"

  route {
    cidr_block = "0.0.0.0/0"
    #gateway_id = "${aws_nat_gateway.natgwB.id}"
    gateway_id = "${aws_internet_gateway.demo.id}"
  }
}

resource "aws_route_table_association" "public" {
  count = 2
  subnet_id      = "${aws_subnet.public.*.id[count.index]}"
  route_table_id = "${aws_route_table.demo.id}"
}
resource "aws_route_table_association" "mgmt" {
  count = 2
  subnet_id      = "${aws_subnet.mgmt.*.id[count.index]}"
  route_table_id = "${aws_route_table.demo.id}"
}
resource "aws_route_table_association" "privateA" {
  count = 2
  subnet_id      = "${aws_subnet.private.*.id[0]}"
  route_table_id = "${aws_route_table.privateA.id}"
}
resource "aws_route_table_association" "privateB" {
  count = 2
  subnet_id      = "${aws_subnet.private.*.id[1]}"
  route_table_id = "${aws_route_table.privateB.id}"
}

