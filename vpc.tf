resource "aws_vpc" "jmtest" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name = "terraform-aws-vpc"
  }
}

resource "aws_internet_gateway" "jmtest" {
  vpc_id = aws_vpc.jmtest.id
}

/*
  NAT Instance
*/
resource "aws_security_group" "bastion" {
  name        = "vpc_bastion"
  description = "Allow SSH traffic to pass from the private subnet to the app and web subnets"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.bastion_subnet_cidr]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.bastion_subnet_cidr]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
  egress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = aws_vpc.jmtest.id

  tags = {
    Name = "Bastion SG"
  }
}

resource "aws_instance" "bastion" {
  ami                         = "ami-0a54aef4ef3b5f881" # this is a special ami preconfigured to do NAT
  availability_zone           = "us-east-2a"
  instance_type               = "t2.micro"
  key_name                    = var.aws_key_name
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  subnet_id                   = aws_subnet.web_subnet.id
  associate_public_ip_address = true
  source_dest_check           = false

  tags = {
    Name = "VPC Bastion"
  }
}

resource "aws_eip" "bastion" {
  instance = aws_instance.bastion.id
  vpc      = true
}

/*
  web Subnet
*/
resource "aws_subnet" "web_subnet" {
  vpc_id = aws_vpc.jmtest.id

  cidr_block        = var.web_subnet_cidr
  availability_zone = "us-east-2a"

  tags = {
    Name = "Web Subnet"
  }
}

resource "aws_route_table" "web_subnet" {
  vpc_id = aws_vpc.jmtest.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.jmtest.id
  }

  tags = {
    Name = "Web Subnet"
  }
}

resource "aws_route_table_association" "web_subnet" {
  subnet_id      = aws_subnet.web_subnet.id
  route_table_id = aws_route_table.web_subnet.id
}

/*
  Private Subnet
*/
resource "aws_subnet" "app_subnet" {
  vpc_id = aws_vpc.jmtest.id

  cidr_block        = var.app_subnet_cidr
  availability_zone = "us-east-2a"

  tags = {
    Name = "App Subnet"
  }
}

resource "aws_route_table" "app_subnet" {
  vpc_id = aws_vpc.jmtest.id

  route {
    cidr_block  = "0.0.0.0/0"
    instance_id = aws_instance.app-1.id
  }

  tags = {
    Name = "App Subnet Route"
  }
}

resource "aws_route_table_association" "app_subnet" {
  subnet_id      = aws_subnet.app_subnet.id
  route_table_id = aws_route_table.app_subnet.id
}

resource "aws_subnet" "db_subnet" {
  vpc_id = aws_vpc.jmtest.id

  cidr_block        = var.db_subnet_cidr
  availability_zone = "us-east-2a"

  tags = {
    Name = "DB Subnet"
  }
}

resource "aws_route_table" "db_subnet" {
  vpc_id = aws_vpc.jmtest.id

  route {
    cidr_block  = "0.0.0.0/0"
    instance_id = aws_instance.db-1.id
  }

  tags = {
    Name = "DB Subnet Route"
  }
}

resource "aws_route_table_association" "db_subnet" {
  subnet_id      = aws_subnet.db_subnet.id
  route_table_id = aws_route_table.db_subnet.id
}
resource "aws_subnet" "bastion_subnet" {
  vpc_id = aws_vpc.jmtest.id

  cidr_block        = var.bastion_subnet_cidr
  availability_zone = "us-east-2a"

  tags = {
    Name = "Bastion Subnet"
  }
}

resource "aws_route_table" "bastion_subnet" {
  vpc_id = aws_vpc.jmtest.id

  route {
    cidr_block  = "0.0.0.0/0"
    instance_id = aws_instance.bastion.id
  }

  tags = {
    Name = "Bastion Subnet Route"
  }
}

resource "aws_route_table_association" "bastion_subnet" {
  subnet_id      = aws_subnet.bastion_subnet.id
  route_table_id = aws_route_table.bastion_subnet.id
}
