provider "aws" {
  region = "us-west-1"
}


resource "aws_vpc" "2048" {
  cidr_block = "10.16.0.0/16"

  tags {
    Name = "2048-Game-VPC"
  }
}



# subnets 
resource "aws_subnet" "2048-public-1" {
  vpc_id            = "${aws_vpc.2048.id}"
  availability_zone = "us-west-1a"

  cidr_block = "10.16.31.0/24"

  tags {
    Name = "2048-public-subnet-1"
  }
}

resource "aws_subnet" "2048-public-2" {
  vpc_id            = "${aws_vpc.2048.id}"
  availability_zone = "us-west-1c"

  cidr_block = "10.16.32.0/24"

  tags {
    Name = "2048-public-subnet-2"
  }
}

resource "aws_subnet" "2048-private-1" {
  availability_zone = "us-west-1c"
  vpc_id            = "${aws_vpc.2048.id}"
  cidr_block        = "10.16.33.0/24"

  tags {
    Name = "2048-private-subnet-1"
  }
}


resource "aws_subnet" "2048-private-2" {
  availability_zone = "us-west-1a"
  vpc_id            = "${aws_vpc.2048.id}"
  cidr_block        = "10.16.34.0/24"

  tags {
    Name = "2048-private-subnet-2"
  }
}









# internet gateway for public subnet
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.2048.id}"

  tags {
    Name = "2048-internet-gw"
  }
}




# nat gateway in public subnet
resource "aws_eip" "nat-1" {
  vpc = true

  tags {
    Name = "2048-nat-gateway-1-eip"
  }
}


resource "aws_nat_gateway" "gw-1" {
  allocation_id = "${aws_eip.nat-1.id}"
  subnet_id     = "${aws_subnet.2048 - public-1.id}"

  tags {
    Name = "nat-gateway-1"
  }
}


resource "aws_eip" "nat-2" {
  vpc = true

  tags {
    Name = "2048-nat-gateway-2-eip"
  }
}


resource "aws_nat_gateway" "gw-2" {
  allocation_id = "${aws_eip.nat-2.id}"
  subnet_id     = "${aws_subnet.2048 - public-2.id}"

  tags {
    Name = "nat-gateway-2"
  }
}



# private subnet routing table and routes
resource "aws_route_table" "private-r-1" {
  vpc_id = "${aws_vpc.2048.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.gw-1.id}"
  }

  tags {
    Name = "2048-private-routing-table-1"
  }
}

resource "aws_route_table_association" "private-r-1" {
  subnet_id      = "${aws_subnet.2048 - private-1.id}"
  route_table_id = "${aws_route_table.private-r-1.id}"
}

resource "aws_route_table" "private-r-2" {
  vpc_id = "${aws_vpc.2048.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.gw-2.id}"
  }

  tags {
    Name = "2048-private-routing-table-2"
  }
}

resource "aws_route_table_association" "private-r-2" {
  subnet_id      = "${aws_subnet.2048 - private-2.id}"
  route_table_id = "${aws_route_table.private-r-2.id}"
}



# public subnet routing table and routes
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.2048.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags {
    Name = "2048-public-subnet-routing-table"
  }
}


resource "aws_route_table_association" "public-1" {
  subnet_id      = "${aws_subnet.2048 - public-1.id}"
  route_table_id = "${aws_route_table.public.id}"
}


resource "aws_route_table_association" "public-2" {
  subnet_id      = "${aws_subnet.2048 - public-2.id}"
  route_table_id = "${aws_route_table.public.id}"
}

