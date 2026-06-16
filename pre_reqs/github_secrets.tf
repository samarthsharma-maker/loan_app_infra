# GitHub Actions Secrets for infrastructure management

# Create AWS_ROLE_ARN secret
resource "github_actions_secret" "aws_role_arn" {
  repository      = local.github_repo
  secret_name     = "AWS_ROLE_ARN"
  plaintext_value = aws_iam_role.terraform_cicd.arn
}

# Create AWS_REGION secret
resource "github_actions_secret" "aws_region" {
  repository      = local.github_repo
  secret_name     = "AWS_REGION"
  plaintext_value = var.aws_region
}

# Create OIDC_PROVIDER_ARN secret for reference
resource "github_actions_secret" "oidc_provider_arn" {
  repository      = local.github_repo
  secret_name     = "OIDC_PROVIDER_ARN"
  plaintext_value = aws_iam_openid_connect_provider.github.arn
}

# Create ORG_NAME secret for CI/CD workflows to use
resource "github_actions_secret" "org_name" {
  repository      = local.github_repo
  secret_name     = "ORG_NAME"
  plaintext_value = var.github_org
}

# Create GH_TOKEN secret for CI/CD workflows to use
resource "github_actions_secret" "gh_token" {
  repository      = local.github_repo
  secret_name     = "GH_TOKEN"
  plaintext_value = var.github_token
}
