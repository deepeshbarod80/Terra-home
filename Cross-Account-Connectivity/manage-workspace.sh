#!/bin/bash
# Bash script for managing Terraform workspaces

usage() {
    echo "Usage: $0 <environment> <action>"
    echo "Environments: dev, staging, prod"
    echo "Actions: plan, apply, destroy, show"
    exit 1
}

if [ $# -ne 2 ]; then
    usage
fi

ENVIRONMENT=$1
ACTION=$2

# Validate environment
case $ENVIRONMENT in
    dev|staging|prod)
        ;;
    *)
        echo "Invalid environment: $ENVIRONMENT"
        usage
        ;;
esac

# Validate action
case $ACTION in
    plan|apply|destroy|show)
        ;;
    *)
        echo "Invalid action: $ACTION"
        usage
        ;;
esac

echo "Managing workspace: $ENVIRONMENT"
echo "Action: $ACTION"

# Select workspace
echo "Selecting workspace: $ENVIRONMENT"
terraform workspace select $ENVIRONMENT

if [ $? -ne 0 ]; then
    echo "Workspace $ENVIRONMENT doesn't exist. Creating it..."
    terraform workspace new $ENVIRONMENT
    terraform workspace select $ENVIRONMENT
fi

# Execute action
VAR_FILE="terraform.$ENVIRONMENT.tfvars"

case $ACTION in
    plan)
        echo "Running terraform plan for $ENVIRONMENT..."
        terraform plan -var-file="$VAR_FILE"
        ;;
    apply)
        echo "Running terraform apply for $ENVIRONMENT..."
        terraform apply -var-file="$VAR_FILE"
        ;;
    destroy)
        echo "Running terraform destroy for $ENVIRONMENT..."
        echo "WARNING: This will destroy all resources in $ENVIRONMENT environment!"
        read -p "Are you sure? (yes/no): " confirm
        if [ "$confirm" = "yes" ]; then
            terraform destroy -var-file="$VAR_FILE"
        else
            echo "Destroy cancelled."
        fi
        ;;
    show)
        echo "Current workspace: $(terraform workspace show)"
        echo "Available workspaces:"
        terraform workspace list
        ;;
esac

echo "Operation completed."