#!/bin/bash

#############################################################################
# GitHub Secrets Configuration Script
# This script configures GitHub secrets and variables for CI/CD pipeline
#############################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Utility functions
info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# Check prerequisites
check_prerequisites() {
    info "Checking prerequisites..."

    # Check if gh CLI is installed
    if ! command -v gh &> /dev/null; then
        error "GitHub CLI (gh) is not installed. Install from: https://cli.github.com/"
    fi

    # Check if user is authenticated with GitHub
    if ! gh auth status &> /dev/null; then
        error "You are not authenticated with GitHub. Run: gh auth login"
    fi

    # Check if terraform is available
    if ! command -v terraform &> /dev/null; then
        warn "Terraform not found. Will attempt to extract values from tfstate or outputs."
    fi

    info "Prerequisites check passed ✓"
}

# Get values from Terraform outputs
get_terraform_outputs() {
    info "Fetching Terraform outputs..."

    if [ ! -f "terraform.tfstate" ] && [ ! -f "terraform.tfvars" ]; then
        error "No Terraform state or vars found in current directory"
    fi

    # Run terraform output to get values
    AWS_ROLE_ARN=$(terraform output -raw terraform_cicd_role_arn 2>/dev/null || echo "")
    AWS_REGION=$(terraform output -raw aws_region 2>/dev/null || echo "ap-south-1")
    GITHUB_ORG=$(terraform output -raw -json 2>/dev/null | jq -r '.github_org.value' 2>/dev/null || echo "")
    GITHUB_REPO=$(terraform output -raw -json 2>/dev/null | jq -r '.github_repo.value' 2>/dev/null || echo "")

    if [ -z "$AWS_ROLE_ARN" ]; then
        error "Could not fetch AWS_ROLE_ARN from Terraform outputs. Did you run 'terraform apply'?"
    fi

    info "Terraform outputs fetched ✓"
}

# Interactive input if needed
get_user_input() {
    info "Verifying GitHub repository details..."

    read -p "Enter GitHub organization (default: $GITHUB_ORG): " input_org
    GITHUB_ORG=${input_org:-$GITHUB_ORG}

    read -p "Enter GitHub repository name (default: $GITHUB_REPO): " input_repo
    GITHUB_REPO=${input_repo:-$GITHUB_REPO}

    if [ -z "$GITHUB_ORG" ] || [ -z "$GITHUB_REPO" ]; then
        error "GitHub organization and repository name are required"
    fi

    info "Repository: $GITHUB_ORG/$GITHUB_REPO ✓"
}

# Set GitHub secrets
set_github_secrets() {
    info "Setting GitHub secrets and variables..."

    REPO="$GITHUB_ORG/$GITHUB_REPO"

    # Check if repository is accessible
    if ! gh repo view "$REPO" &> /dev/null; then
        error "Cannot access repository: $REPO. Check the organization and repository name."
    fi

    # Set AWS_ROLE_ARN secret
    info "Setting AWS_ROLE_ARN secret..."
    echo "$AWS_ROLE_ARN" | gh secret set AWS_ROLE_ARN --repo "$REPO" --body "$(cat)"
    info "AWS_ROLE_ARN set ✓"

    # Set AWS_REGION variable
    info "Setting AWS_REGION variable..."
    gh variable set AWS_REGION --repo "$REPO" --body "$AWS_REGION"
    info "AWS_REGION set ✓"

    # Display set values
    info "Verifying secrets..."
    gh secret list --repo "$REPO" | grep AWS_ROLE_ARN && info "AWS_ROLE_ARN verified ✓" || warn "AWS_ROLE_ARN not found in list"
    gh variable list --repo "$REPO" | grep AWS_REGION && info "AWS_REGION verified ✓" || warn "AWS_REGION not found in list"
}

# Display summary
display_summary() {
    echo ""
    echo "=========================================="
    echo -e "${GREEN}✓ GitHub Secrets Configuration Complete!${NC}"
    echo "=========================================="
    echo ""
    echo "Configured Secrets & Variables:"
    echo "  Repository: $GITHUB_ORG/$GITHUB_REPO"
    echo "  AWS Account ID: $(echo $AWS_ROLE_ARN | cut -d':' -f5)"
    echo "  AWS Region: $AWS_REGION"
    echo "  AWS Role ARN: $AWS_ROLE_ARN"
    echo ""
    echo "Next Steps:"
    echo "  1. Verify secrets in: https://github.com/$GITHUB_ORG/$GITHUB_REPO/settings/secrets"
    echo "  2. Create a PR to test the CI pipeline"
    echo "  3. Merge to main to trigger CD pipeline"
    echo ""
}

# Cleanup on exit
cleanup() {
    # Unset sensitive variables
    unset AWS_ROLE_ARN
}

trap cleanup EXIT

# Main execution
main() {
    echo "=========================================="
    echo "GitHub Secrets Configuration Script"
    echo "=========================================="
    echo ""

    # Change to script directory
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    cd "$SCRIPT_DIR"

    check_prerequisites
    get_terraform_outputs
    get_user_input
    set_github_secrets
    display_summary
}

# Run main function
main "$@"
