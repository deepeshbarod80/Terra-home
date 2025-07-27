# AWS to GCP Site-to-Site VPN Configuration

This Terraform configuration establishes a site-to-site VPN connection between a private subnet in an AWS VPC and a private subnet in a Google Cloud VPC.

## Architecture

The setup creates:

- AWS VPC with a private subnet
- AWS Virtual Private Gateway
- AWS Customer Gateway (pointing to GCP VPN Gateway)
- AWS VPN Connection
- GCP VPC with a private subnet
- GCP VPN Gateway
- GCP VPN Tunnel
- Appropriate routes in both clouds

## Prerequisites

- AWS account with appropriate permissions
- GCP account with appropriate permissions
- Terraform installed (version >= 1.0)
- AWS CLI configured
- GCP authentication configured

## Usage

1. Clone this repository
2. Copy `terraform.tfvars.example` to `terraform.tfvars` and update with your values:
   ```
   cp terraform.tfvars.example terraform.tfvars
   ```
3. Update the `terraform.tfvars` file with your specific configuration values
4. Initialize Terraform:
   ```
   terraform init
   ```
5. Plan the deployment:
   ```
   terraform plan
   ```
6. Apply the configuration:
   ```
   terraform apply
   ```

## Important Notes

- The VPN connection uses static routing
- The AWS VPN connection creates two tunnels for redundancy, but this configuration only uses the first tunnel
- You may need to adjust firewall rules in both clouds to allow traffic between the subnets
- For production use, consider implementing additional security measures

## Testing the Connection

After deployment, you can test the VPN connection by:

1. Launching an EC2 instance in the AWS private subnet
2. Launching a VM instance in the GCP private subnet
3. Configuring security groups/firewall rules to allow ICMP traffic
4. Pinging between the instances

## Cleanup

To destroy all resources created by this configuration:

```
terraform destroy
```