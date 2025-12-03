# Terraform Workspace Management Commands

## Initialize and Setup Backend
```bash
# Initialize Terraform (run once)
terraform init

# Configure backend (optional - can be done via backend config file)
terraform init -backend-config="bucket=your-terraform-state-bucket" \
               -backend-config="key=cross-account-connectivity/terraform.tfstate" \
               -backend-config="region=us-east-1"
```

## Workspace Operations

### List Workspaces
```bash
terraform workspace list
```

### Create and Switch to Development Workspace
```bash
terraform workspace new dev
terraform workspace select dev
```

### Create and Switch to Staging Workspace
```bash
terraform workspace new staging
terraform workspace select staging
```

### Create and Switch to Production Workspace
```bash
terraform workspace new prod
terraform workspace select prod
```

## Deploy to Specific Environment

### Development Environment
```bash
terraform workspace select dev
terraform plan -var-file="terraform.dev.tfvars"
terraform apply -var-file="terraform.dev.tfvars"
```

### Staging Environment
```bash
terraform workspace select staging
terraform plan -var-file="terraform.staging.tfvars"
terraform apply -var-file="terraform.staging.tfvars"
```

### Production Environment
```bash
terraform workspace select prod
terraform plan -var-file="terraform.prod.tfvars"
terraform apply -var-file="terraform.prod.tfvars"
```

## Destroy Environment
```bash
# Select the workspace first
terraform workspace select dev
terraform destroy -var-file="terraform.dev.tfvars"
```

## Show Current Workspace
```bash
terraform workspace show
```

## State Management
Each workspace maintains its own state file:
- `workspaces/dev/terraform.tfstate`
- `workspaces/staging/terraform.tfstate`
- `workspaces/prod/terraform.tfstate`

## Resource Naming Convention
Resources are automatically named with workspace/environment suffix:
- S3 Bucket: `cross-account-bucket-{account_id}-{environment}`
- VPC: `account1-vpc-{environment}`
- EC2: `account1-ec2-{environment}`