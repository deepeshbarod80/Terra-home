@echo off
echo Setting up AWS credentials via environment variables...
set AWS_ACCESS_KEY_ID=your-access-key-id
set AWS_SECRET_ACCESS_KEY=your-secret-access-key
set AWS_DEFAULT_REGION=us-east-1

echo Environment variables set. Run terraform commands now.
echo Example: terraform init && terraform plan && terraform apply