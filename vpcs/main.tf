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

##################################################################### Security Services VPC #############################################################

resource "aws_vpc" "securityServicesVPC" {
  cidr_block = "10.250.0.0/16"
  tags = {
    Name  = "${var.projectPrefix}-securityServicesVPC-${random_id.buildSuffix.hex}"
    Owner = var.resourceOwner
  }
}

resource "aws_subnet" "securityServicesSubnetAZ1" {
  vpc_id = aws_vpc.securityServicesVPC.id
  cidr_block = "10.250.150.0/24"
  availability_zone = local.awsAz1
  tags = {
    Name  = "${var.projectPrefix}-securityServicesSubnetAZ1-${random_id.buildSuffix.hex}"
    Owner = var.resourceOwner
  }
}

resource "aws_subnet" "securityServicesSubnetAZ2" {
  vpc_id = aws_vpc.securityServicesVPC.id
  cidr_block = "10.250.250.0/24"
  availability_zone = local.awsAz2
  tags = {
    Name  = "${var.projectPrefix}-securityServicesSubnetAZ2-${random_id.buildSuffix.hex}"
    Owner = var.resourceOwner
  }
}

resource "aws_internet_gateway" "securityServicesIGW" {
  vpc_id = aws_vpc.securityServicesVPC.id
  tags = {
    Name  = "${var.projectPrefix}-securityServicesIGW-${random_id.buildSuffix.hex}"
    Owner = var.resourceOwner
  }
}

resource "aws_route_table" "securityServicesMainRT" {
  vpc_id = aws_vpc.securityServicesVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.securityServicesIGW.id
  }
  tags = {
    Name  = "${var.projectPrefix}-securityServicesMainRT-${random_id.buildSuffix.hex}"
    Owner = var.resourceOwner
  }
}

resource "aws_main_route_table_association" "securityServicesMainRTAssociation" {
  vpc_id         = aws_vpc.securityServicesVPC.id
  route_table_id = aws_route_table.securityServicesMainRT.id
}

