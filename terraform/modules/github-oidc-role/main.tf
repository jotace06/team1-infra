# Per-environment IAM Role assumable by GitHub Actions for ECR push.
#
# Trust policy restricts which GitHub workflows can assume this role via the
# 'sub' claim (e.g., specific branch only). Permissions cover ECR auth + image
# push on the specified repositories only.

resource "aws_iam_role" "this" {
  name        = var.role_name
  description = "GitHub Actions role for ${var.repo}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = var.oidc_provider_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        # 'aud' (audience) is set to sts.amazonaws.com by GitHub Actions by default.
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        # 'sub' restricts which workflows/refs can assume the role.
        # Use StringLike to support wildcard patterns if needed.
        StringLike = {
          "token.actions.githubusercontent.com:sub" = var.github_subject_claims
        }
      }
    }]
  })

  tags = var.tags
}

# ECR push policy — minimum permissions for `docker push`.
# See: https://docs.aws.amazon.com/AmazonECR/latest/userguide/security_iam_id-based-policy-examples.html
resource "aws_iam_policy" "ecr_push" {
  name        = "${var.role_name}-ecr-push"
  description = "ECR push permissions for ${var.repo}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "GetAuthorizationToken"
        Effect = "Allow"
        Action = "ecr:GetAuthorizationToken"
        # GetAuthorizationToken is account-wide; doesn't accept specific ARNs.
        Resource = "*"
      },
      {
        Sid    = "ECRRepositoryOperations"
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage",
        ]
        Resource = var.ecr_repository_arns
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ecr_push" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.ecr_push.arn
}
