# Trust policy for infrastructure repo
data "aws_iam_policy_document" "cicd_trust" {
  statement {
    sid     = "AllowGitHubOIDCAssume"
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = local.github_subjects
    }
  }
}

# IAM role for Terraform infrastructure management
resource "aws_iam_role" "terraform_cicd" {
  name               = local.role_name
  assume_role_policy = data.aws_iam_policy_document.cicd_trust.json

  max_session_duration = 3600

  # Permission boundary scopes what can be created
  permissions_boundary = aws_iam_policy.terraform_boundary.arn

  tags = merge(
    local.tags,
    {
      Name = local.role_name
    }
  )
}

# Attach admin policy for Terraform (scoped by boundary)
resource "aws_iam_role_policy_attachment" "terraform_admin" {
  role       = aws_iam_role.terraform_cicd.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Region lock policy - enforce operations only in specified region
data "aws_iam_policy_document" "region_lock" {
  statement {
    sid       = "DenyOutsideRegion"
    effect    = "Deny"
    actions   = ["*"]
    resources = ["*"]

    condition {
      test     = "StringNotEquals"
      variable = "aws:RequestedRegion"
      values   = [var.aws_region]
    }
  }
}

resource "aws_iam_role_policy" "region_lock" {
  name   = "${local.role_name}-region-lock"
  role   = aws_iam_role.terraform_cicd.id
  policy = data.aws_iam_policy_document.region_lock.json
}

