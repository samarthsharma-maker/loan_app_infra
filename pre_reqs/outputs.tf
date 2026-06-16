output "aws_account_id" {
  description = "AWS Account ID"
  value       = local.aws_account_id
}

output "aws_region" {
  description = "AWS Region"
  value       = local.aws_region
}

output "github_org" {
  description = "GitHub Organization"
  value       = local.github_org
}

output "github_repo" {
  description = "GitHub repository for infrastructure management"
  value       = local.github_repo
}

output "github_oidc_provider_arn" {
  description = "ARN of the GitHub OIDC provider"
  value       = aws_iam_openid_connect_provider.github.arn
}

output "terraform_cicd_role_arn" {
  description = "ARN of the Terraform CI/CD IAM role"
  value       = aws_iam_role.terraform_cicd.arn
}

output "terraform_cicd_role_name" {
  description = "Name of the Terraform CI/CD IAM role"
  value       = aws_iam_role.terraform_cicd.name
}

output "permission_boundary_policy_arn" {
  description = "ARN of the IAM permission boundary policy"
  value       = aws_iam_policy.terraform_boundary.arn
}

output "github_secrets_url" {
  description = "Direct link to GitHub repository secrets settings"
  value       = "https://github.com/${local.github_org}/${local.github_repo}/settings/secrets/actions"
}

output "terraform_outputs_summary" {
  description = "Complete summary of all outputs"
  value = {
    aws_account_id           = local.aws_account_id
    aws_region               = local.aws_region
    github_organization      = local.github_org
    github_repository        = local.github_repo
    github_oidc_provider_arn = aws_iam_openid_connect_provider.github.arn
    terraform_cicd_role_arn  = aws_iam_role.terraform_cicd.arn
    terraform_cicd_role_name = aws_iam_role.terraform_cicd.name
    permission_boundary_arn  = aws_iam_policy.terraform_boundary.arn
    secrets_created          = ["AWS_ROLE_ARN", "AWS_REGION", "OIDC_PROVIDER_ARN", "ORG_NAME", "GH_TOKEN"]
    github_secrets_url       = "https://github.com/${local.github_org}/${local.github_repo}/settings/secrets/actions"
  }
}
