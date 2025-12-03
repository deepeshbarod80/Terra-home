# AWS Secret Management in Terraform

This directory contains examples of AWS authentication methods for Terraform:

## Authentication Methods

1. **Environment Variables** - `env-vars/`
2. **AWS Profile** - `aws-profile/`
3. **AWS Config File** - `aws-config/`
4. **AWS Shared Credentials** - `shared-credentials/`

## Usage

### 1. Environment Variables (`env-vars/`)
```bash
cd env-vars
# Set environment variables (modify setup.bat with your credentials)
setup.bat
terraform init
terraform plan
terraform apply
```

### 2. AWS Profile (`aws-profile/`)
```bash
cd aws-profile
# Ensure AWS CLI is configured with profiles
aws configure --profile default
terraform init
terraform plan
terraform apply
```

### 3. AWS Config File (`aws-config/`)
```bash
cd aws-config
# Use sample-config as reference for ~/.aws/config
terraform init
terraform plan
terraform apply
```

### 4. Shared Credentials (`shared-credentials/`)
```bash
cd shared-credentials
# Use sample-credentials as reference for ~/.aws/credentials
terraform init
terraform plan
terraform apply
```

## Prerequisites

- AWS CLI installed and configured
- Terraform installed
- Appropriate AWS permissions for Secrets Manager
- Valid AWS credentials configured