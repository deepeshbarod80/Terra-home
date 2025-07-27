

project/
├── modules/
│   ├── vpc/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   ├── transit_gateway/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   ├── eks/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   ├── load_balancer/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   ├── security/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   ├── route53/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   ├── ecr/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── terraform.tfvars
│   │   ├── backend.tf
│   ├── stage/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── terraform.tfvars
│   │   ├── backend.tf
│   ├── pre-prod/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── terraform.tfvars
│   │   ├── backend.tf
│   ├── prod/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── terraform.tfvars
│   │   ├── backend.tf
│   ├── shared-services/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── terraform.tfvars
│   │   ├── backend.tf
├── main.tf
├── variables.tf
├── provider.tf
├── backend.tf


modules/: Reusable modules for VPC, Transit Gateway, EKS, load balancers, security (WAF, Shield, KMS, etc.), Route 53, and ECR.
environments/: Environment-specific configurations (Dev, Stage, Pre-prod, Prod, Shared Services) with terraform.tfvars for variables.
Root Files: Global provider and backend configurations.



# Architecture Overview
1) Environments: `Dev`, `Stage`, `Pre-prod`, and `Prod`, each in a separate VPC and AWS region for isolation and compliance.
2) Regions: Deploy each environment in a different region for geographic distribution and resilience ( `us-east-1` for `Prod`, `us-west-2` for `Pre-prod`, `eu-west-1` for `Stage`, `ap-south-1` for `Dev`).
3) Connectivity: Use AWS Transit Gateway for inter-VPC and cross-region connectivity, supplemented by VPC Endpoints and PrivateLink for secure access to AWS services.
4) Security: Implement `Bastion Hosts`, `NAT Gateways`, `NACLs`, `WAF`, `Shield`, `KMS`, and `Secrets Manager` to ensure a secure environment.
5) Application: The web application runs on EKS, with container images in `ECR`, load-balanced by `ALB`/`NLB`, and exposed via `API Gateway` and `Route 53`.


``` Step-by-Step Implementation ```
* 

1. Plan the VPC Structure
--------------->
# Define VPCs and Regions:
- Prod VPC: Tag = `prod-vpc`, region = `us-east-1`, CIDR = `10.0.0.0/16`
- Pre-prod VPC: Tag = `pre-prod-vpc`, region = `us-west-2`, CIDR = `10.1.0.0/16`
- Stage VPC: Tag = `stage-vpc`, region = `eu-west-1`, CIDR = `10.2.0.0/16`
- Dev VPC: Tag = `dev-vpc`, region = `ap-south-1`, CIDR = `10.3.0.0/16`
- Shared Services VPC: Tag = `shared-services-vpc`, region = `us-east-1`, CIDR = `10.4.0.0/16` 
  (for centralized services like `logging or monitoring`).

# Create `VPCs`:
- In the AWS Management Console, navigate to the VPC service in each region.
- Create a VPC for each environment with the specified CIDR block.
- Enable DNS hostnames and DNS resolution for each VPC.

# Create `Subnets (per VPC, across at least two Availability Zones for high availability)`:
- `Public Subnets`: For resources like ALB, NAT Gateway, Bastion Host (e.g., `10.0.1.0/24` in us-east-1a, `10.0.2.0/24` in us-east-1b).
- `Private Subnets`: For EKS, EC2, or application servers (e.g., `10.0.3.0/24` in us-east-1a, `10.0.4.0/24` in us-east-1b).
- `Database Subnets`: For RDS or other databases (e.g., `10.0.5.0/24` in us-east-1a, `10.0.6.0/24` in us-east-1b).
- Repeat for each VPC in its respective region, adjusting CIDR blocks (e.g., 10.1.x.x for Pre-prod).

# Set Up `Internet Gateway (IGW)`:
- In each VPC, create an Internet Gateway and attach it to the VPC.
- Update the public subnet route table to route `0.0.0.0/0` to the IGW for internet access.

# Set Up `NAT Gateway`:
- In each VPC, create a `NAT Gateway` in one public subnet (e.g., `us-east-1a`).
- Update the private subnet route tables to route `0.0.0.0/0` to the NAT Gateway, allowing private resources to access the internet for updates.


---


