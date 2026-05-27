#  Locals + Subnet Group
locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

resource "aws_db_subnet_group" "this" {
  name       = "${local.name_prefix}-db-subnet-group"
  subnet_ids = var.database_subnet_ids

  tags = {
    Name = "${local.name_prefix}-db-subnet-group"
  }
}

#Security Group
resource "aws_security_group" "this" {
  name        = "${local.name_prefix}-rds-sg"
  description = "Allow MySQL access from EKS nodes"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${local.name_prefix}-rds-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "mysql_from_eks" {
  security_group_id            = aws_security_group.this.id
  referenced_security_group_id = var.allowed_security_group_id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
  description                  = "MySQL from EKS cluster SG"
}

# Egress는 굳이 안 만들어도 됨 — RDS는 outbound 안 함.
# 다만 SG는 default가 deny-all egress라 명시적으로 막아둔 셈.


# Parameter Group
resource "aws_db_parameter_group" "this" {
  name   = "${local.name_prefix}-mysql8"
  family = "mysql8.0"

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  parameter {
    name  = "collation_server"
    value = "utf8mb4_unicode_ci"
  }

  parameter {
    name  = "time_zone"
    value = "Asia/Seoul"
  }

  tags = {
    Name = "${local.name_prefix}-mysql8"
  }
}

#RDS Instance
resource "aws_db_instance" "this" {
  identifier = "${local.name_prefix}-mysql"

  # 엔진
  engine         = "mysql"
  engine_version = var.engine_version

  # 컴퓨트 + 스토리지
  instance_class        = var.instance_class
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true

  # 네트워킹
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.this.id]
  publicly_accessible    = false
  port                   = 3306

  # DB 설정
  db_name              = var.database_name
  username             = var.master_username
  parameter_group_name = aws_db_parameter_group.this.name

  # Master password — AWS Secrets Manager 자동 연동
  manage_master_user_password = true

  # 가용성
  multi_az = var.multi_az

  # 백업
  backup_retention_period = var.backup_retention_days
  backup_window           = "16:00-17:00" # KST 새벽 1~2시
  maintenance_window      = "sun:17:00-sun:18:00"

  # destroy 정책
  deletion_protection       = var.deletion_protection
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${local.name_prefix}-final-${formatdate("YYYYMMDD-hhmm", timestamp())}"

  # 모니터링 (선택, 기본 비활성)
  performance_insights_enabled = false
  monitoring_interval          = 0

  # autoMinorVersionUpgrade — minor 버전 자동 패치
  auto_minor_version_upgrade = true

  tags = {
    Name = "${local.name_prefix}-mysql"
  }
}
