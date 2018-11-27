variable project {
  default = "lab1"
}

resource "aws_vpc" "lab" {
  cidr_block = "10.0.0.0/16"

  tags {
    Name = "lab"
    project = "${var.project}"
  }

}

############## Subnets ############################
resource "aws_subnet" "public" {
  vpc_id = "${aws_vpc.lab.id}"
  cidr_block        = "10.0.100.0/24"
  availability_zone = "eu-west-1a"

  tags {
    Name    = "${var.project}_public_subnet"
    project = "${var.project}"
  }
}

resource "aws_subnet" "private" {
  vpc_id = "${aws_vpc.lab.id}"
  cidr_block        = "10.0.200.0/24"
  availability_zone = "eu-west-1b"

  tags {
    Name    = "${var.project}_private_subnet"
    project = "${var.project}"
  }
}


############### Igw and route ##############################
resource "aws_internet_gateway" "lab" {
  vpc_id = "${aws_vpc.lab.id}"

  tags {
    Name    = "${var.project}_igw"
    project = "${var.project}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.lab.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.lab.id}"
  }

  tags {
    name    = "${var.project}_public_rt"
    project = "${var.project}"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = "${aws_subnet.public.id}"
  route_table_id = "${aws_route_table.public.id}"
}

################ Ngw and route ########################

resource "aws_eip" "ngw" {
  vpc = true
}

resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.ngw.id}"
  subnet_id     = "${aws_subnet.public.id}"
  depends_on    = ["aws_internet_gateway.lab"]
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.lab.id}"
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat.id}"
  }

  tags {
    name    = "${var.project}_private_rt"
    project = "${var.project}"
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = "${aws_subnet.private.id}"
  route_table_id = "${aws_route_table.private.id}"
}
