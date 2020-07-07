/*
  Database Servers
*/
resource "aws_security_group" "db" {
  name        = "vpc_db"
  description = "Allow incoming database connections."

  ingress {
    from_port = 1433 # SQL Server

    to_port         = 1433
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }
  ingress {
    from_port = 3306 # MySQL

    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.vpc_cidr]
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

  vpc_id = aws_vpc.jmtest.id

  tags = {
    Name = "DBServerSG"
  }
}

resource "aws_instance" "db-1" {
  ami                    = "ami-0a54aef4ef3b5f881"
  availability_zone      = "us-east-2a"
  instance_type          = "t2.micro"
  key_name               = var.aws_key_name
  vpc_security_group_ids = [aws_security_group.db.id]
  subnet_id              = aws_subnet.db_subnet.id
  source_dest_check      = false

  tags = {
    Name = "DB Server 1"
  }
}
resource "aws_instance" "db-2" {
  ami                    = "ami-0a54aef4ef3b5f881"
  availability_zone      = "us-east-2a"
  instance_type          = "t2.micro"
  key_name               = var.aws_key_name
  vpc_security_group_ids = [aws_security_group.db.id]
  subnet_id              = aws_subnet.db_subnet.id
  source_dest_check      = false

  tags = {
    Name = "DB Server 2"
  }
}
/*
  Application Servers
*/
resource "aws_security_group" "app" {
  name        = "vpc_app"
  description = "Allow incoming application connections."

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.vpc_cidr]
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

  vpc_id = aws_vpc.jmtest.id

  tags = {
    Name = "AppServerSG"
  }
}

resource "aws_instance" "app-1" {
  ami                    = "ami-0a54aef4ef3b5f881"
  availability_zone      = "us-east-2a"
  instance_type          = "t2.micro"
  key_name               = var.aws_key_name
  vpc_security_group_ids = [aws_security_group.app.id]
  subnet_id              = aws_subnet.app_subnet.id
  source_dest_check      = false

  tags = {
    Name = "App Server 1"
  }
}
resource "aws_instance" "app-2" {
  ami                    = "ami-0a54aef4ef3b5f881"
  availability_zone      = "us-east-2a"
  instance_type          = "t2.micro"
  key_name               = var.aws_key_name
  vpc_security_group_ids = [aws_security_group.app.id]
  subnet_id              = aws_subnet.app_subnet.id
  source_dest_check      = false

  tags = {
    Name = "App Server 2"
  }
}

# Create a new load balancer
resource "aws_lb" "app-lb" {
  name               = "app-lb"
  internal           = true
  load_balancer_type = "network"
  subnets            = ["${aws_subnet.app_subnet.id}"]

  tags = {
    Environment = "production"
  }
}
resource "aws_lb" "web-lb" {
  name               = "web-lb"
  internal           = true
  load_balancer_type = "network"
  subnets            = ["${aws_subnet.web_subnet.id}"]

  tags = {
    Environment = "production"
  }
}
