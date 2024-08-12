# Subnet cidr locals
locals {
  private_cidrs = [for i in range(1, 16, 2) : cidrsubnet(var.vpc_cidr, 8, i)]
  public_cidrs  = [for i in range(2, 16, 2) : cidrsubnet(var.vpc_cidr, 8, i)]
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = local.cluster_name
  }
}

# IGW
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = local.cluster_name
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Internet facing NGW and EIP
resource "aws_eip" "main" {
  count  = var.az_count
  domain = "vpc"
  tags = {
    Name = "${var.company_prefix}-${var.env}-${local.az_names[count.index]}"
  }
}

resource "aws_nat_gateway" "main" {
  count         = var.az_count
  depends_on    = [aws_internet_gateway.main, aws_eip.main]
  allocation_id = aws_eip.main[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "${var.company_prefix}-${var.env}-${local.az_names[count.index]}"
  }
}

# Route Tables
resource "aws_default_route_table" "main" {
  default_route_table_id = aws_vpc.main.default_route_table_id

  tags = {
    Name = "${var.company_prefix}-main-rt"
  }
}

resource "aws_route_table" "public" {
  count  = var.az_count
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${upper(substr(local.az_names[count.index], -1, 1))} public | ${var.company_prefix}-${var.env}-rt"
  }
}

resource "aws_route" "igw_route" {
  count                  = var.az_count
  route_table_id         = aws_route_table.public[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table" "private" {
  count  = var.az_count
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${upper(substr(local.az_names[count.index], -1, 1))} private | ${var.company_prefix}-${var.env}-rt"
  }
}

resource "aws_route" "ngw_route" {
  count                  = var.az_count
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[count.index].id
  depends_on             = [aws_route_table.private, aws_nat_gateway.main]
}

resource "aws_route_table_association" "public" {
  count          = var.az_count
  subnet_id      = aws_subnet.public.*.id[count.index]
  route_table_id = aws_route_table.public[count.index].id
}

resource "aws_route_table_association" "private" {
  count          = var.az_count
  subnet_id      = aws_subnet.private.*.id[count.index]
  route_table_id = aws_route_table.private[count.index].id
}

# Subnets
resource "aws_subnet" "private" {
  count                   = var.az_count
  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.private_cidrs[count.index]
  map_public_ip_on_launch = false
  availability_zone       = local.az_names[count.index]
  tags = merge({
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
    "kubernetes.io/role/internal-elb"             = "1"
    Name                                          = "${upper(substr(local.az_names[count.index], -1, 1))} private | ${local.cluster_name}-subnet"
    Accessibility                                 = "private"
  }, local.default_tags_karpenter_discovery)
}

resource "aws_subnet" "public" {
  count                   = var.az_count
  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.public_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone       = local.az_names[count.index]
  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
    "kubernetes.io/role/elb"                      = "1"
    Name                                          = "${upper(substr(local.az_names[count.index], -1, 1))} public | ${local.cluster_name}-subnet"
    Accessibility                                 = "public"
    Availability-zone                             = local.az_names[count.index]
  }
}

# Security groups
resource "aws_security_group" "private" {
  name        = "${local.cluster_name}-private-sg"
  description = "Security group for private resources"
  vpc_id      = aws_vpc.main.id
  tags        = local.default_tags_karpenter_discovery

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    ignore_changes = [
      ingress
    ]
  }
}

resource "aws_security_group" "public" {
  name        = "${local.cluster_name}-public"
  description = "Security group for public resources"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol         = "tcp"
    from_port        = 80
    to_port          = 80
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    protocol         = "tcp"
    from_port        = 443
    to_port          = 443
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

# VPC Gateway Endpoints for s3 and dynamodb
resource "aws_vpc_endpoint" "s3_gateway_endpoint" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = aws_route_table.private[*].id
}

resource "aws_vpc_endpoint" "dynamodb_gateway_endpoint" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.dynamodb"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = aws_route_table.private[*].id
}

# VPC Interface Endpoints for other services
resource "aws_vpc_endpoint" "ssm_interface_endpoint" {
  count               = var.ssm_vpce ? 1 : 0
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.private.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ssm_messages_interface_endpoint" {
  count               = var.ssm_vpce ? 1 : 0
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.ssmmessages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.private.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ec2_messages_interface_endpoint" {
  count               = var.ssm_vpce ? 1 : 0
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.ec2messages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.private.id]
  private_dns_enabled = true
}

# ECR docker Interface Endpoint
resource "aws_vpc_endpoint" "ecr_dkr_interface_endpoint" {
  count               = var.ecr_vpce ? 1 : 0
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.private.id]
  private_dns_enabled = true
}

# ECR API Interface Endpoint
resource "aws_vpc_endpoint" "ecr_api_interface_endpoint" {
  count               = var.ecr_vpce ? 1 : 0
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.private.id]
  private_dns_enabled = true
}

# CloudWatch Logs Interface Endpoint
resource "aws_vpc_endpoint" "cw_logs_interface_endpoint" {
  count               = var.cw_vpce ? 1 : 0
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.private.id]
  private_dns_enabled = true
}

# CloudWatch Metrics Interface Endpoint
resource "aws_vpc_endpoint" "cw_monitoring_interface_endpoint" {
  count               = var.cw_vpce ? 1 : 0
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.monitoring"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.private.id]
  private_dns_enabled = true
}