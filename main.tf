provider "aws" {
region = "YOURREGION"
access_key = "YOURACCESSKEY"
secret_key = "YOURSECRETKEY"
}



resource "aws_vpc" "YOURVPCNAME" {
  cidr_block        = "127.0.0.0/24"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "New vpc 3 tier stack"}
}

  
