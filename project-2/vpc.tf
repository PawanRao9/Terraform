resource "aws_vpc" "My_VPC" {
  cidr_block = "10.0.0.0/16"

  tags = {
    "name" = My_VPC
  }
}

resource "aws_subnet" "public_subnet" {
  cidr_block = "10.0.1.0/24"
  vpc_id     = aws_vpc.My_VPC.id

  tags = {
    "name" = public_subnet
  }
}

resource "aws_subnet" "private_subnet" {
  cidr_block = "10.0.2.0/24"
  vpc_id     = aws_vpc.My_VPC.id

  tags = {
    "name" = private_subnet
  }
}

resource "aws_internet_gateway" "my-igw" {
  vpc_id = aws_vpc.My_VPC.id
  tags = {
    "name" = my-igw
  }
}

resource "aws_route_table" "my-rt" {
  vpc_id = aws_vpc.My_VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-igw.id
  }
}

resource "aws_route_table_association" "public_sub" {
  route_table_id = aws_route_table.my-rt.id
  subnet_id      = aws_subnet.public_subnet.id

}
