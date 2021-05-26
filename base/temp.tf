##################################################################### Security Services VPC #############################################################

# VPC

resource "aws_vpc" "WafSvcsVpc" {
  cidr_block = "10.252.0.0/16"
  tags = {
    Name  = "${var.projectPrefix}-WafSvcsVpc-${random_id.buildSuffix.hex}"
    Owner = var.resourceOwner
  }
}

# Subnets

resource "aws_subnet" "subnetTransitGatewaySubnetAz1" {
  vpc_id            = aws_vpc.WafSvcsVpc.id
  cidr_block        = "10.252.1.0/24"
  availability_zone = local.awsAz1

  tags = {
    Name  = "${var.projectPrefix}-subnetTransitGatewaySubnetAz1-${random_id.buildSuffix.hex}"
    Owner = var.resourceOwner
  }
}

resource "aws_subnet" "subnetTransitGatewaySubnetAz2" {
  vpc_id            = aws_vpc.WafSvcsVpc.id
  cidr_block        = "10.252.101.0/24"
  availability_zone = local.awsAz1

  tags = {
    Name  = "${var.projectPrefix}-subnetTransitGatewaySubnetAz2-${random_id.buildSuffix.hex}"
    Owner = var.resourceOwner
  }
}

resource "aws_subnet" "subnetWAFDataPlaneAz1" {
  vpc_id            = aws_vpc.WafSvcsVpc.id
  cidr_block        = "10.252.10.0/24"
  availability_zone = local.awsAz1

  tags = {
    Name  = "${var.projectPrefix}-subnetWAFDataPlaneAz1-${random_id.buildSuffix.hex}"
    Owner = var.resourceOwner
  }
}

resource "aws_subnet" "subnetWAFDataPlaneAz2" {
  vpc_id            = aws_vpc.WafSvcsVpc.id
  cidr_block        = "10.252.110.0/24"
  availability_zone = local.awsAz2

  tags = {
    Name  = "${var.projectPrefix}-subnetWAFDataPlaneAz2-${random_id.buildSuffix.hex}"
    Owner = var.resourceOwner
  }
}

resource "aws_subnet" "subnetNATGatewayAz1" {
  vpc_id            = aws_vpc.WafSvcsVpc.id
  cidr_block        = "10.252.20.0/24"
  availability_zone = local.awsAz1

  tags = {
    Name  = "${var.projectPrefix}-subnetNATGatewayAz1-${random_id.buildSuffix.hex}"
    Owner = var.resourceOwner
  }
}
resource "aws_subnet" "subnetNATGatewayAz2" {
  vpc_id            = aws_vpc.WafSvcsVpc.id
  cidr_block        = "10.252.120.0/24"
  availability_zone = local.awsAz2

  tags = {
    Name  = "${var.projectPrefix}-subnetNATGatewayAz2-${random_id.buildSuffix.hex}"
    Owner = var.resourceOwner
  }
}

# Internet Gateway

resource "aws_internet_gateway" "WafSvcsVpcIgw" {
  vpc_id = aws_vpc.WafSvcsVpc.id

  tags = {
    Name  = "${var.projectPrefix}-WafSvcsVpcIgw-${random_id.buildSuffix.hex}"
    Owner = var.resourceOwner
  }
}

# Route Tables

resource "aws_route_table" "rtWafSvcsVpc" {
  vpc_id = aws_vpc.WafSvcsVpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.WafSvcsVpcIgw.id
  }
  tags = {
    Name  = "${var.projectPrefix}-rtWafSvcsVpc-${random_id.buildSuffix.hex}"
    Owner = var.resourceOwner
  }
}

#route table associations

resource "aws_main_route_table_association" "WafSvcsVpcRtbAssociation" {
  vpc_id         = aws_vpc.WafSvcsVpc.id
  route_table_id = aws_route_table.rtWafSvcsVpc.id
}

#nat gatewaty

resource "aws_eip" "SecSvcsNatgwAz1Eip" {
  vpc = true
  tags = {
    Name  = "${var.projectPrefix}-SecSvcsNatgwAz1Eip-${random_id.buildSuffix.hex}"
    Owner = var.resourceOwner
  }
}

resource "aws_eip" "SecSvcsNatgwAz2Eip" {
  vpc = true
  tags = {
    Name  = "${var.projectPrefix}-SecSvcsNatgwAz2Eip-${random_id.buildSuffix.hex}"
    Owner = var.resourceOwner
  }
}

resource "aws_nat_gateway" "SecSvcsNatgwAz1" {
  allocation_id = aws_eip.internetVpcNatgwAz1Eip.id
  subnet_id     = aws_subnet.subnetInternetNatgAz1.id
}

resource "aws_nat_gateway" "internetVpcNatgwAz2" {
  allocation_id = aws_eip.internetVpcNatgwAz2Eip.id
  subnet_id     = aws_subnet.subnetInternetNatgAz2.id
}



##################################################################### Security Services VPC #############################################################
