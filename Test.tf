    terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-south-1"
}

resource "aws_vpc" "MyVPC" {
    cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "CliVPC-1"
  }
}

resource "aws_subnet" "MySUB" {
  vpc_id     = aws_vpc.MyVPC.id
  availability_zone = "ap-south-1a"
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "CliSUB"
  }
}

resource "aws_internet_gateway" "MyIGW" {
  vpc_id = aws_vpc.MyVPC.id

  tags = {
    Name = "CliIGW"
  }
}

resource "aws_route_table" "MyRoute" {
  vpc_id = aws_vpc.MyVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.MyIGW.id
  }

    tags = {
    Name = "CliRoute"
  }
}

resource "aws_route_table_association" "MySubnetAssio" {
  subnet_id      = aws_subnet.MySUB.id
  route_table_id = aws_route_table.MyRoute.id
}

resource "aws_security_group" "MySGPort" {
  name        = "MySGPort"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.MyVPC.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
     }

 ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "Cli_SG"
  }
}

resource "aws_instance" "Myinstan" {
  ami         = "ami-0a3277ffce9146b74" # ap-south-1
  instance_type = "t2.micro"
  availability_zone = "ap-south-1a"
  subnet_id = aws_subnet.MySUB.id
  key_name = "Key-1"
  associate_public_ip_address = true

  tags = {
    Name = "CliEc2"
  }
}





