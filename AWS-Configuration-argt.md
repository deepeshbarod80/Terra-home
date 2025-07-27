# Setting	          # Provider	   # Environment-Variable	   # Shared Config

Access Key ID	   -  access_key	 -   AWS_ACCESS_KEY_ID	   -   aws_access_key_id

Secret Access Key  -  secret_key	 -   AWS_SECRET_ACCESS_KEY -   aws_secret_access_key

Session Token	   -   token	     -   AWS_SESSION_TOKEN	   -   aws_session_token

Region	           -   region	-   AWS_REGION/AWS_DEFAULT_REGION  -   region

Custom CA Bundle   - custom_ca_bundle  -	AWS_CA_BUNDLE         -   ca_bundle

EC2 IMDS Ep.  -  ec2_metadata_service_endpoint -  AWS_EC2_METADATA_SERVICE_ENDPOINT  -	N/A

EC2 IMDS Ep. Mode - ec2_metadata_service_endpoint_mode - AWS_EC2_METADATA_SERVICE_ENDPOINT_MODE

Disable EC2 IMDS - skip_metadata_api_check - AWS_EC2_METADATA_DISABLED  -	  N/A

HTTP Proxy	    -    http_proxy	   -   HTTP_PROXY or http_proxy	      -       N/A

HTTPS Proxy	    -    https_proxy  -   HTTPS_PROXY or https_proxy	-         N/A

Non-Proxied Hosts -	no_proxy	  -   NO_PROXY or no_proxy	       -          N/A

Max Retries	   -    max_retries   -   AWS_MAX_ATTEMPTS           -       max_attempts

Profile	       -    profile	  -  AWS_PROFILE or AWS_DEFAULT_PROFILE    -      N/A

Retry Mode	   -   retry_mode	-     AWS_RETRY_MODE	           -      retry_mode

Shared-Config Files	- shared_config_files - AWS_CONFIG_FILE	       -          N/A

Shared Credentials Files - shared_credentials_files - AWS_SHARED_CREDENTIALS_FILE - N/A

S3 Use Regional Endpoint for us-east-1 - s3_us_east_1_regional_endpoint - AWS_S3_US_EAST_1_REGIONAL_ENDPOINT -	s3_us_east_1_regional_endpoint

Use DualStack Endpoints	- use_dualstack_endpoint - AWS_USE_DUALSTACK_ENDPOINT	- use_dualstack_endpoint

Use FIPS Endpoints -  use_fips_endpoint -  AWS_USE_FIPS_ENDPOINT -  use_fips_endpoint

--------------------------------------------------------------------------------------->


2. ec2 creation with already exit VPC and it's components
# main.tf
```bash
# Configure Terraform and AWS provider
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.2.0"
    }
  }
}

# Configure the AWS provider
provider "aws" {
  region = "us-east-1" # Replace with your AWS region
}

# Data source to fetch the existing VPC
data "aws_vpc" "existing_vpc" {
  id = "vpc-06d8ae514de493289" # Replace with your VPC ID
}

# Data source to fetch the existing subnet
data "aws_subnet" "existing_subnet" {
  id = "subnet-0081815f04e39bf10" # Replace with your subnet ID
}

# Data source to fetch the existing Security Group
data "aws_security_group" "existing_sg" {
  id = "sg-02f4f3fd75742985a" # Replace with your Security Group ID
}

# Data source to fetch the existing key pair
data "aws_key_pair" "existing_key_pair" {
  key_name = "test-key" # Replace with your key pair name
}

# Optional: Data source to fetch the existing Internet Gateway (for validation)
data "aws_internet_gateway" "existing_igw" {
  internet_gateway_id = "igw-0e98f6d953ce18e09" # Replace with your IGW ID
}

# Create the EC2 instance
resource "aws_instance" "example" {
  ami           = "ami-084568db4383264d4" # Replace with a valid AMI ID for your region (e.g., Amazon Linux 2)
  instance_type = "t2.micro"              # Replace with desired instance type
  subnet_id     = data.aws_subnet.existing_subnet.id
  vpc_security_group_ids = [
    data.aws_security_group.existing_sg.id
  ]
  key_name = data.aws_key_pair.existing_key_pair.key_name

  # Optional: Add tags
  tags = {
    Name = "example-ec2"
    Environment = "prod"
  }

  # Optional: Enable public IP if the subnet is public
  associate_public_ip_address = true # Set to false if using a private subnet
}

# Output the EC2 instance details
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.example.id
}

output "instance_public_ip" {
  description = "Public IP of the EC2 instance (if applicable)"
  value       = aws_instance.example.public_ip
}
```