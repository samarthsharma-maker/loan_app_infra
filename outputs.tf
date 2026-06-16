output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnets
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnets
}

output "eks_cluster_name" {
  description = "EKS cluster name — used in: aws eks update-kubeconfig --name <value>"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS API server endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_oidc_provider_arn" {
  description = "OIDC provider ARN (for IRSA)"
  value       = module.eks.oidc_provider_arn
}

output "eso_role_arn" {
  description = "IAM role ARN for External Secrets Operator — set in clustersecretstore.yaml"
  value       = module.eso_irsa.iam_role_arn
}

output "rds_endpoint" {
  description = "RDS instance endpoint — set in base/backend/configmap.yaml as DB_HOST"
  value       = module.rds.db_instance_endpoint
}

output "rds_secret_arn" {
  description = "Secrets Manager ARN containing DB credentials — set in externalsecret.yaml"
  value       = aws_secretsmanager_secret.db.arn
}

output "ecr_repository_urls" {
  description = "Map of ECR repository URLs — loan_app_backend  and loan_app_frontend"
  value       = { for k, v in module.ecr : k => v.repository_url }
}

output "backend_ecr_push_role_arn" {
  description = "ARN of the backend ECR push-only IAM role"
  value       = aws_iam_role.backend_ecr_push.arn
}

output "backend_ecr_push_role_name" {
  description = "Name of the backend ECR push-only IAM role"
  value       = aws_iam_role.backend_ecr_push.name
}

output "frontend_ecr_push_role_arn" {
  description = "ARN of the frontend ECR push-only IAM role"
  value       = aws_iam_role.frontend_ecr_push.arn
}

output "frontend_ecr_push_role_name" {
  description = "Name of the frontend ECR push-only IAM role"
  value       = aws_iam_role.frontend_ecr_push.name
}

output "github_ci_roles_summary" {
  description = "Summary of GitHub CI/CD IAM roles for application repos (backend & frontend)"
  value = {
    oidc_provider_arn = data.aws_iam_openid_connect_provider.github.arn

    backend = {
      repo        = "loan_app_backend "
      role_arn    = aws_iam_role.backend_ecr_push.arn
      role_name   = aws_iam_role.backend_ecr_push.name
      permissions = "ECR Docker image push only"
    }

    frontend = {
      repo        = "loan_app_frontend"
      role_arn    = aws_iam_role.frontend_ecr_push.arn
      role_name   = aws_iam_role.frontend_ecr_push.name
      permissions = "ECR Docker image push only"
    }
  }
}
