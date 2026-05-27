environment = "dev"
owner       = "jc"   # ← 본인 이름 또는 닉네임

vpc_cidr           = "10.10.0.0/16"
availability_zones = ["ap-northeast-2a", "ap-northeast-2c"]   # 2개 AZ로 시작
nat_gateway_count  = 1

# 본인 IAM 사용자 ARN — Step 0에서 메모한 ARN
cluster_admin_iam_arn = "arn:aws:iam::582797602058:user/admin"