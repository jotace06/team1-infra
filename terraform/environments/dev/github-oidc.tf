# GitHub Actions OIDC: account-level Provider + per-environment Role.
#
# The Provider is account-wide and must exist exactly once across all
# environments. We declare it here for dev (the first environment); when prod
# is added in Step 14, only the Role module will be invoked again.
#
# If/when prod is added, consider moving the Provider into a shared/global
# environment to make ownership explicit. For now, dev "owns" it.

module "github_oidc_provider" {
  source = "../../modules/github-oidc-provider"

  tags = { Project = "course-registration", Env = "dev" }
}

module "github_oidc_role_dev" {
  source = "../../modules/github-oidc-role"

  role_name         = "github-actions-team1-app-dev"
  repo              = "jotace06/team1-app"
  oidc_provider_arn = module.github_oidc_provider.provider_arn

  github_subject_claims = [
    # Only the 'develop' branch on this exact repo can assume this role.
    "repo:jotace06/team1-app:ref:refs/heads/develop",
  ]

  ecr_repository_arns = [
    module.ecr.repository_arn, # ← ECR 모듈의 output 이름에 맞춰 조정 필요. 아래 주의사항 참조.
  ]

  tags = { Project = "course-registration", Env = "dev" }
}

output "github_actions_role_arn" {
  description = "Set this as the AWS_ROLE_ARN secret in the GitHub repo"
  value       = module.github_oidc_role_dev.role_arn
}
