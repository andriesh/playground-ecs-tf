data "aws_region" "current" {}
data "aws_availability_zones" "available" {}

# Create VPC

resource "aws_vpc_ipam" "andrei-rusnac-lab1-ipam" {
  operating_regions {
    region_name = data.aws_region.current.name
  }
  tags = merge(module.common_tags.tags, { Name = "andrei-rusnac-ipam" })
}

resource "aws_vpc_ipam_pool" "andrei-rusnac-lab1-ipam" {
  address_family = "ipv4"
  ipam_scope_id  = aws_vpc_ipam.andrei-rusnac-lab1-ipam.private_default_scope_id
  locale         = data.aws_region.current.name
  tags = merge(module.common_tags.tags, { Name = "andrei-rusnac-ipam-pool" })
}

resource "aws_vpc_ipam_pool_cidr" "andrei-rusnac-lab1-cidr" {
  ipam_pool_id = aws_vpc_ipam_pool.andrei-rusnac-lab1-ipam.id
  cidr         = "10.0.0.0/16"
}

resource "aws_vpc" "andrei-rusnac-lab1-vpc" {
  ipv4_ipam_pool_id   = aws_vpc_ipam_pool.andrei-rusnac-lab1-ipam.id
  ipv4_netmask_length = 16
  depends_on = [
    aws_vpc_ipam_pool_cidr.andrei-rusnac-lab1-cidr
  ]
  tags = merge(module.common_tags.tags, { Name = "andrei-rusnac-vpc" })
}


# Create Subnets

variable "public_subnet_cidrs" {
 type        = list(string)
 description = "Public Subnet CIDR values"
 default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

resource "aws_subnet" "public_subnets" {
    count      = length(var.public_subnet_cidrs)
    vpc_id     = aws_vpc.andrei-rusnac-lab1-vpc.id
    cidr_block = element(var.public_subnet_cidrs, count.index)
    #  Add subnets to different AZ
    availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
    tags = merge(module.common_tags.tags, { Name = "andrei-rusnac-public-subnet-${count.index + 1}" })
}


# Create Internet Gateway
resource "aws_internet_gateway" "internet-gateway" {
  vpc_id = aws_vpc.andrei-rusnac-lab1-vpc.id
  tags = merge(module.common_tags.tags, { Name = "andrei-rusnac-igw-lab1" })
}
resource "aws_route" "route-gw" {
  route_table_id         = aws_vpc.andrei-rusnac-lab1-vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet-gateway.id
}