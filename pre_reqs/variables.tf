variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "LoanApp"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "development"
}

variable "short_name" {
  description = "Short name used for resource naming"
  type        = string
  default     = "loanapp"
}

variable "github_org" {
  description = "GitHub organization or username"
  type        = string
}

variable "github_token" {
  description = "GitHub Personal Access Token (PAT) for creating secrets"
  type        = string
  sensitive   = true
}

variable "github_repo" {
  description = "GitHub repository for Terraform infrastructure management"
  type        = string
  default     = "loan_app_infra"
}

variable "github_branch" {
  description = "GitHub branch that is allowed to assume the CI/CD role"
  type        = string
  default     = "main"
}

variable "github_repos" {
  description = "List of GitHub repositories to add secrets to"
  type        = list(string)
  default     = ["loan_app_backend", "loan_app_frontend", "loan_app_infra", "loan_app_gitops"]
}
