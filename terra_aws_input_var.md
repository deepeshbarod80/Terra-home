Here’s a categorized list of **commonly used Terraform input variables** for creating various AWS resources. These variables are generally used in the `resource` blocks and can also be defined in `variables.tf` or passed via `terraform.tfvars`.

---

✅ **1. Network Resources (VPC, Subnets, Route Tables, Gateways)**

# VPC
```bash
variable "vpc_cidr_block" {}
variable "vpc_name" {}
variable "enable_dns_support" {}
variable "enable_dns_hostnames" {}
```

# Subnets
```bash
variable "public_subnet_cidrs" {}
variable "private_subnet_cidrs" {}
variable "availability_zones" {}
```

# Internet Gateway / NAT Gateway
```bash
variable "create_igw" {}
variable "igw_name" {}
variable "igw_tags" {}
variable "igw_vpc_attachment" {}
variable "nat_gateway_vpc_attachment" {}
variable "create_nat_gateway" {}
variable "elastic_ip_allocation" {}
```

# Transit Gateway
```bash
variable "transit_gateway_name" {}
variable "transit_gateway_cidr_block" {}
variable "transit_gateway_amazon_side_asn" {}
variable "transit_gateway_options" {}
variable "transit_gateway_attachments" {}
variable "transit_gateway_routes" {}
variable "transit_gateway_route_tables" {}
variable "transit_gateway_vpcs" {}
variable "transit_gateway_tags" {}
```

# Transit Gateway Route Tables
```bash
variable "transit_gateway_route_table_name" {}
variable "transit_gateway_route_table_routes" {}
variable "transit_gateway_route_table_tags" {}
variable "transit_gateway_route_table_associations" {}
```

# Transit Gateway Attachments
```bash
variable "transit_gateway_attachment_name" {}
variable "transit_gateway_attachment_options" {}
variable "transit_gateway_attachment_tags" {}
variable "transit_gateway_attachment_vpc_attachments" {}


# Route Tables
```bash
variable "route_to_igw" {}
variable "route_to_nat" {}
```

# Route Table Associations
```bash
variable "public_route_table_association" {}
variable "private_route_table_association" {}
variable "transit_gateway_route_table_association" {}
variable "internet_gateway_route_table_association" {}
variable "nat_gateway_route_table_association" {}
```

# Security Groups
```bash
variable "security_group_name" {}
variable "security_group_description" {}
variable "security_group_ingress" {}
variable "security_group_egress" {}
variable "security_group_tags" {}
variable "security_group_rules" {}
```

# 


---

✅ **2. Compute (EC2, Autoscaling)**

# EC2 Instances
```bash
variable "instance_type" {}
variable "ami_id" {}
variable "key_name" {}
variable "subnet_id" {}
variable "vpc_security_group_ids" {}
variable "associate_public_ip_address" {}
variable "user_data" {}
```

# Launch Template / Auto Scaling
```bash
variable "autoscaling_min_size" {}
variable "autoscaling_max_size" {}
variable "desired_capacity" {}
variable "target_group_arns" {}
```

---

✅ **3. Load Balancers (ALB/NLB)**

# ALB
```bash
variable "alb_name" {}
variable "internal" {}  # true or false
variable "load_balancer_type" {}  # "application" or "network"
variable "security_groups" {}
variable "subnets" {}
```

# Target Group
```bash
variable "target_type" {}  # "instance", "ip", or "lambda"
variable "port" {}
variable "protocol" {}  # "HTTP", "HTTPS"
```

# Listener
```bash
variable "listener_port" {}
variable "listener_protocol" {}
variable "default_action_type" {}
variable "target_group_arn" {}
```

---

✅ **4. EKS (Elastic Kubernetes Service)**

```bash
variable "cluster_name" {}
variable "cluster_version" {}
variable "subnet_ids" {}
variable "vpc_config" {}
variable "node_group_name" {}
variable "node_instance_type" {}
variable "desired_capacity" {}
variable "min_size" {}
variable "max_size" {}
```

---

✅ **5. ECS (Elastic Container Service)**

```bash
variable "cluster_name" {}
variable "launch_type" {}  # "FARGATE" or "EC2"
variable "task_definition_family" {}
variable "container_definitions" {}
variable "desired_count" {}
variable "network_configuration" {}
```

---

✅ **6. ECR (Elastic Container Registry)**

```bash
variable "repository_name" {}
variable "image_tag_mutability" {}  # MUTABLE / IMMUTABLE
variable "scan_on_push" {}  # true or false
```

---

✅ **7. CloudWatch (Logs and Alarms)**

# Logs
```bash
variable "log_group_name" {}
variable "retention_in_days" {}
variable "kms_key_id" {}
```

# Alarms
```bash
variable "alarm_name" {}
variable "comparison_operator" {}
variable "evaluation_periods" {}
variable "metric_name" {}
variable "namespace" {}
variable "period" {}
variable "statistic" {}
variable "threshold" {}
variable "alarm_actions" {}
```

---


