// VPC
resource "aws_vpc" "main" {
    cidr_block = "10.21.32.0/20"
    enable_dns_hostnames = "true"
    enable_dns_support = "true"
    tags = {
        Name = "wireguard-vpc"
    }
    tags_all = {
        Name = "wireguard-vpc"
    }
}

// Internet Gateway
resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id
    tags = {
      Name = "wireguard-igw"
    }
    tags_all = {
      Name = "wireguard-igw"
    }
}

// Subnet
resource "aws_subnet" "main" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.21.32.0/28"
    tags = {
        Name = "wireguard-subnet"
    }
    tags_all = {
        Name = "wireguard-subnet" 
    }
}

// Routing table
resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id    
    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.main.id
    }   
    tags = {
      Name = "wireguard-rt1"
    }   
    tags_all = {
      Name = "wireguard-rt1"
    }   
}

// Routing table association
resource "aws_route_table_association" "public" {
    subnet_id = aws_subnet.main.id
    route_table_id = aws_route_table.public.id
}