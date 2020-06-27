provider "aws" {
region = "us-east-2"
access_key = "AKIARBI7EXCQMTST4QVX"
secret_key = "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"
}



resource "aws_vpc" "jmtest" {
  cidr_block        = "127.0.0.0/24"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "My terraform managed vpc"}
}

  
