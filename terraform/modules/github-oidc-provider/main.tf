# GitHub Actions OIDC Provider (AWS account-wide singleton).
#
# This provider must exist exactly once per AWS account. It enables IAM roles
# to be assumed by GitHub Actions workflows via OIDC, eliminating long-lived
# access keys.
#
# References:
# - https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services
# - https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html

resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]

  # Since 2023, AWS validates GitHub's TLS chain via its own trust store and
  # effectively ignores these values for token.actions.githubusercontent.com.
  # The list is still required by the Terraform schema, so we document intent
  # with GitHub's known certificate thumbprints.
  # See: https://github.blog/changelog/2023-06-27-github-actions-update-on-oidc-integration-with-aws/
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd",
  ]

  tags = var.tags
}
