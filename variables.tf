variable "aws_access_key" {
  description = "access key for AWS account"
}

variable "aws_secret_key" {
  description = "secret key for AWS account"
}

variable "aws_key_path" {
}

variable "aws_key_name" {
}

variable "aws_region" {
  description = "EC2 Region for the VPC"
  default     = "us-east-2"
}

variable "amis" {
  description = "AMIs by region"
  default = {
    us-east-2 = "ami-0a54aef4ef3b5f881" # red hat 8
  }
}

variable "vpc_cidr" {
  description = "CIDR for the whole VPC"
  default     = "10.0.0.0/22"
}

variable "web_subnet_cidr" {
  description = "CIDR for the web Subnet"
  default     = "10.0.1.0/24"
}

variable "db_subnet_cidr" {
  description = "CIDR for the DB Subnet"
  default     = "10.0.3.0/24"
}
variable "app_subnet_cidr" {
  description = "CIDR for the App Subnet"
  default     = "10.0.2.0/25"
}
variable "bastion_subnet_cidr" {
  description = "CIDR for the Bastion Subnet"
  default     = "10.0.2.128/25"
}
