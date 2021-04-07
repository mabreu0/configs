provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "avantvpc"  {
  cidr_block = "10.0.0.0/24"
  instance_tenancy = "default"
  enable_dns_support = "false"
  #region = "us-east-1"

  tags = {
    name = "MainVPC",
    purpose = "AvanticaLab Private Network APN"
  }
}

resource "aws_key_pair" "VirginiaKeyPair" {
  key_name = "VirginiaKeyPair"
}

resource "aws_subnet" "primarySubnet" {
  vpc_id = aws_vpc.avantvpc.id

  cidr_block = "10.0.0.0/24"
  assign_ipv6_address_on_creation = false

  tags = {
    theRegion = "us-east-1"
    theZone = "us-east-1a"
  }
}

resource "aws_subnet" "secondarySubnet" {
  vpc_id = aws_vpc.avantvpc.id

  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = false
  assign_ipv6_address_on_creation = false

  tags = {
    theRegion = "us-east-1"
    theZone = "us-east-1b"
  }
}

resource "aws_internet_gateway" "mainGateway"  {
  vpc_id = aws_vpc.avantvpc.id
}

resource "aws_route_table" "routeTable" {
  vpc_id = aws_vpc.avantvpc.id

  route {
    cidr_block = "10.0.0/24"
    //gateway_id = aws_vpc.avantvpc.gateway_id

    gateway_id = aws_internet_gateway.mainGateway.id
    #gateway_id = aws.internet
  }

  route {
    cidr_block = "10.0.1.0/24"
    gateway_id = aws_internet_gateway.mainGateway.id
  }

  tags = {
    name = "avanticaRouteTable"
    purpose = "Serv vpc subnets routing : us-east-1a, us-east-1b"
  }


}