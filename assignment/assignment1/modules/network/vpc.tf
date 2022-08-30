locals {
  max_subnet_length = max(
    length(var.private_subnets)
  )
}

data "aws_availability_zones" "available" {}

resource "aws_vpc" "vpc" {
  instance_tenancy                 = "default"
  enable_dns_hostnames             = true
  enable_dns_support               = true

  tags = {
    Name        = "${var.env}-vpc"
    Environment = "${var.env}"
    Department  = "CWP"
  }
}



################################################################################
# Public subnet
################################################################################

resource "aws_subnet" "public" {
  count = length(var.public_subnets) > 0 ? length(var.public_subnets) : 0

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = element(concat(var.public_subnets, [""]), count.index)
  availability_zone       = length(regexall("^[a-z]{2}-", element(data.aws_availability_zones.available.names, count.index))) > 0 ? element(data.aws_availability_zones.available.names, count.index) : null
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.env}-public-subnet-${element(data.aws_availability_zones.available.names, count.index)}"
    Environment = "${var.env}"
    Department  = "CWP"
  }

  lifecycle {
    ignore_changes = [
      availability_zone, tags
    ]
  }
}

################################################################################
# Private subnet
################################################################################

resource "aws_subnet" "private" {
  count = length(var.private_subnets) > 0 ? length(var.private_subnets) : 0

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = length(regexall("^[a-z]{2}-", element(data.aws_availability_zones.available.names, count.index))) > 0 ? element(data.aws_availability_zones.available.names, count.index) : null

  tags = {
    Name        = "${var.env}-private-subnet-${element(data.aws_availability_zones.available.names, count.index)}"
    Environment = "${var.env}"
    Department  = "CWP"
  }

  lifecycle {
    ignore_changes = [
      availability_zone, tags
    ]
  }
}


################################################################################
# Route table association
################################################################################

resource "aws_route_table_association" "private" {
  count = length(var.private_subnets) > 0 ? length(var.private_subnets) : 0

  subnet_id = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(
    aws_route_table.private.*.id,
    var.single_nat_gateway ? 0 : count.index,
  )
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnets) > 0 ? length(var.public_subnets) : 0

  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public[0].id
}

################################################################################
# Publiс routes
################################################################################

resource "aws_route_table" "public" {
  count  = length(var.public_subnets) > 0 ? 1 : 0
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "${var.env}-public-route-table-${element(data.aws_availability_zones.available.names, count.index)}"
    Environment = "${var.env}"
    Department  = "CWP"
  }
}

################################################################################
# Private routes
# There are as many routing tables as the number of NAT gateways
################################################################################

resource "aws_route_table" "private" {
  count  = local.max_subnet_length > 0 ? local.nat_gateway_count : 0
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "${var.env}-private-route-table-${element(data.aws_availability_zones.available.names, count.index)}"
    Environment = "${var.env}"
    Department  = "CWP"
  }
}


################################################################################
# Security Group
################################################################################

resource "aws_security_group" "security_group" {
  name   = "${var.env}-security-group"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.env}-security-group"
    Environment = "${var.env}"
    Department  = "CWP"
  }
}

################################################################################
# Secondary Private subnet0
################################################################################

resource "aws_subnet" "private_subnets0" {
  count = length(var.private_subnets0) > 0 ? length(var.private_subnets0) : 0

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnets0[count.index]
  availability_zone = length(regexall("^[a-z]{2}-", element(data.aws_availability_zones.available.names, count.index))) > 0 ? element(data.aws_availability_zones.available.names, count.index) : null

  tags = {
    Name        = "${var.env}-private-subnet-${element(data.aws_availability_zones.available.names, count.index)}"
    Environment = "${var.env}"
  }
  depends_on = [
    aws_vpc_ipv4_cidr_block_association.secondary_cidr
  ]
}

resource "aws_route_table_association" "private_subnets0" {
  count = length(var.private_subnets0) > 0 ? length(var.private_subnets0) : 0

  subnet_id = element(aws_subnet.private_subnets0.*.id, count.index)
  route_table_id = element(
    aws_route_table.private.*.id,
    var.single_nat_gateway ? 0 : count.index,
  )
  depends_on = [
    aws_subnet.private_subnets0
  ]
}

################################################################################
# Secondary Private subnet1
################################################################################

resource "aws_subnet" "private_subnets1" {
  count = length(var.private_subnets1) > 0 ? length(var.private_subnets1) : 0

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnets1[count.index]
  availability_zone = length(regexall("^[a-z]{2}-", element(data.aws_availability_zones.available.names, count.index))) > 0 ? element(data.aws_availability_zones.available.names, count.index) : null

  tags = {
    Name        = "${var.env}-private-subnet-${element(data.aws_availability_zones.available.names, count.index)}"
    Environment = "${var.env}"
  }

  depends_on = [
    aws_vpc_ipv4_cidr_block_association.secondary_cidr
  ]
}

resource "aws_route_table_association" "private_subnets1" {
  count = length(var.private_subnets1) > 0 ? length(var.private_subnets1) : 0

  subnet_id = element(aws_subnet.private_subnets1.*.id, count.index)
  route_table_id = element(
    aws_route_table.private.*.id,
    var.single_nat_gateway ? 0 : count.index,
  )
  depends_on = [
    aws_subnet.private_subnets1
  ]
}
