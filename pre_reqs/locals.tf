data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  aws_account_id = data.aws_caller_identity.current.account_id
  aws_region     = data.aws_region.current.name

  project_name = var.project_name
  environment  = var.environment
  short_name   = var.short_name
  name_prefix  = "${local.short_name}-${local.environment}"

  github_org    = var.github_org
  github_repo   = var.github_repo
  github_branch = var.github_branch

  # GitHub OIDC subjects (allowed to assume the role)
  github_subjects = [
    "repo:${local.github_org}/${local.github_repo}:ref:refs/heads/${local.github_branch}",
    "repo:${local.github_org}/${local.github_repo}:pull_request"
  ]

  # IAM role and boundary names
  role_name     = "${local.name_prefix}-terraform-cicd-role"
  boundary_name = "${local.name_prefix}-terraform-created-users-boundary"

  tags = {
    Project     = local.project_name
    Environment = local.environment
    ManagedBy   = "Terraform"
    Module      = "CI/CD Prerequisites"
  }
}