2. Configure Transit Gateway for Cross-Region Connectivity
---------------> 
# Create a `Transit Gateway`:
- In the AWS Management Console, go to the VPC service in a central region (e.g., us-east-1).
- Create a `Transit Gateway` (e.g., “App-Transit-Gateway”).
- Enable cross-region peering by attaching the Transit Gateway to other regions (`us-west-2`, `eu-west-1`, `ap-south-1`).

# Attach `VPCs` to `Transit Gateway`:
- In each region, attach the VPC (`Prod`, `Pre-prod`, `Stage`, `Dev`, `Shared Services`) to the Transit Gateway.
- For each VPC, specify the subnets (usually private subnets) to associate with the Transit Gateway.

# Configure Transit Gateway Route Tables:
- Create a Transit Gateway route table (e.g., “Main-Route-Table”).
- Add routes to allow traffic between VPCs:
=> Route `10.1.0.0/16` (Pre-prod) to the Pre-prod VPC attachment.
=> Route `10.2.0.0/16` (Stage) to the Stage VPC attachment.
=> Route `10.3.0.0/16` (Dev) to the Dev VPC attachment.
=> Route `10.4.0.0/16` (Shared Services) to the Shared Services VPC attachment.
- Propagate routes from each VPC to the Transit Gateway route table.

# Update `VPC Route Tables`:
- In each VPC’s private subnet route table, add routes for other VPC CIDRs pointing to the Transit Gateway:
=> E.g., in `Prod VPC (10.0.0.0/16)`, add `10.1.0.0/16` → `Transit Gateway`, `10.2.0.0/16` → `Transit Gateway`, etc.


---


3. Set Up VPC Endpoints and PrivateLink
--------------->
# Gateway VPC Endpoints:
- In each `VPC`, create `Gateway Endpoints` for `S3` and `DynamoDB`.
- Associate the `endpoints` with the `private subnet route tables`.
- This allows `private subnets` to access `S3` and `DynamoDB` without `internet access`.

# Interface VPC Endpoints:
- Create `Interface Endpoints` for services like `AWS Secrets Manager`, `ECR`, and `API Gateway` in each `VPC`.
- Place `endpoints` in `private subnets` and assign `Security Groups` to allow traffic from `EKS` or `EC2` instances.
- Update `route tables` to route traffic to these `endpoints` within the `VPC`.

# PrivateLink:
- In the `Shared Services VPC`, set up `PrivateLink` for a centralized service (e.g., a monitoring tool or internal API).
- Create an `Endpoint Service` in the `Shared Services VPC` and allow other VPCs (Prod, Pre-prod, etc.) to access it.
- In each `consumer VPC` (e.g., Prod), create an `Interface Endpoint` pointing to the `PrivateLink service` in the `Shared Services VPC`.
- Update `Security Groups` and `route tables` to allow traffic to the `PrivateLink endpoint`.


---


4. Configure Bastion Host for Secure Access
--------------->
# Create Bastion Host:
- In each `VPC’s public subnet`, launch an EC2 instance as a `Bastion Host` (e.g., Amazon Linux 2).
- Assign a `Security Group allowing SSH (port 22)` from your `trusted IP range` (e.g., your office IP).
- Disable public access to private subnet resources except via the Bastion Host.

# Access Private Resources:
- Use the Bastion Host to SSH into EC2 instances or EKS worker nodes in private subnets.
- Configure SSH agent forwarding or a jump host setup for secure access.


---


5. Set Up Network Access Control Lists (NACLs)
--------------->
1) Create NACLs for Each Subnet Type:
# Public Subnet NACL:
- Allow inbound `HTTP/HTTPS (ports 80, 443)` from `0.0.0.0/0` for `ALB`.
- Allow inbound `SSH (port 22)` from your `trusted IP` for the `Bastion Host`.
- Allow outbound to private subnet CIDRs and 0.0.0.0/0 for NAT Gateway.

# Private Subnet NACL:
- Allow inbound from `public subnet CIDR` (for `ALB`, `Bastion Host`) and other VPC CIDRs via `Transit Gateway`.
- Allow outbound to `S3/DynamoDB` via `Gateway Endpoints` and to the `internet` via `NAT Gateway`.

# Database Subnet NACL:
- Allow inbound from `private subnet CIDR` (for application access to `RDS`).
- Allow outbound to `private subnet CIDR` only.

2) Apply NACLs:
- Associate each `NACL` with the appropriate subnets in each VPC.
- Ensure rules are numbered sequentially (e.g., 100, 200) and include a default deny rule at the end.


---


