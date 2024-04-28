#----------------------------------------
# VPCの作成
#----------------------------------------
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true # AWSのDNSサーバによる名前解決を有効
  enable_dns_hostnames = true # VPC内のリソースにパブリックDNSホスト名を自動的に割り当てる
  tags = {
    Name = var.name
  }
}

# Public Subnet
resource "aws_subnet" "public" {
  vpc_id = aws_vpc.main.id

  availability_zone       = "ap-northeast-1a"
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true # 起動したインスタンスにパブリックIPを自動割当

  tags = {
    Name = "${var.name}-public"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.name
  }
}

resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = var.name
  }
}

# SubnetとRoute tableの関連付け
resource "aws_route_table_association" "public_route_associate" {
  subnet_id = aws_subnet.public.id 
  route_table_id = aws_route_table.public_route.id
}


# Security Group作成
resource "aws_security_group" "ec2_security_group" {
  description = "For EC2 Linux"
  vpc_id      = aws_vpc.main.id
  tags = {
    Name = var.name
  }

  # インバウンドルール
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # 接続元を限定する場合は変更する
  }

  # アウトバウンドルール
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}