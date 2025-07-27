# Multi-Region EKS Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                                                                         │
│                                                AWS Transit Gateway                                                      │
│                                                                                                                         │
└───────────┬─────────────────────┬─────────────────────┬─────────────────────┬─────────────────────┬─────────────────────┘
            │                     │                     │                     │                     │
            ▼                     ▼                     ▼                     ▼                     ▼
┌───────────────────┐  ┌───────────────────┐  ┌───────────────────┐  ┌───────────────────┐  ┌───────────────────┐
│   Shared VPC      │  │     Dev VPC       │  │    Stage VPC      │  │   Pre-Prod VPC    │  │     Prod VPC      │
│  (us-east-1)      │  │   (ap-south-1)    │  │   (eu-west-1)     │  │   (us-west-2)     │  │   (us-east-1)     │
│                   │  │                   │  │                   │  │                   │  │                   │
│ ┌───────────────┐ │  │ ┌───────────────┐ │  │ ┌───────────────┐ │  │ ┌───────────────┐ │  │ ┌───────────────┐ │
│ │ Public Subnet │ │  │ │ Public Subnet │ │  │ │ Public Subnet │ │  │ │ Public Subnet │ │  │ │ Public Subnet │ │
│ │   (AZ1, AZ2)  │ │  │ │   (AZ1, AZ2)  │ │  │ │   (AZ1, AZ2)  │ │  │ │   (AZ1, AZ2)  │ │  │ │   (AZ1, AZ3)  │ │
│ └───────────────┘ │  │ └───────────────┘ │  │ └───────────────┘ │  │ └───────────────┘ │  │ └───────────────┘ │
│                   │  │                   │  │                   │  │                   │  │                   │
│ ┌───────────────┐ │  │ ┌───────────────┐ │  │ ┌───────────────┐ │  │ ┌───────────────┐ │  │ ┌───────────────┐ │
│ │Private Subnet │ │  │ │Private Subnet │ │  │ │Private Subnet │ │  │ │Private Subnet │ │  │ │Private Subnet │ │
│ │   (AZ1, AZ2)  │ │  │ │   (AZ1, AZ2)  │ │  │ │   (AZ1, AZ2)  │ │  │ │   (AZ1, AZ2)  │ │  │ │   (AZ1, AZ3)  │ │
│ └───────┬───────┘ │  │ └───────┬───────┘ │  │ └───────┬───────┘ │  │ └───────┬───────┘ │  │ └───────┬───────┘ │
│         │         │  │         │         │  │         │         │  │         │         │  │         │         │
│ ┌───────▼───────┐ │  │ ┌───────▼───────┐ │  │ ┌───────▼───────┐ │  │ ┌───────▼───────┐ │  │ ┌───────▼───────┐ │
│ │  EKS Cluster  │ │  │ │  EKS Cluster  │ │  │ │  EKS Cluster  │ │  │ │  EKS Cluster  │ │  │ │  EKS Cluster  │ │
│ │ (Shared Svcs) │ │  │ │     (Dev)     │ │  │ │    (Stage)    │ │  │ │  (Pre-Prod)   │ │  │ │    (Prod)     │ │
│ └───────────────┘ │  │ └───────────────┘ │  │ └───────────────┘ │  │ └───────────────┘ │  │ └───────────────┘ │
│                   │  │                   │  │                   │  │                   │  │                   │
│ ┌───────────────┐ │  │ ┌───────────────┐ │  │ ┌───────────────┐ │  │ ┌───────────────┐ │  │ ┌───────────────┐ │
│ │Database Subnet│ │  │ │Database Subnet│ │  │ │Database Subnet│ │  │ │Database Subnet│ │  │ │Database Subnet│ │
│ │   (AZ1, AZ2)  │ │  │ │   (AZ1, AZ2)  │ │  │ │   (AZ1, AZ2)  │ │  │ │   (AZ1, AZ2)  │ │  │ │   (AZ1, AZ3)  │ │
│ └───────────────┘ │  │ └───────────────┘ │  │ └───────────────┘ │  │ └───────────────┘ │  │ └───────────────┘ │
└───────────────────┘  └───────────────────┘  └───────────────────┘  └───────────────────┘  └───────────────────┘
```

## Detailed Architecture Components

### 1. Transit Gateway
- Central hub for VPC connectivity
- Enables cross-region and cross-VPC communication
- Simplifies network architecture
- Provides redundant, highly available connectivity

### 2. VPC Structure (Per Environment)
Each VPC contains:
- **Public Subnets**: For internet-facing resources like load balancers
- **Private Subnets**: For EKS nodes and application workloads
- **Database Subnets**: For RDS and other data services
- **NAT Gateways**: One per AZ for high availability
- **Internet Gateway**: For public subnet internet access
- **VPC Endpoints**: For secure AWS service access

### 3. EKS Clusters
Each environment has its own EKS cluster with:
- **Multiple Node Groups**: Separated by workload type
- **Private API Endpoint**: For enhanced security
- **Kubernetes Control Plane**: Managed by AWS
- **Auto-scaling**: Based on workload demands

### 4. High Availability Design
- **Multi-AZ Deployment**: 2 AZs for dev/stage/pre-prod/shared, 3 AZs for prod
- **Multiple NAT Gateways**: One per AZ
- **Node Group Auto-scaling**: Handles workload spikes
- **Cross-region Resource Distribution**: Mitigates regional failures

### 5. Security Features
- **Private EKS API Endpoints**: No public internet exposure
- **VPC Endpoints**: For secure AWS service access
- **Network ACLs**: Subnet-level security
- **Security Groups**: Instance-level security
- **KMS Encryption**: For secrets and data
- **WAF Protection**: For application load balancers

### 6. Monitoring and Logging
- **CloudWatch Container Insights**: For EKS monitoring
- **VPC Flow Logs**: For network traffic analysis
- **CloudTrail**: For API activity tracking
- **Centralized Logging**: In shared services VPC

## Environment-Specific Configurations

### Production (us-east-1)
- 3 Availability Zones
- Larger instance types (m5.xlarge)
- Higher minimum node counts
- Stricter security controls

### Pre-Production (us-west-2)
- 2 Availability Zones
- Medium instance types (m5.large)
- Moderate scaling configuration
- Production-like security controls

### Staging (eu-west-1)
- 2 Availability Zones
- Smaller instance types (t3.medium)
- Lower scaling limits
- Standard security controls

### Development (ap-south-1)
- 2 Availability Zones
- Smallest instance types (t3.medium)
- Minimal scaling configuration
- Relaxed security for development

### Shared Services (us-east-1)
- 2 Availability Zones
- Medium instance types (m5.large)
- Hosts shared resources like monitoring tools
- Standard security controls