provider "aws" {		
    region= "us-east-1"
    access_key= var.access
    secret_key= var.secret
}

/*terraform {
  backend "s3" {
    bucket = "ctf-ankababu-terraform"
    key    = "statefile/prod"
    region = "us-east-1"
  }
}*/

resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = var.tenancy

  tags = {
    Name = "CT-Ankabau-Pre-Prod"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "CT-Ankababu-Pre-Prod"
  }
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.sub_cidr
  map_public_ip_on_launch= true
  availability_zone= var.azn

  tags = {
    Name = "CT-Ankababu-Pre-Prod-psub1"
  }
}

resource "aws_route_table" "r" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }


  tags = {
    Name = "CT-Ankababu-Pre-Prod-Rt"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.r.id
}

resource "aws_security_group" "allow_tls" {
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "CT-Ankababu-Sg-4"
  }
}
