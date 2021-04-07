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

resource "aws_security_group" "tomcatVisibility" {
  name = "tomcatVisibility"
  description = "Expose 8080 in the local networks"

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["10.0.0.0/24", "10.0.1.0/24"]
  }

  egress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["10.0.0.0/24", "10.0.1.0/24"]
  }

  tags = {
    purpose = "Expose application request and application response from any ASG instance launched"
  }
}

/*
resource "aws_key_pair" "VirginiaKeyPair" {
  key_name = "VirginiaKeyPair"
}
*/

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
  }

  route {
    cidr_block = "10.1.0/24"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mainGateway.id
  }  

  tags = {
    name = "avanticaRouteTable"
    purpose = "Serv vpc subnets routing : us-east-1a, us-east-1b / internet"
  }
}

resource "aws_route_table_association" "primarySubnetAssocition" {
  subnet_id = aws_subnet.primarySubnet.id 
  gateway_id = aws_internet_gateway.mainGateway.id
  route_table_id = aws_route_table.routeTable.id
}

resource "aws_route_table_association" "secondarySubnetAssociation" {
  subnet_id = aws_subnet.secondarySubnet.id
  gateway_id = aws_internet_gateway.mainGateway.id
  route_table_id = aws_route_table.routeTable.id
}

resource "aws_lb" "avanticaLoadBalancer" {
  name = "avanticaLoadBalancer"
  load_balancer_type = "application"
  internal = false
  enable_deletion_protection = false
  
  security_groups = [aws_security_group.LBVisibility.id]
  subnets = [aws_subnet.primarySubnet.id, aws_subnet.secondarySubnet.id]

  tags = {
    balancedZones = "us-east-1a,us-est-1b"
    targets = "instances"
    regions = "us-east"
  }
}
  
resource "aws_security_group" "LBVisibility" {
  name = "LBVisibility"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["10.0.0.0/24", "10.0.1.0/24"]
  }

  egress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["10.0.0.0/24", "10.0.1.0/24"]
  }

  tags = {
    purpose = "Expose port 80 avanticaLoadBalancer for internet comunication"
  }
}