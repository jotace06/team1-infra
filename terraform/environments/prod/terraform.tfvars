environment = "prod"
owner       = "jc"

vpc_cidr           = "10.20.0.0/16"   # ← dev와 다른 CIDR
availability_zones = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]   # 3개 AZ
nat_gateway_count  = 3                # AZ 수만큼