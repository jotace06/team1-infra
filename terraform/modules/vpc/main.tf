locals {
  name_prefix = "${var.project_name}-${var.environment}"
  az_count    = length(var.availability_zones)

  # 각 subnet의 CIDR을 자동 계산
  # vpc_cidr가 10.10.0.0/16 일 때:
  #   public:   10.10.0.0/24, 10.10.1.0/24, ...
  #   private:  10.10.10.0/24, 10.10.11.0/24, ...
  #   database: 10.10.20.0/24, 10.10.21.0/24, ...
  public_subnet_cidrs   = [for i in range(local.az_count) : cidrsubnet(var.vpc_cidr, 8, i)]
  private_subnet_cidrs  = [for i in range(local.az_count) : cidrsubnet(var.vpc_cidr, 8, i + 10)]
  database_subnet_cidrs = [for i in range(local.az_count) : cidrsubnet(var.vpc_cidr, 8, i + 20)]
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${local.name_prefix}-vpc"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${local.name_prefix}-igw"
  }
}

resource "aws_subnet" "public" {
  count = local.az_count

  vpc_id                  = aws_vpc.this.id
  cidr_block              = local.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name                                         = "${local.name_prefix}-public-${var.availability_zones[count.index]}"
    "kubernetes.io/role/elb"                     = "1" # ALB Controller가 public subnet 식별용
    "kubernetes.io/cluster/${local.name_prefix}" = "shared"
  }
}

resource "aws_subnet" "private" {
  count = local.az_count

  vpc_id            = aws_vpc.this.id
  cidr_block        = local.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name                                         = "${local.name_prefix}-private-${var.availability_zones[count.index]}"
    "kubernetes.io/role/internal-elb"            = "1" # 내부 ELB용
    "kubernetes.io/cluster/${local.name_prefix}" = "shared"
  }
}

resource "aws_subnet" "database" {
  count = local.az_count

  vpc_id            = aws_vpc.this.id
  cidr_block        = local.database_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${local.name_prefix}-database-${var.availability_zones[count.index]}"
  }
}

resource "aws_eip" "nat" {
  count  = var.nat_gateway_count
  domain = "vpc"

  tags = {
    Name = "${local.name_prefix}-nat-eip-${count.index + 1}"
  }
}

resource "aws_nat_gateway" "this" {
  count = var.nat_gateway_count

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id # NAT은 public subnet에

  tags = {
    Name = "${local.name_prefix}-nat-${count.index + 1}"
  }

  depends_on = [aws_internet_gateway.this]
}

# Public route table — 인터넷으로 직접 (IGW)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${local.name_prefix}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count = local.az_count

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private route table — NAT으로 (AZ별로 1개씩, dev에서는 NAT이 1개라 다 같은 NAT을 가리킴)
resource "aws_route_table" "private" {
  count = local.az_count

  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    # NAT이 1개면 모든 private subnet이 NAT[0]을 사용,
    # NAT이 AZ 수만큼이면 같은 인덱스의 NAT 사용
    nat_gateway_id = aws_nat_gateway.this[var.nat_gateway_count == 1 ? 0 : count.index].id
  }

  tags = {
    Name = "${local.name_prefix}-private-rt-${count.index + 1}"
  }
}

resource "aws_route_table_association" "private" {
  count = local.az_count

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# Database route table — 인터넷 라우팅 없음 (완전 격리)
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${local.name_prefix}-database-rt"
  }
}

resource "aws_route_table_association" "database" {
  count = local.az_count

  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}
