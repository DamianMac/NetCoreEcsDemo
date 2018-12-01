resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_security_group" "allow_postgres" {
  name        = "allow_postgres"
  description = "Allow postgres inbound traffic"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_route_table" "external" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }
}

resource "aws_route_table_association" "external-main" {
  subnet_id      = "${aws_subnet.main.id}"
  route_table_id = "${aws_route_table.external.id}"
}

resource "aws_route_table_association" "external-secondary" {
  subnet_id      = "${aws_subnet.secondary.id}"
  route_table_id = "${aws_route_table.external.id}"
}

resource "aws_subnet" "main" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.az1}"

  tags {
    Name = "main_subnet1"
  }
}

resource "aws_subnet" "secondary" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.az2}"

  tags {
    Name = "main_subnet2"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_security_group" "load_balancers" {
  name        = "load_balancers"
  description = "Allows all traffic"
  vpc_id      = "${aws_vpc.main.id}"

  # TODO: do we need to allow ingress besides TCP 80 and 443?
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # TODO: this probably only needs egress to the ECS security group.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecs-staging" {
  name        = "ecs-staging"
  description = "Allows all traffic"
  vpc_id      = "${aws_vpc.main.id}"

  # TODO: remove this and replace with a bastion host for SSHing into
  # individual machines.
  ingress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }

    lifecycle {
    create_before_destroy = true
  }

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = ["${aws_security_group.load_balancers.id}"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
