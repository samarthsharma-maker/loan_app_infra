# data "aws_iam_policy_document" "frontend_oidc_trust" {
#   statement {
#     sid     = "AllowGitHubOIDCAssumeForFrontend"
#     effect  = "Allow"
#     actions = ["sts:AssumeRoleWithWebIdentity"]

#     principals {
#       type        = "Federated"
#       identifiers = [aws_iam_openid_connect_provider.github.arn]
#     }

#     condition {
#       test     = "StringEquals"
#       variable = "token.actions.githubusercontent.com:aud"
#       values   = ["sts.amazonaws.com"]
#     }

#     condition {
#       test     = "StringEquals"
#       variable = "token.actions.githubusercontent.com:sub"
#       values = [
#         "repo:${var.github_org}/loanhub-frontend:ref:refs/heads/main"
#       ]
#     }
#   }
# }

# resource "aws_iam_role" "frontend_ecr_push" {
#   name               = "${local.name}-frontend-ecr-push-role"
#   assume_role_policy = data.aws_iam_policy_document.frontend_oidc_trust.json

#   max_session_duration = 3600

#   tags = merge(
#     local.tags,
#     {
#       Name       = "${local.name}-frontend-ecr-push-role"
#       Repository = "loanhub-frontend"
#       Purpose    = "ECR Docker Image Push"
#     }
#   )
# }

# data "aws_iam_policy_document" "frontend_ecr_push_policy" {
#   statement {
#     sid    = "AllowECRAuth"
#     effect = "Allow"
#     actions = [
#       "ecr:GetAuthorizationToken"
#     ]
#     resources = ["*"]
#   }

#   statement {
#     sid    = "AllowECRPush"
#     effect = "Allow"
#     actions = [
#       "ecr:BatchCheckLayerAvailability",
#       "ecr:GetDownloadUrlForLayer",
#       "ecr:BatchGetImage",
#       "ecr:InitiateLayerUpload",
#       "ecr:UploadLayerPart",
#       "ecr:CompleteLayerUpload",
#       "ecr:PutImage"
#     ]
#     resources = [
#       "arn:aws:ecr:${var.aws_region}:${data.aws_caller_identity.current.account_id}:repository/loanhub-frontend"
#     ]
#   }
# }

# resource "aws_iam_role_policy" "frontend_ecr_push" {
#   name   = "${local.name}-frontend-ecr-push-policy"
#   role   = aws_iam_role.frontend_ecr_push.id
#   policy = data.aws_iam_policy_document.frontend_ecr_push_policy.json
# }
