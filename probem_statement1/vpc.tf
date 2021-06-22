# Create VPC/Subnet/Security Group/Network ACL
provider "aws" {
  version = "~> 2.0"
  access_key = var.access_key 
  secret_key = var.secret_key 
  region     = var.region
}


#create the VPC
resource "aws_vpc" "My_VPC" {
  cidr_block           = var.vpcCIDRblock
  instance_tenancy     = var.instanceTenancy
  enable_dns_support   = var.dnsSupport
  enable_dns_hostnames = var.dnsHostNames
  tags = {
    Name = "My VPC"
}
} # end resource

# create the Subnet
resource "aws_subnet" "My_VPC_Public_Subnet" {
  vpc_id                  = aws_vpc.My_VPC.id
  cidr_block              = "172.20.10.0/24"
  map_public_ip_on_launch = var.mapPublicIP
  availability_zone       = var.availabilityZone
  tags = {
   Name = "My Public VPC Subnet"
}
} # end resource
resource "aws_subnet" "My_VPC_Private_Subnet" {
  vpc_id                  = aws_vpc.My_VPC.id
  cidr_block              = "172.20.20.0/24"
  map_public_ip_on_launch = false
  availability_zone       = var.availabilityZone
  tags = {
   Name = "My Private VPC Subnet"
}
} # end resource

# Create the Security Group
resource "aws_security_group" "My_VPC_Security_Group" {
  vpc_id       = aws_vpc.My_VPC.id
  name         = "My VPC Security Group"
  description  = "My VPC Security Group"

  # allow ingress of port 22
  ingress {
    cidr_blocks = var.ingressCIDRblock
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  # allow egress of all ports
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
   Name = "My VPC Security Group"
   Description = "My VPC Security Group"
}
} # end resource

# create VPC Network access control list
resource "aws_network_acl" "My_VPC_Security_ACL" {
  vpc_id = aws_vpc.My_VPC.id
  subnet_ids = [ aws_subnet.My_VPC_Subnet.id ]
  # allow ingress port 22
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.destinationCIDRblock
    from_port  = 22
    to_port    = 22
  }

  # allow ingress port 80
  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = var.destinationCIDRblock
    from_port  = 80
    to_port    = 80
  }

  # allow ingress ephemeral ports
  ingress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = var.destinationCIDRblock
    from_port  = 1024
    to_port    = 65535
  }

  # allow egress port 22
  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.destinationCIDRblock
    from_port  = 22
    to_port    = 22
  }

  # allow egress port 80
  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = var.destinationCIDRblock
    from_port  = 80
    to_port    = 80
  }

  # allow egress ephemeral ports
  egress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = var.destinationCIDRblock
    from_port  = 1024
    to_port    = 65535
  }
  tags = {
    Name = "My VPC ACL"
}
} # end resource

# Create the Internet Gateway
resource "aws_internet_gateway" "My_VPC_GW" {
 vpc_id = aws_vpc.My_VPC.id
 tags = {
        Name = "My VPC Internet Gateway"
}
} # end resource

resource "aws_nat_gateway" "MY_VPC_NAT" {
  subnet_id = aws_subnet.My_VPC_Public_Subnet.id
  tags = {
    Name = "My NAT Gateway"
  }
  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.My_VPC_GW]
}

# Create the Route Table
resource "aws_route_table" "My_VPC_route_table" {
 vpc_id = aws_vpc.My_VPC.id
 tags = {
        Name = "My VPC Route Table"
}
} # end resource

# Create the Internet Access
resource "aws_route" "My_VPC_internet_access" {
  route_table_id         = aws_route_table.My_VPC_route_table.id
  destination_cidr_block = var.destinationCIDRblock
  gateway_id             = aws_internet_gateway.My_VPC_GW.id
} # end resource

# Create the Nat Gateway Access
resource "aws_route" "My_VPC_internet_access" {
  route_table_id         = aws_route_table.My_VPC_route_table.id
  destination_cidr_block = var.destinationCIDRblock
  gateway_id             = aws_nat_gateway.MY_VPC_NAT.id
} # end resource

# Associate the Route Table with the Subnet
resource "aws_route_table_association" "My_VPC_association" {
  subnet_id      = aws_subnet.My_VPC_Subnet.id
  route_table_id = aws_route_table.My_VPC_route_table.id
} # end resource

#Create EC2 instances
resource "aws_instance" "private_instance" {
    ami = "ami-032598fcc7e9d1c7a"
    instance_type = "t2.micro"
    ec2_subnet_id = aws_subnet.My_VPC_Private_Subnet.id
    security_groups = [aws_security_group.private_traffic.name]
    user_data = file("private_ec2.sh")
    tags = {
        Name = "Private Server"
    }
}

resource "aws_instance" "public_instance" {
    ami = "ami-032598fcc7e9d1c7a"
    instance_type = "t2.micro"
    security_groups = [aws_security_group.web_traffic.name]
    user_data = file("public_ec2.sh")
    ec2_subnet_id = aws_subnet.My_VPC_Public_Subnet.id
    tags = {
        Name = "Web Server"
    }
}

resource "aws_eip" "web_ip" {
    instance = aws_instance.private_instance.id
}

resource "aws_security_group" "web_traffic" {
    name = "Allow Web Traffic"
    description = "Allow inbound traffic"
    vpc_id      = aws_vpc.My_VPC.id

 ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

 egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_security_group" "private_traffic" {
    name = "Allow Nat Traffic"
    description = "Allow traffic from nat only"
    vpc_id      = aws_vpc.My_VPC.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [aws_nat_gateway.MY_VPC_NAT.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

output "PrivateIP" {
    value = aws_instance.db.private_ip
}

output "PublicIP" {
    value = aws_eip.web_ip.public_ip
}