6. Configure Route 53 for DNS
--------------->
# Create Hosted Zones:
- In `Route 53`, create a `public hosted zone` for your domain (e.g., `example.com`).
- Create `private hosted zones` for each VPC (e.g., `prod.example.com`, `dev.example.com`) for internal DNS resolution.

# Set Up DNS Records:
- Add an A record in the `public hosted zone` pointing to the `ALB’s DNS name` (e.g., `web.example.com` → `ALB`).
- Add a CNAME record for APIs pointing to API Gateway (e.g., api.example.com).
- In private hosted zones, add records for internal resources (e.g., rds.prod.example.com → RDS endpoint).

# Health Checks:
- Configure Route 53 health checks for the ALB to ensure traffic routes to healthy instances.
- Use latency-based routing for multi-region traffic distribution.


---


7. Deploy Load Balancers (ALB and NLB)
--------------->
# Application Load Balancer (ALB):
- In each VPC’s public subnets, create an ALB.
- Configure listeners for HTTP (port 80, redirect to HTTPS) and HTTPS (port 443, using an ACM cert.).
- Create Target Groups for EKS pods or EC2 instances in private subnets.
- Set up path-based routing (e.g., /api → backend Target Group, / → frontend Target Group).

# Network Load Balancer (NLB):
- In each VPC’s public subnets, create an NLB for TCP/UDP traffic (e.g., WebSockets).
- Configure Target Groups pointing to EKS worker nodes or specific EC2 instances.
- Enable cross-zone load balancing for even traffic distribution across AZs.


---


8. Deploy EKS and ECR
--------------->
# Create ECR Repositories:
- In each region, create an ECR repository for container images (e.g., prod-app, dev-app).
- Push Docker images to ECR for use by EKS.

# Set Up EKS Cluster:
- In each VPC’s private subnets, create an EKS cluster.
- Use managed node groups (EC2) or Fargate for worker nodes.
- Install the AWS VPC CNI plugin to assign VPC IPs to pods.
- Configure EKS to pull images from ECR via a VPC Endpoint.

# Deploy Application:
Deploy the web application (frontend and backend) as Kubernetes deployments in EKS.
Use Kubernetes Services to expose pods to the ALB or NLB via Target Groups.


---

9. Configure Auto Scaling
--------------->
# EC2 Auto Scaling Groups:
- For EKS worker nodes or standalone EC2 instances, create Auto Scaling Groups in private subnets.
- Set scaling policies based on CloudWatch metrics (e.g., CPU > 70% to scale out).
- Register instances with ALB/NLB Target Groups.

# EKS Cluster Autoscaler:
- Enable the Cluster Autoscaler in EKS to scale worker nodes based on pod demand.
- Configure node groups to span multiple AZs for resilience.


---


10. Implement Security with WAF, Shield, KMS, and Secrets Manager
--------------->
# WAF:
- Create a WAF Web ACL and associate it with the ALB and API Gateway in each VPC.
- Add rules to block SQL injection, XSS, or rate-limit requests from specific IPs.

# AWS Shield:
- Enable AWS Shield Standard for ALB and NLB (automatic, free).
- Optionally, subscribe to AWS Shield Advanced for enhanced DDoS protection.

# ACM:
- In each region, create SSL/TLS certificates in ACM for ALB, NLB, and API Gateway.
- Associate certificates with listeners to enable HTTPS.

# KMS:
- Create KMS keys in each region for encrypting data in S3, RDS, and EBS.
- Grant EKS and EC2 IAM roles access to KMS for decryption.

# Secrets Manager:
- Store sensitive data (e.g., RDS credentials, API keys) in Secrets Manager.
- Configure EKS to retrieve secrets via a VPC Endpoint.


---


11. Set Up API Gateway
--------------->
# Create API Gateway:
- In each region, create a REST or WebSocket API in API Gateway.
- Configure private integrations to route requests to the ALB or NLB in the same VPC.
- Secure APIs with IAM roles, Cognito, or Lambda authorizers.

# DNS Mapping:
- Map API Gateway to a subdomain (e.g., api.example.com) using a Route 53 CNAME record.


---


12. Monitoring and Logging
# CloudWatch:
- Enable logging for ALB, NLB, EKS, and EC2.
- Create CloudWatch alarms for metrics like high latency or error rates to trigger scaling.

# VPC Flow Logs:
- Enable Flow Logs for each VPC to capture network traffic metadata.
- Store logs in S3 or CloudWatch Logs via a VPC Endpoint.



