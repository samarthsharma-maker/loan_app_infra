resource "github_actions_secret" "backend_aws_role_arn" {
  repository  = "loan_app_backend"
  secret_name = "AWS_ROLE_ARN"
  value       = aws_iam_role.backend_ecr_push.arn
}

resource "github_actions_secret" "backend_aws_region" {
  repository  = "loan_app_backend"
  secret_name = "AWS_REGION"
  value       = var.aws_region
}

resource "github_actions_secret" "backend_oidc_provider_arn" {
  repository  = "loan_app_backend"
  secret_name = "OIDC_PROVIDER_ARN"
  value       = data.aws_iam_openid_connect_provider.github.arn
}

# Frontend Repository Secrets
resource "github_actions_secret" "frontend_aws_role_arn" {
  repository  = "loan_app_frontend"
  secret_name = "AWS_ROLE_ARN"
  value       = aws_iam_role.frontend_ecr_push.arn
}

resource "github_actions_secret" "frontend_aws_region" {
  repository  = "loan_app_frontend"
  secret_name = "AWS_REGION"
  value       = var.aws_region
}

resource "github_actions_secret" "frontend_oidc_provider_arn" {
  repository  = "loan_app_frontend"
  secret_name = "OIDC_PROVIDER_ARN"
  value       = data.aws_iam_openid_connect_provider.github.arn
}

# Backend ECR Repository URI
resource "github_actions_secret" "backend_ecr_uri" {
  repository  = "loan_app_backend"
  secret_name = "ECR_BACKEND_URI"
  value       = module.ecr["loanapp-backend"].repository_url
}

# Frontend ECR Repository URI
resource "github_actions_secret" "frontend_ecr_uri" {
  repository  = "loan_app_frontend"
  secret_name = "ECR_FRONTEND_URI"
  value       = module.ecr["loanapp-frontend"].repository_url
}

# # GitOps Token (for loanhub-gitops repository updates)
# resource "github_actions_secret" "backend_gitops_token" {
#   repository  = "loan_app_backend"
#   secret_name = "GITOPS_TOKEN"
#   value       = var.gitops_token
# }

# resource "github_actions_secret" "frontend_gitops_token" {
#   repository  = "loan_app_frontend"
#   secret_name = "GITOPS_TOKEN"
#   value       = var.gitops_token
# }
