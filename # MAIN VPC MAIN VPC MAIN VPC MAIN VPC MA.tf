# MAIN VPC MAIN VPC MAIN VPC MAIN VPC MAIN VPC MAIN VPC MAIN VPC MAIN VPC MAIN VPC
# MAIN VPC MAIN VPC MAIN VPC MAIN VPC MAIN VPC MAIN VPC MAIN VPC MAIN VPC MAIN VPC 

resource "aws_vpc" "main_vpc" {
  cidr_block       = "105.106.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "Main_VPC"
  }
}

# PUBLIC SUBNET
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "105.106.1.0/24"

  tags = {
    Name = "Public_subnet"
  }
}
#  INTERNET GATEWAY
resource "aws_internet_gateway" "internet" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "Internet_Gateway"
  }
}
# ROUTE TABLE
resource "aws_route_table" "route" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet.id
  }
  tags = {
    Name = "Public_Route_Table"
  }
}
resource "aws_route_table_association" "route_table_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.route.id
}

# PRIVATE SUBNET PRIVATE SUBNET PRIVATE SUBNET PRIVATE SUBNET PRIVATE SUBNET PRIVATE SUBNET
# PRIVATE SUBNET PRIVATE SUBNET PRIVATE SUBNET PRIVATE SUBNET PRIVATE SUBNET PRIVATE SUBNET 

# PRIVATE SUBNET
resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "105.106.2.0/24"

  tags = {
    Name = "Private_subnet"
  }
}

# Elastic Ip
resource "aws_eip" "lb" {
  vpc = true
  tags = {
    "Name" = "Private_Elastic_IP"
  }
}

#  NAT GATEWAY
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.lb.id
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = "NAT Gateway "
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.internet]
}
# Private ROUTE TABLE
resource "aws_route_table" "private_route" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }
  tags = {
    Name = "Private_Route_Table"
  }
}
resource "aws_route_table_association" "private_route_table_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route.id
}

# Security Group Security Group Security Group Security Group Security Group Security Group 


resource "aws_security_group" "ssh-security-group" {
  name        = "SSH Security Group"
  description = "Enable SSH access on Port 22"
  vpc_id      = aws_vpc.main_vpc.id
  ingress {
    description = "SSH Access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main_vpc.cidr_block]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "SSH Security Group"
  }
}


# EC2 Instance EC2 Instance EC2 Instance EC2 Instance EC2 Instance EC2 Instance EC2 Instance 
# EC2 Instance EC2 Instance EC2 Instance EC2 Instance EC2 Instance EC2 Instance EC2 Instance 

resource "aws_instance" "Jerry-EC2" {
  ami           = "ami-0557a15b87f6559cf"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.ssh-security-group.id]
  # Other required parameters
}