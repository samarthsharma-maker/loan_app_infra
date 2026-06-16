data "aws_iam_policy_document" "terraform_boundary" {
  statement {
    sid    = "AllowEC2AndNetworking"
    effect = "Allow"
    actions = [
      "ec2:*",
      "elasticloadbalancing:*",
      "rds:*",
      "s3:*",
      "iam:*",
      "kms:*",
      "cloudwatch:*",
      "logs:*",
      "sns:*",
      "sqs:*",
      "secretsmanager:*",
      "ssm:*"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "DenyDangerousIAMActions"
    effect = "Deny"
    actions = [
      "iam:DeleteUser",
      "iam:DeleteGroup",
      "iam:DeleteRole",
      "iam:DeletePolicy",
      "iam:DeleteRolePolicy",
      "iam:DeleteGroupPolicy",
      "iam:DeleteUserPolicy",
      "iam:DeleteAccessKey",
      "iam:DeleteLoginProfile",
      "iam:DeleteMFADevice",
      "iam:DeactivateMFADevice",
      "iam:RemoveUserFromGroup",
      "iam:RemoveClientIDFromOpenIDConnectProvider",
      "iam:DeleteOpenIDConnectProvider",
      "iam:CreateAccessKey",
      "iam:CreateLoginProfile",
      "iam:CreateUser"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "DenyOrganizationAndBillingChanges"
    effect = "Deny"
    actions = [
      "organizations:*",
      "account:*",
      "billing:*",
      "cur:*"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "DenyPermissionBoundaryModification"
    effect = "Deny"
    actions = [
      "iam:PutUserPermissionsBoundary",
      "iam:PutRolePermissionsBoundary",
      "iam:DeleteUserPermissionsBoundary",
      "iam:DeleteRolePermissionsBoundary"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "terraform_boundary" {
  name        = local.boundary_name
  description = "Permission boundary for resources created by Terraform CI/CD"
  policy      = data.aws_iam_policy_document.terraform_boundary.json

  tags = merge(
    local.tags,
    {
      Name = local.boundary_name
    }
  )
}

