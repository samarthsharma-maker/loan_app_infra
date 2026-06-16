# Infrastructure CI/CD Prerequisites

This directory contains Terraform configurations to set up the prerequisites for automated CI/CD using GitHub Actions and AWS, including automatic creation of secrets across multiple repositories.

## What This Creates

### 1. **GitHub OIDC Provider** (`aws_iam_oidc.tf`)
- AWS OIDC provider configured to trust GitHub Actions
- Verifies GitHub's OIDC certificates for secure token exchange
- No long-lived credentials needed

### 2. **CI/CD IAM Role** (`aws_iam_role.tf`)
- IAM role that GitHub Actions assumes via OIDC federation
- Permissions: AdministratorAccess (scoped by permission boundary)
- Trust policy: Limited to specified branch and repositories
- Region lock: Enforces operations only in configured region
- Session policies: Enable audit trail and security controls

### 3. **Permission Boundary** (`aws_iam_boundary.tf`)
- Limits what resources can be created/modified
- Prevents deletion of critical resources
- Blocks organization/billing changes
- Prevents permission boundary modification itself

### 4. **GitHub Repository Secrets** (`github_secrets.tf`) ✨ NEW
- Automatically creates secrets on **all configured repositories**
- Creates: `AWS_ROLE_ARN`, `AWS_REGION`, `GITHUB_OIDC_PROVIDER_ARN`
- Uses GitHub Terraform provider for IaC-managed secrets
- No manual secret configuration needed!

## Prerequisites

### 1. AWS Account & Credentials
```bash
# Configure AWS CLI
aws configure

# Verify you have appropriate IAM permissions (recommend AdministratorAccess)
aws sts get-caller-identity
```

### 2. GitHub Personal Access Token (PAT)
```bash
# Create a new PAT at: https://github.com/settings/tokens
# 
# Required scopes:
#   - repo (full control of private repositories)
#   - admin:repo_hook (for webhook access)
#   - workflow (for GitHub Actions workflows)
#
# Save it securely - you'll need it in the next step!
```

### 3. Terraform
```bash
# Install Terraform 1.5+
terraform --version
```

## Setup Instructions

### Step 1: Prepare Variables

```bash
cd infra/pre_reqs

# Copy example configuration
cp terraform.tfvars.example terraform.tfvars
```

### Step 2: Configure with Your Values

**Option A: Edit terraform.tfvars (insecure for PAT)**
```hcl
github_org = "raj-pro"
github_token = "ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"  # DON'T commit this!
github_repos = [
  "loan_app_infra",
  "loan_app_backend ",
  "loan_app_frontend"
]
github_branch = "main"
```

**Option B: Use Environment Variables (recommended - secure)**
```bash
# Set as environment variable (won't be saved in files)
export TF_VAR_github_token="ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

# Terraform will automatically use this
```

**Option C: Prompt for Input**
```bash
terraform apply
# Terraform will prompt for github_token value
```

### Step 3: Review & Deploy

```bash
# Initialize Terraform with GitHub provider
terraform init

# Review what will be created
terraform plan
# Expected: GitHub OIDC provider, IAM role, boundary, and secrets for each repo

# Deploy everything
terraform apply

# Save outputs (optional, for reference)
terraform output -json > pre_reqs_outputs.json
```

**What gets created:**
```
✓ GitHub OIDC Provider (aws)
✓ IAM Role (loanhub-dev-terraform-cicd-role)
✓ Permission Boundary Policy
✓ Region Lock & Session Policies
✓ GitHub secrets on ALL repos:
  - AWS_ROLE_ARN
  - AWS_REGION
  - GITHUB_OIDC_PROVIDER_ARN
```

### Step 4: Verify Configuration

```bash
# View all outputs
terraform output

# Check specific output
terraform output -json github_secrets_urls
# Shows URLs to verify secrets were created

# Manually verify in GitHub
# Visit: https://github.com/{org}/{repo}/settings/secrets/actions
```

## File Descriptions

| File | Purpose |
|------|---------|
| `versions.tf` | Terraform and provider requirements (AWS, GitHub, TLS) |
| `variables.tf` | Input variables (region, org, token, repos list, etc.) |
| `locals.tf` | Computed values (OIDC subjects for all repos, names, etc.) |
| `aws_iam_oidc.tf` | GitHub OIDC provider configuration |
| `aws_iam_role.tf` | CI/CD IAM role with trust policy |
| `aws_iam_boundary.tf` | Permission boundary policy |
| `github_secrets.tf` | ✨ Creates secrets on all repositories |
| `outputs.tf` | Output values (role ARN, secret URLs, etc.) |
| `terraform.tfvars.example` | Example variable values |
| `README.md` | This file |

## Architecture

