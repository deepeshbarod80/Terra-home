1. Setup & Initialization
1) Install Terraform
// for Linux & macOS
# wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
----->
# echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
----->
# sudo apt update && sudo apt install terraform
----------------------------------------------------->
- Verify Installation
terraform -v

''' Initialize Terraform '''
# terraform init 
- Downloads provider plugins
- Sets up the working directory

2. ''' Terraform Core Commands '''
1) Format & Validate Code;
- Formats Terraform code
# terraform fmt
- Validates Terraform syntax      
# terraform validate 

2) Plan & Apply Infrastructure
- Shows execution plan without applying
# terraform plan
- Creates/updates infrastructure
# terraform apply
- Applies without manual confirmation
# terraform apply -auto-approve

3) Destroy Infrastructure
- Destroys all managed resources
# terraform destroy
- Destroy without manual confirmation
# terraform destroy -auto-approve


3. ''' Elements of Terraform '''
------>  <Blocks>         What you want to create (Resource, Provider, Module, Variales, Output)
------>  <Parameters>     What you declare in configuration files
------>  <Arguments>      What is written in configuration files
------>  <Attributes>     What is Result of arguments inside configuration files after execution

// Block types;
------>  <Resources>      What you want to create
------>  <Output>         What is Final Output of Configuration
------>  <Variables>      What arguments you want to pass
------>  <Providers>      What resources you want to use from which provider(Cloud)
------>  <Modules>        What Variables you want to pass
------>  <Provisioners>   What 
------>  <Data Sources>   What you want to fetch from external sources
------>  <Locals>         What you want to pass locally
------>  <Connection>     What you want to connect to 



__________________________________
resource local_file my_file {
    filename = "automate terraform"
    content = "Hello World"
}
__________________________________
Here:
- resource = block
- local = provider
- local_file = resource type
- my_file = resource name or identifier
- filename & content = arguments
- "Hello world" = output


4. ''' Built-in Block Types (Core Terraform) '''
1) terraform – Configures Terraform settings (backend, required providers, etc.).
----------------->
terraform {
  required_version = ">= 1.0.0"
  backend "s3" { ... }
}
----------------->

2) provider – Configures a cloud/service provider (AWS, Azure, GCP, etc.).
----------------->
provider "aws" {
  region = "us-east-1"
}
----------------->

3) resource – Defines an infrastructure object (e.g., VM, network, database).
----------------->
resource "aws_instance" "web" { ... }
----------------->

4) data – Fetches external data (e.g., AMI IDs, existing resources).
----------------->
data "aws_ami" "ubuntu" { ... }
----------------->

5) module – Calls a reusable Terraform module.
----------------->
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
}
----------------->

6) variable – Declares input variables.
----------------->
variable "instance_type" {
  type = string
}
----------------->

7) output – Exports values for other modules or terraform output.
----------------->
output "instance_ip" {
  value = aws_instance.web.private_ip
}
----------------->

8) locals – Defines local variables for reuse.
----------------->
locals {
  env = "prod"
}
----------------->
________________________________________________________________________________

"dot-object-notation" or "interpolation"


5. 




