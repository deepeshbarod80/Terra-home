# Cross-Account S3 and EC2 Connection Setup

This Terraform script creates infrastructure to connect S3 buckets and EC2 instances across different AWS accounts and regions.

## Prerequisites

1. **Two AWS Accounts** with appropriate permissions
2. **Cross-account IAM roles** set up in both accounts
3. **Terraform** installed (version 1.0+)
4. **AWS CLI** configured with appropriate credentials

## Setup Steps

### 1. Create Cross-Account IAM Roles

In both AWS accounts, create an IAM role named `CrossAccountAccessRole` with the following trust policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::TRUSTED-ACCOUNT-ID:root"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

Attach the following policies:
- `PowerUserAccess` or custom policies with EC2, S3, VPC, and IAM permissions

### 2. Configure Backend (Optional)

Update `backend.conf` with your S3 bucket details:
```hcl
bucket = "your-terraform-state-bucket"
key    = "cross-account-connectivity/terraform.tfstate"
region = "us-east-1"
workspace_key_prefix = "workspaces"
```

### 3. Configure Environment Variables

Update the environment-specific `.tfvars` files:
- `terraform.dev.tfvars` - Development environment
- `terraform.staging.tfvars` - Staging environment  
- `terraform.prod.tfvars` - Production environment

Example configuration:
```hcl
account1_id = "YOUR-ACCOUNT-1-ID"
account2_id = "YOUR-ACCOUNT-2-ID"
primary_region = "us-east-1"
secondary_region = "us-west-2"
cross_account_role = "CrossAccountAccessRole"
environment = "dev"
```

### 4. Deploy Infrastructure Using Workspaces

```bash
# Initialize Terraform
terraform init -backend-config="backend.conf"

# Create and select workspace
terraform workspace new dev
terraform workspace select dev

# Plan and apply for development
terraform plan -var-file="terraform.dev.tfvars"
terraform apply -var-file="terraform.dev.tfvars"
```

#### For Other Environments:

**Staging:**
```bash
terraform workspace new staging
terraform workspace select staging
terraform apply -var-file="terraform.staging.tfvars"
```

**Production:**
```bash
terraform workspace new prod
terraform workspace select prod
terraform apply -var-file="terraform.prod.tfvars"
```

## What Gets Created

### Account 1 (Primary):
- **S3 Bucket** with cross-account access policy
- **VPC** with public subnet, IGW, and route table
- **EC2 Instance** with IAM role for S3 access
- **Security Groups** for web and SSH access

### Account 2 (Secondary):
- **VPC** with public subnet, IGW, and route table
- **EC2 Instance** with cross-account S3 access
- **Security Groups** for web and SSH access

### Cross-Account Resources:
- **VPC Peering Connection** between accounts
- **IAM Policies** for cross-account S3 access
- **S3 Bucket Policies** allowing cross-account access

## Testing the Setup

1. **SSH into EC2 instances** (use key pairs created during setup)
2. **Test S3 access** from both instances:
   ```bash
   aws s3 ls s3://cross-account-bucket-ACCOUNT1ID-dev
   ```
3. **Test file upload/download** between accounts
4. **Access web servers** via public IPs

## Security Considerations

- **Least Privilege**: IAM roles have minimal required permissions
- **Network Security**: Security groups restrict access to necessary ports
- **Encryption**: Enable S3 bucket encryption for production use
- **VPC Flow Logs**: Enable for network monitoring
- **CloudTrail**: Enable for API call logging

## Workspace Management

### List Workspaces
```bash
terraform workspace list
```

### Switch Between Workspaces
```bash
terraform workspace select dev
terraform workspace select staging
terraform workspace select prod
```

### Show Current Workspace
```bash
terraform workspace show
```

## Cleanup

To destroy resources in a specific environment:
```bash
# Select the workspace first
terraform workspace select dev
terraform destroy -var-file="terraform.dev.tfvars"
```

## Troubleshooting

### Common Issues:

1. **Cross-account role assumption fails**
   - Verify trust relationships in IAM roles
   - Check account IDs in terraform.tfvars

2. **S3 access denied**
   - Verify bucket policy allows cross-account access
   - Check IAM policies on EC2 instance roles

3. **VPC peering connection fails**
   - Ensure CIDR blocks don't overlap
   - Check route table configurations

4. **EC2 instances can't communicate**
   - Verify security group rules
   - Check VPC peering connection status

## Architecture Diagram

```
Account 1 (us-east-1)          Account 2 (us-west-2)
┌─────────────────────┐       ┌─────────────────────┐
│ VPC: 10.1.0.0/16    │◄─────►│ VPC: 10.2.0.0/16    │
│ ┌─────────────────┐ │       │ ┌─────────────────┐ │
│ │ EC2 Instance    │ │       │ │ EC2 Instance    │ │
│ │ + IAM Role      │ │       │ │ + Cross-Acc Role│ │
│ └─────────────────┘ │       │ └─────────────────┘ │
│ ┌─────────────────┐ │       │                     │
│ │ S3 Bucket       │ │◄──────┼─────────────────────┤
│ │ + Cross-Acc     │ │       │                     │
│ │   Policy        │ │       │                     │
│ └─────────────────┘ │       │                     │
└─────────────────────┘       └─────────────────────┘
```

## Files Structure

- `cross-account-s3-ec2-connection.tf` - Main Terraform configuration
- `user_data.sh` - Bootstrap script for Account 1 EC2
- `user_data_account2.sh` - Bootstrap script for Account 2 EC2
- `backend.conf` - Backend configuration for state management
- `terraform.dev.tfvars` - Development environment variables
- `terraform.staging.tfvars` - Staging environment variables
- `terraform.prod.tfvars` - Production environment variables
- `terraform.tfvars.example` - Example variables file
- `workspace-commands.md` - Workspace management commands
- `cross-account-setup-README.md` - This documentation

## Workspace Benefits

- **Isolated State**: Each environment has separate state files
- **Resource Isolation**: Resources are named with environment suffix
- **Easy Switching**: Quick environment switching with workspace commands
- **Consistent Tagging**: Automatic environment and workspace tagging
- **Scalable**: Easy to add new environments