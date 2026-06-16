variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "ap-south-1"
}

variable "environment" {
  description = "Environment name (dev or prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "environment must be 'dev' or 'prod'."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "db_username" {
  description = "Master username for the RDS instance"
  type        = string
  default     = "loanhub"
}

variable "github_org" {
  description = "GitHub organisation or user that owns the repos"
  type        = string
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

variable "eks_admin_role_name" {
  description = "Name of the IAM role to grant EKS cluster-admin access (e.g. your SSO role)"
  type        = string
  default     = "AWSReservedSSO_AdministratorAccess_28d3ec7be400d057"
}

data "aws_iam_role" "admin" {
  name = var.eks_admin_role_name
}

locals {
  name = "loanhub-${var.environment}"
  azs  = slice(data.aws_availability_zones.available.names, 0, 2)

  private_subnets = [for i in range(length(local.azs)) : cidrsubnet(var.vpc_cidr, 4, i + length(local.azs))]
  public_subnets  = [for i in range(length(local.azs)) : cidrsubnet(var.vpc_cidr, 4, i)]

  tags = {
    Project     = "loanhub"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