```
GitHub Actions Workflow (any repo in github_repos)
        ↓
   OIDC Token Request
        ↓
AWS STS AssumeRoleWithWebIdentity
        ↓
  Verify Token Against:
  ├─ GitHub OIDC Provider (AWS)
  ├─ Trust Policy (org/repo/branch from secrets)
  └─ Token Audience (sts.amazonaws.com)
        ↓
   Temporary AWS Credentials (1 hour expiry)
        ↓
  Execute Terraform with:
  ├─ AdministratorAccess (from role)
  ├─ Permission Boundary (security scope)
  ├─ Region Lock (ap-south-1 only)
  └─ Session Name Policy (audit trail)
```

## Security Features

### ✅ Zero Credential Storage
- No AWS access keys in GitHub secrets
- PAT only needed for initial Terraform setup, not stored
- Temporary STS tokens expire after 1 hour
- GitHub OIDC tokens are ephemeral

### ✅ Least Privilege
- Permission boundary prevents privilege escalation
- Region lock prevents operations outside configured region
- Session name policy enables CloudTrail filtering
- Trust policy specific to org/repos/branch

### ✅ Audit Trail
- All actions performed via temporary STS tokens
- Session tags enable detailed CloudTrail logs
- Git history tracks infrastructure changes
- Secrets creation is visible in Terraform state

### ✅ Multi-Repository Support
- Single trust policy for all repos
- Secrets automatically created/updated on all repos
- Easy to add/remove repositories

## Troubleshooting

### Issue: "Error: Invalid Personal Access Token"

**Cause:** PAT is invalid, expired, or missing required scopes

**Fix:**
```bash
# Create new PAT at https://github.com/settings/tokens
# Required scopes: repo, admin:repo_hook, workflow

# Use environment variable (don't save in files)
export TF_VAR_github_token="ghp_xxxx..."
terraform apply
```

### Issue: "Failed to create secret in repository"

**Cause:** Repository doesn't exist or PAT doesn't have access

**Fix:**
```bash
# Verify repository exists
gh repo view {org}/{repo}

# Check PAT has repo access
gh auth status

# Verify repo list in terraform.tfvars
terraform plan  # Check which repos will be configured
```

### Issue: "Error: GitHub OIDC token validation failed"

**Cause:** Trust policy or subject mismatch

**Fix:**
```bash
# Verify variables
terraform output terraform_cicd_role_name
terraform output github_repos_configured

# Check trust policy
aws iam get-role --role-name loanhub-dev-terraform-cicd-role
aws iam list-role-policies --role-name loanhub-dev-terraform-cicd-role
```

### Issue: "terraform plan shows changes every time"

**Cause:** GitHub provider state drift

**Fix:**
```bash
# Refresh state
terraform refresh

# If secrets are truly missing, reapply
terraform apply
```

## Advanced: Supporting Multiple Environments

To create separate roles for dev/staging/prod:

```bash
# Create a workspace for each environment
terraform workspace new staging
terraform workspace select staging

# Update variables for staging
# - environment = "staging"
# - github_branch = "staging"
# - github_repos = ["loan_app_infra-staging", ...]

terraform apply

# Switch back to dev
terraform workspace select default
```

## Best Practices

### 🔒 PAT Security
- Store PAT in environment variable, not files
- Use limited scopes (only what's needed)
- Rotate PATs periodically
- Never commit PATs to Git

### 📝 Configuration
- Keep `terraform.tfvars` out of Git (add to `.gitignore`)
- Use `.terraform/` directory which is ignored
- Commit `terraform.tfstate.backup` is safe, not `.tfstate`

### 🔄 Workflow
1. Update `variables.tf` when changing requirements
2. Run `terraform plan` to see changes
3. Review changes carefully before `terraform apply`
4. Commit only `.tf` files, not state files
5. Use CI/CD to manage infrastructure changes

## Integration with CI/CD Workflows

Once this setup is complete, the workflows in `.github/workflows/` will:

1. **Read secrets** created by this setup (AWS_ROLE_ARN, AWS_REGION)
2. **Generate OIDC token** automatically
3. **Assume role** with temporary credentials
4. **Run terraform plan/apply** securely
5. **Clean up** automatically (token expires)

**No additional manual setup needed!** ✨

## Cleanup

To remove all resources:

```bash
cd infra/pre_reqs

# Review what will be deleted
terraform plan -destroy

# Delete everything
terraform destroy

# Clean up state files
rm -rf .terraform terraform.tfstate*
```

**Warning:** This will delete:
- GitHub OIDC provider
- IAM role and policies
- GitHub secrets

## Related Files

- CI Pipeline: `../.github/workflows/ci.yaml`
- CD Pipeline: `../.github/workflows/cd.yaml`
- Main Infrastructure: `../` (*.tf files)

## Reference

- [GitHub OIDC Documentation](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect)
- [Terraform GitHub Provider](https://registry.terraform.io/providers/integrations/github/latest/docs)
- [AWS OIDC Setup Guide](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html)
- [GitHub Personal Access Tokens](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens)
