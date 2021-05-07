provider "aws" {
  region = var.awsRegion
}

data "aws_availability_zones" "available" {
  state = "available"
}
##################################################################### Locals #############################################################
locals {
  awsAz1 = var.awsAz1 != null ? var.awsAz1 : data.aws_availability_zones.available.names[0]
  awsAz2 = var.awsAz2 != null ? var.awsAz1 : data.aws_availability_zones.available.names[1]
}
##################################################################### Locals #############################################################

##################################################################### Web App VPC #############################################################
resource "aws_vpc" "WebAppVpc" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name  = "${var.projectPrefix}-WebAppVpc-${random_id.buildSuffix.hex}"
    Owner = var.resourceOwner
  }
}

# Subnets

resource "aws_subnet" "subnetGWLBeAz1" {
  vpc_id            = aws_vpc.WebAppVpc.id
  cidr_block        = "10.1.10.0/24"
  availability_zone = local.awsAz1

  tags = {
    Name  = "${var.projectPrefix}-subnetGWLBeAz1-${random_id.buildSuffix.hex}"
    Owner = var.resourceOwner
  }
}

resource "aws_subnet" "subnetGWLBeAz2" {
  vpc_id            = aws_vpc.WebAppVpc.id
  cidr_block        = "10.1.110.0/24"
  availability_zone = local.awsAz1

  tags = {
    Name  = "${var.projectPrefix}-subnetGWLBeAz2-${random_id.buildSuffix.hex}"
    Owner = var.resourceOwner
  }
}

resource "aws_subnet" "subnetFrontEndAz1" {
  vpc_id            = aws_vpc.WebAppVpc.id
  cidr_block        = "10.1.10.0/24"
  availability_zone = local.awsAz1

  tags = {
    Name  = "${var.projectPrefix}-subnetFrontEndAz1-${random_id.buildSuffix.hex}"
    Owner = var.resourceOwner
  }
}

resource "aws_subnet" "subnetFrontEndAz2" {
  vpc_id            = aws_vpc.WebAppVpc.id
  cidr_block        = "10.1.110.0/24"
  availability_zone = local.awsAz2

  tags = {
    Name  = "${var.projectPrefix}-subnetFrontEndAz2-${random_id.buildSuffix.hex}"
    Owner = var.resourceOwner
  }
}

resource "aws_subnet" "subnetWebAppAz1" {
  vpc_id            = aws_vpc.WebAppVpc.id
  cidr_block        = "10.1.52.0/24"
  availability_zone = local.awsAz1

  tags = {
    Name  = "${var.projectPrefix}-subnetFrontEndAz1-${random_id.buildSuffix.hex}"
    Owner = var.resourceOwner
  }
}
resource "aws_subnet" "subnetWebAppAz2" {
  vpc_id            = aws_vpc.WebAppVpc.id
  cidr_block        = "10.1.152.0/24"
  availability_zone = local.awsAz2

  tags = {
    Name  = "${var.projectPrefix}-subnetFrontEndAz2-${random_id.buildSuffix.hex}"
    Owner = var.resourceOwner
  }
}

# Internet Gateway

resource "aws_internet_gateway" "WebAppVpcIgw" {
  vpc_id = aws_vpc.WebAppVpc.id

  tags = {
    Name  = "${var.projectPrefix}-WebAppVpcIgw-${random_id.buildSuffix.hex}"
    Owner = var.resourceOwner
  }
}

# Route Tables

resource "aws_route_table" "rtWebAppVpc" {
  vpc_id = aws_vpc.WebAppVpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.WebAppVpcIgw.id
  }
  route {
    cidr_block         = "10.0.0.0/8"
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  }
  tags = {
    Name  = "${var.projectPrefix}-rtWebAppVpc-${random_id.buildSuffix.hex}"
    Owner = var.resourceOwner
  }
}

#route table associations

resource "aws_main_route_table_association" "WebAppVpcRtbAssociation" {
  vpc_id         = aws_vpc.WebAppVpc.id
  route_table_id = aws_route_table.rtWebAppVpc.id
}

##################################################################### Web App VPC #############################################################

##################################################################### Security Services VPC #############################################################
##################################################################### Security Services VPC #############################################################
