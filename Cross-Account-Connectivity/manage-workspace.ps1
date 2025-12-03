# PowerShell script for managing Terraform workspaces
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("dev", "staging", "prod")]
    [string]$Environment,
    
    [Parameter(Mandatory=$true)]
    [ValidateSet("plan", "apply", "destroy", "show")]
    [string]$Action
)

Write-Host "Managing workspace: $Environment" -ForegroundColor Green
Write-Host "Action: $Action" -ForegroundColor Yellow

# Select workspace
Write-Host "Selecting workspace: $Environment" -ForegroundColor Cyan
terraform workspace select $Environment

if ($LASTEXITCODE -ne 0) {
    Write-Host "Workspace $Environment doesn't exist. Creating it..." -ForegroundColor Yellow
    terraform workspace new $Environment
    terraform workspace select $Environment
}

# Execute action
$varFile = "terraform.$Environment.tfvars"

switch ($Action) {
    "plan" {
        Write-Host "Running terraform plan for $Environment..." -ForegroundColor Cyan
        terraform plan -var-file="$varFile"
    }
    "apply" {
        Write-Host "Running terraform apply for $Environment..." -ForegroundColor Cyan
        terraform apply -var-file="$varFile"
    }
    "destroy" {
        Write-Host "Running terraform destroy for $Environment..." -ForegroundColor Red
        Write-Host "WARNING: This will destroy all resources in $Environment environment!" -ForegroundColor Red
        $confirm = Read-Host "Are you sure? (yes/no)"
        if ($confirm -eq "yes") {
            terraform destroy -var-file="$varFile"
        } else {
            Write-Host "Destroy cancelled." -ForegroundColor Yellow
        }
    }
    "show" {
        Write-Host "Current workspace: $(terraform workspace show)" -ForegroundColor Green
        Write-Host "Available workspaces:" -ForegroundColor Green
        terraform workspace list
    }
}

Write-Host "Operation completed." -ForegroundColor Green