/*
#Spoke10 VPC
module "spoke10Vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 2.0"

  name = "${var.projectPrefix}-spoke10Vpc-${random_id.buildSuffix.hex}"

  cidr                               = "10.10.0.0/16"
  azs                                = [local.awsAz1, local.awsAz2]
  database_subnets                   = ["10.10.20.0/24", "10.10.120.0/24"]
  create_database_subnet_group       = false
  create_database_subnet_route_table = true

}

resoure "aws_route" "spoke10VpcDatabaseRtb" {
  route_table_id         = module.spoke10Vpc.database_route_table_ids[0]
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
  depends_on             = [aws_ec2_transit_gateway.tgw]
}
resource "aws_default_route_table" "spoke10VpcDefaultRtb" {
  default_route_table_id = module.spoke10Vpc.default_route_table_id
  route {
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  }
  depends_on = [aws_ec2_transit_gateway.tgw]
}

resource "aws_ec2_transit_gateway_vpc_attachment" "spoke10VpcTgwAttachment" {
  subnet_ids                                      = [module.spoke10Vpc.database_subnets[0], module.spoke10Vpc.database_subnets[1]]
  transit_gateway_id                              = aws_ec2_transit_gateway.tgw.id
  vpc_id                                          = module.spoke10Vpc.vpc_id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  tags = {
    Name  = "${var.projectPrefix}-spoke10VpcTgwAttachment-${random_id.buildSuffix.hex}"
    Owner = var.resourceOwner
  }
  depends_on = [aws_ec2_transit_gateway.tgw]
}

resource "aws_ec2_transit_gateway_route_table_association" "spoke10RtAssociation" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke10VpcTgwAttachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rtTgwIngress.id
}

#Spoke20 VPC
module "spoke20Vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 2.0"

  name = "${var.projectPrefix}-spoke20Vpc-${random_id.buildSuffix.hex}"

  cidr = "10.20.0.0/16"

  azs                                = [local.awsAz1, local.awsAz2]
  database_subnets                   = ["10.20.20.0/24", "10.20.120.0/24"]
  create_database_subnet_group       = false
  create_database_subnet_route_table = true

}

resource "aws_route" "spoke20VpcDatabaseRtb" {
  route_table_id         = module.spoke20Vpc.database_route_table_ids[0]
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
  depends_on             = [aws_ec2_transit_gateway.tgw]
}
resource "aws_default_route_table" "spoke20VpcDefaultRtb" {
  default_route_table_id = module.spoke20Vpc.default_route_table_id
  route {
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  }
  depends_on = [aws_ec2_transit_gateway.tgw]
}

resource "aws_ec2_transit_gateway_vpc_attachment" "spoke20VpcTgwAttachment" {
  subnet_ids                                      = [module.spoke20Vpc.database_subnets[0], module.spoke20Vpc.database_subnets[1]]
  transit_gateway_id                              = aws_ec2_transit_gateway.tgw.id
  vpc_id                                          = module.spoke20Vpc.vpc_id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  tags = {
    Name  = "${var.projectPrefix}-spoke20VpcTgwAttachment-${random_id.buildSuffix.hex}"
    Owner = var.resourceOwner
  }
  depends_on = [aws_ec2_transit_gateway.tgw]
}

resource "aws_ec2_transit_gateway_route_table_association" "spoke20RtAssociation" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke20VpcTgwAttachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rtTgwIngress.id
}


#################################Security Vpc = GWLB and BIGIPs

resource "aws_key_pair" "deployer" {
  key_name   = "${var.projectPrefix}-key-${random_id.buildSuffix.hex}"
  public_key = var.sshPublicKey
}

module "gwlb-bigip" {
  source             = "../../../../modules/aws/terraform/gwlb-bigip-vpc"
  projectPrefix      = var.projectPrefix
  resourceOwner      = var.resourceOwner
  keyName            = aws_key_pair.deployer.id
  buildSuffix        = random_id.buildSuffix.hex
  instanceCount      = 1
  vpcGwlbSubPubACidr = "10.252.10.0/24"
  vpcGwlbSubPubBCidr = "10.252.110.0/24"
  subnetGwlbeAz1     = "10.252.54.0/24"
  subnetGwlbeAz2     = "10.252.154.0/24"
  createGwlbEndpoint = true
}

############subnets
resource "aws_subnet" "securityVpcSubnetTgwAttachmentAz1" {
  vpc_id            = module.gwlb-bigip.vpcs["vpcGwlb"]
  cidr_block        = "10.252.52.0/24"
  availability_zone = local.awsAz1

  tags = {
    Name  = "${var.projectPrefix}-securityVpcSubnetTgwAttachmentAz1-${random_id.buildSuffix.hex}"
    Owner = var.resourceOwner
  }
}

resource "aws_subnet" "securityVpcSubnetTgwAttachmentAz2" {
  vpc_id            = module.gwlb-bigip.vpcs["vpcGwlb"]
  cidr_block        = "10.252.152.0/24"
  availability_zone = local.awsAz2

  tags = {
    Name  = "${var.projectPrefix}-securityVpcSubnetTgwAttachmentAz2-${random_id.buildSuffix.hex}"
    Owner = var.resourceOwner
  }
}

# route tables

resource "aws_route_table" "rtGwlbEndpointSubnets" {
  vpc_id = module.gwlb-bigip.vpcs["vpcGwlb"]

  route {
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  }
  tags = {
    Name  = "${var.projectPrefix}-rtGwlbEndpointSubnets-${random_id.buildSuffix.hex}"
    Owner = var.resourceOwner
  }
}


resource "aws_route_table" "rtTgwAttachmentSubnetAz1" {
  vpc_id = module.gwlb-bigip.vpcs["vpcGwlb"]

  route {
    cidr_block      = "0.0.0.0/0"
    vpc_endpoint_id = module.gwlb-bigip.gwlbeAz1
  }
  tags = {
    Name  = "${var.projectPrefix}-rtTgwAttachmentSubnetAz1-${random_id.buildSuffix.hex}"
    Owner = var.resourceOwner
  }
}
resource "aws_route_table" "rtTgwAttachmentSubnetAz2" {
  vpc_id = module.gwlb-bigip.vpcs["vpcGwlb"]

  route {
    cidr_block      = "0.0.0.0/0"
    vpc_endpoint_id = module.gwlb-bigip.gwlbeAz2
  }
  tags = {
    Name  = "${var.projectPrefix}-rtTgwAttachmentSubnetAz2-${random_id.buildSuffix.hex}"
    Owner = var.resourceOwner
  }
}
# route table association

resource "aws_route_table_association" "GwlbEndpointSubnetAz1RtbAssociation" {
  subnet_id      = module.gwlb-bigip.subnetGwlbeAz1
  route_table_id = aws_route_table.rtGwlbEndpointSubnets.id
}

resource "aws_route_table_association" "GwlbEndpointSubnetAz2RtbAssociation" {
  subnet_id      = module.gwlb-bigip.subnetGwlbeAz2
  route_table_id = aws_route_table.rtGwlbEndpointSubnets.id
}

resource "aws_route_table_association" "TgwAttachmentSubnetAz1RtbAssociation" {
  subnet_id      = aws_subnet.securityVpcSubnetTgwAttachmentAz1.id
  route_table_id = aws_route_table.rtTgwAttachmentSubnetAz1.id
}

resource "aws_route_table_association" "TgwAttachmentSubnetAz2RtbAssociation" {
  subnet_id      = aws_subnet.securityVpcSubnetTgwAttachmentAz2.id
  route_table_id = aws_route_table.rtTgwAttachmentSubnetAz2.id
}



#########Compute
#local for spinning up compute resources
locals {

  vpcs = {

    internetVpcData = {
      vpcId    = aws_vpc.internetVpc.id
      subnetId = aws_subnet.subnetInternetJumphostAz1.id
    }

    spoke10VpcData = {
      vpcId    = module.spoke10Vpc.vpc_id
      subnetId = module.spoke10Vpc.database_subnets[0]
    }
    spoke20VpcData = {
      vpcId    = module.spoke20Vpc.vpc_id
      subnetId = module.spoke20Vpc.database_subnets[0]
    }

  }

}

resource "aws_security_group" "secGroupWorkstation" {
  for_each    = local.vpcs
  name        = "secGroupWorkstation"
  description = "Jumphost workstation security group"
  vpc_id      = each.value["vpcId"]

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5800
    to_port     = 5800
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "${var.projectPrefix}-secGroupWorkstation"
    Owner = var.resourceOwner
  }
}

module "jumphost" {
  for_each      = local.vpcs
  source        = "../../../../modules/aws/terraform/workstation/"
  projectPrefix = var.projectPrefix
  resourceOwner = var.resourceOwner
  vpc           = each.value["vpcId"]
  keyName       = aws_key_pair.deployer.id
  mgmtSubnet    = each.value["subnetId"]
  securityGroup = aws_security_group.secGroupWorkstation[each.key].id
  associateEIP  = each.key == "internetVpcData" ? true : false
}
*/