--------------------------------------------------------------------------------------->


# How It All Works Together from user to end resource
- A user accesses example.com, resolved by Route 53 to the Prod ALB in us-east-1.
- The ALB, secured by WAF and Shield, routes traffic to EKS pods in private subnets via a Target Group.
- EKS pods pull images from ECR and access RDS or Secrets Manager via VPC Endpoints.
- If Dev (ap-south-1) needs to access a monitoring tool in the Shared Services VPC (us-east-1), traffic flows through the Transit Gateway.
- Admins use the Bastion Host to SSH into private resources securely.
- NACLs and Security Groups restrict traffic, while KMS and Secrets Manager secure data.
- Auto Scaling ensures resources scale with demand, and CloudWatch monitors performance.


# Best Practices
- Tagging: Tag all resources (e.g., Environment=Prod, Project=WebApp) for cost tracking.
- Security: Use least-privilege IAM roles and lock down Security Groups/NACLs.
- High Availability: Deploy resources across multiple AZs in each region.
- Backup: Enable backups for RDS and versioning for S3.
- Testing: Start with Dev, validate connectivity, then replicate for Stage, Pre-prod, and Prod.




``` AWS Multi-Region Networking Architecture for Web Application ```
# Overview
This architecture deploys a web application across Dev, Stage, Pre-prod, and Prod environments in different AWS regions, connected via Transit Gateway, with secure access using VPC Endpoints, PrivateLink, Bastion Hosts, and advanced services like ALB, NLB, EKS, and WAF.

1. VPC Structure
--------------->
# Prod VPC:
Region & CIDR: `us-east-1` and `10.0.0.0/16`
Public Subnets: `10.0.1.0/24`, `10.0.2.0/24`
Private Subnets: `10.0.3.0/24`, `10.0.4.0/24`
Database Subnets: `10.0.5.0/24`, `10.0.6.0/24`

# Pre-prod VPC:
Region & CIDR: `us-west-2`, and `10.1.0.0/16`
Public Subnets: `10.1.1.0/24`, `10.1.2.0/24`
Private Subnets: `10.1.3.0/24`, `10.1.4.0/24`
Database Subnets: `10.1.5.0/24`, `10.1.6.0/24`

# Stage VPC:
Region & CIDR: `eu-west-1`, and `10.2.0.0/16`
Public Subnets: `10.2.1.0/24`, `10.2.2.0/24`
Private Subnets: `10.2.3.0/24`, `10.2.4.0/24`
Database Subnets: `10.2.5.0/24`, `10.2.6.0/24`

# Dev VPC:
Region & CIDR: `ap-south-1`, and `10.3.0.0/16`
Public Subnets: `10.3.1.0/24`, `10.3.2.0/24`
Private Subnets: `10.3.3.0/24`, `10.3.4.0/24`
Database Subnets: `10.5.5.0/24`, `10.3.6.0/24`

# Shared Services VPC:
Region & CIDR: `us-east-1`, and `10.4.0.0/16`
Public Subnets: `10.4.1.0/24`, `10.4.2.0/24`
Private Subnets: `10.4.3.0/24`, `10.4.4.0/24`
Database Subnets: `10.4.5.0/24`, `10.4.6.0/24`


2. Steps to Implement
--------------->
# Create VPCs: 
Set up VPCs in each region with subnets, IGW, and NAT Gateway.

# Transit Gateway: 
Create and attach VPCs, configure route tables for cross-region connectivity.

# VPC Endpoints: 
Add Gateway Endpoints for S3/DynamoDB and Interface Endpoints for Secrets Manager/ECR.

# PrivateLink: 
Expose Shared Services VPC resources to other VPCs.

# Bastion Host: 
Deploy EC2 in public subnets for secure SSH access.

# NACLs: 
Configure rules to restrict traffic by subnet type.

# Route 53: 
Set up public/private hosted zones and DNS records.

# ALB/NLB: 
Deploy load balancers with Target Groups for EKS/EC2.

# EKS/ECR: 
Deploy EKS clusters and store images in ECR.

# Auto Scaling: 
Configure scaling for EC2 and EKS nodes.

# Security: 
Apply WAF, Shield, ACM, KMS, and Secrets Manager.

# API Gateway: 
Expose APIs with private integrations.

# Monitoring: 
Enable CloudWatch and VPC Flow Logs.


----------------------------------------------------------------------->






