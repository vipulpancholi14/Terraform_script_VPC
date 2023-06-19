resource "aws_vpc" "vipul" {
  cidr_block       = "192.168.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "vipul"
  }
}

#subnet public
resource "aws_subnet" "vipul-sub-public" {
  vpc_id     = aws_vpc.vipul.id
  cidr_block = "192.168.0.0/24"

  tags = {
    Name = "vipul-sub-public"
  }
}

#intergateway public
resource "aws_internet_gateway" "vipul-IGW" {
  vpc_id = aws_vpc.vipul.id

  tags = {
    Name = "vipul-IGW"
  }
}

#subnet-association public
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.vipul-sub-public.id
  route_table_id = aws_route_table.vipul-pub-RTb.id
}

#routetable public
resource "aws_route_table" "vipul-pub-RTb" {
  vpc_id = aws_vpc.vipul.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vipul-IGW.id
  }


  tags = {
    Name = "vipul-pub-RTb"
  }
}

#public subnet public subnet public subnet public subnet public subnet 
#private subnet
# PRIVATE SUBNET
resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.vipul.id
  cidr_block = "192.168.2.0/24"

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
  subnet_id     = aws_subnet.vipul-sub-public.id

  tags = {
    Name = "NAT Gateway "
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.vipul-IGW]
}
# Private ROUTE TABLE
resource "aws_route_table" "private_route" {
  vpc_id = aws_vpc.vipul.id

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
# create securty group
resource "aws_security_group" "vipul-SW" {
  name        = "vipul-SW"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.vipul.id

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.vipul.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "vipul"
  }
}

resource "aws_key_pair" "vipul_key" {
  key_name   = "vishal"
  public_key = file("${path.module}/vipul.pub")

}


resource "aws_instance" "vipulec2" {
  ami                         = "ami-006dcf34c09e50022"
  instance_type               = "t2.micro"
  key_name                    = "vishal"
  subnet_id                   = aws_subnet.vipul-sub-public.id
  vpc_security_group_ids      = [aws_security_group.vipul-SW.id]
  associate_public_ip_address = true


  # Other required parameters
  tags = {
    Name = "vipulec2"
  }

}