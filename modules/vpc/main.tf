data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "oik8s_vpc" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.env_name}-${var.vpc_name}"
  }
}

resource "aws_internet_gateway" "oik8s_igw" {
  vpc_id = aws_vpc.oik8s_vpc.id

  tags = {
    Name = "${var.env_name}-oik8s-igw"
  }
}

# Create Public Subnets
resource "aws_subnet" "public_subnet" {
  for_each = toset(data.aws_availability_zones.available.names)

  vpc_id = aws_vpc.oik8s_vpc.id
  # Logic: Take VPC CIDR, add 8 bits, and offset by the index of the zone
  cidr_block              = cidrsubnet(aws_vpc.oik8s_vpc.cidr_block, 8, index(data.aws_availability_zones.available.names, each.value))
  availability_zone       = each.value
  map_public_ip_on_launch = true

  tags = {
    # substr(string, -1, 1) grabs the last character
    Name = "${var.env_name}-oik8s-public-subnet-${substr(each.value, -1, 1)}"
  }
}

# Create Private Subnets
resource "aws_subnet" "private_subnet" {
  for_each = toset(data.aws_availability_zones.available.names)

  vpc_id = aws_vpc.oik8s_vpc.id
  # Logic: Offset by +100 to ensure private ranges don't hit public ranges
  cidr_block        = cidrsubnet(aws_vpc.oik8s_vpc.cidr_block, 8, index(data.aws_availability_zones.available.names, each.value) + 100)
  availability_zone = each.value

  tags = {
    Name = "${var.env_name}-oik8s-private-subnet-${substr(each.value, -1, 1)}"
  }
}

# Default Private Route Table
resource "aws_default_route_table" "oik8s_private_rt" {
  default_route_table_id = aws_vpc.oik8s_vpc.default_route_table_id

  tags = {
    Name = "${var.env_name}-oik8s-private-rt"
  }
}

# Associate all Private Subnets with the Default Route Table which is private
resource "aws_route_table_association" "private-rt-association" {
  for_each = aws_subnet.private_subnet

  subnet_id      = each.value.id
  route_table_id = aws_vpc.oik8s_vpc.default_route_table_id
}

# Public Route Table
resource "aws_route_table" "oik8s_public_rt" {
  vpc_id = aws_vpc.oik8s_vpc.id

  # This route sends all non-local traffic to the Internet Gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.oik8s_igw.id
  }

  tags = {
    Name = "${var.env_name}-oik8s-public-rt"
  }
}

# Explicitly associate all Public Subnets
resource "aws_route_table_association" "public-rt-association" {
  # We loop through the existing public_subnet resource map
  for_each = aws_subnet.public_subnet

  subnet_id      = each.value.id
  route_table_id = aws_route_table.oik8s_public_rt.id
}


resource "aws_default_security_group" "oik8s_default_sg" {
  vpc_id = aws_vpc.oik8s_vpc.id

  # Inbound: Allow SSH
  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound: Allow Kubernetes API Server
  ingress {
    protocol    = "tcp"
    from_port   = 6443
    to_port     = 6443
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound: Allow everything to everywhere
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env_name}-oik8s-default-sg-restricted"
  }
}

## Create an Elastic IP for the NAT Gateway
#resource "aws_eip" "oik8s_nat_eip" {
#  domain = "vpc"
#
#  tags = {
#    Name = "oik8s-nat-eip"
#  }
#}
#
## Create the NAT Gateway
#resource "aws_nat_gateway" "oik8s_nat_gw" {
#  vpc_id            = aws_vpc.oik8s_vpc.id
#  connectivity_type = "public"
#  availability_mode = "regional"
#
#  tags = {
#    Name = "oik8s-regional-nat-gw"
#  }
#
#  # To ensure proper ordering, it must wait for the IGW
#  depends_on = [aws_internet_gateway.oik8s_igw]
#}
#
## Create a route in your existing private route table
#resource "aws_route" "private_internet_access" {
#  # Link it to your previously created private route table
#  route_table_id = aws_default_route_table.oik8s_private_rt.id
#
#  # The destination is the entire internet
#  destination_cidr_block = "0.0.0.0/0"
#
#  # The target is your Regional NAT Gateway
#  nat_gateway_id = aws_nat_gateway.oik8s_nat_gw.id
#}