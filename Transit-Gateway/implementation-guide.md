# Multi-Region EKS Architecture Implementation Guide

This guide provides step-by-step instructions for implementing the multi-region EKS architecture with 5 VPCs across different environments.

## Prerequisites

1. AWS CLI installed and configured with appropriate permissions
2. Terraform v1.0.0 or later installed
3. kubectl installed
4. AWS IAM permissions to create all required resources

## Implementation Steps

### Step 1: Set Up the Terraform Backend

1. Create an S3 bucket for Terraform state:

```bash
aws s3 mb s3://terraform-state-microservices --region us-east-1
```

2. Enable versioning on the S3 bucket:

```bash
aws s3api put-bucket-versioning --bucket terraform-state-microservices --versioning-configuration Status=Enabled
```

3. Create a DynamoDB table for state locking:

```bash
aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

### Step 2: Initialize and Apply the Terraform Configuration

1. Initialize Terraform:

```bash
terraform init
```

2. Create a `terraform.tfvars` file with your AWS account ID:

```
aws_account_id = "123456789012"  # Replace with your AWS account ID
trusted_ip = "203.0.113.0/24"    # Replace with your trusted IP CIDR
```

3. Plan the deployment:

```bash
terraform plan -out=tfplan
```

4. Apply the configuration:

```bash
terraform apply tfplan
```

### Step 3: Configure kubectl for EKS Clusters

1. Update your kubeconfig for each EKS cluster:

```bash
# Production
aws eks update-kubeconfig --name prod-eks --region us-east-1

# Pre-Production
aws eks update-kubeconfig --name pre-prod-eks --region us-west-2

# Staging
aws eks update-kubeconfig --name stage-eks --region eu-west-1

# Development
aws eks update-kubeconfig --name dev-eks --region ap-south-1

# Shared Services
aws eks update-kubeconfig --name shared-services-eks --region us-east-1
```

2. Verify connectivity to each cluster:

```bash
kubectl get nodes
```

### Step 4: Deploy Core Kubernetes Components

For each EKS cluster, deploy the following components:

1. AWS Load Balancer Controller:

```bash
helm repo add eks https://aws.github.io/eks-charts
helm repo update

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  --namespace kube-system \
  --set clusterName=<CLUSTER_NAME> \
  --set serviceAccount.create=true \
  --set serviceAccount.name=aws-load-balancer-controller
```

2. Metrics Server:

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

3. Cluster Autoscaler:

```bash
kubectl apply -f cluster-autoscaler.yaml
```

### Step 5: Set Up Monitoring and Logging

1. Deploy CloudWatch Container Insights:

```bash
ClusterName=<CLUSTER_NAME>
RegionName=<REGION>
FluentBitHttpPort='2020'
FluentBitReadFromHead='Off'
[[ ${FluentBitReadFromHead} = 'On' ]] && FluentBitReadFromTail='Off'|| FluentBitReadFromTail='On'
[[ -z ${FluentBitHttpPort} ]] && FluentBitHttpServer='Off' || FluentBitHttpServer='On'
curl https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/quickstart/cwagent-fluent-bit-quickstart.yaml | sed 's/{{cluster_name}}/'${ClusterName}'/;s/{{region_name}}/'${RegionName}'/;s/{{http_server_toggle}}/"'${FluentBitHttpServer}'"/;s/{{http_server_port}}/"'${FluentBitHttpPort}'"/;s/{{read_from_head}}/"'${FluentBitReadFromHead}'"/;s/{{read_from_tail}}/"'${FluentBitReadFromTail}'"/' | kubectl apply -f -
```

2. Deploy Prometheus and Grafana in the shared-services cluster:

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install prometheus prometheus-community/prometheus \
  --namespace monitoring \
  --create-namespace

helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

helm install grafana grafana/grafana \
  --namespace monitoring \
  --set persistence.enabled=true \
  --set persistence.size=10Gi
```

### Step 6: Configure Transit Gateway Routing

1. Verify Transit Gateway attachments:

```bash
aws ec2 describe-transit-gateway-attachments --region us-east-1
```

2. Verify Transit Gateway route tables:

```bash
aws ec2 describe-transit-gateway-route-tables --region us-east-1
```

3. Test connectivity between VPCs:

```bash
# Launch a test EC2 instance in each VPC and test connectivity
ping <PRIVATE_IP_OF_INSTANCE_IN_ANOTHER_VPC>
```

### Step 7: Set Up CI/CD for Microservices

1. Create ECR repositories for your microservices:

```bash
aws ecr create-repository --repository-name microservice-a --region us-east-1
aws ecr create-repository --repository-name microservice-b --region us-east-1
```

2. Set up CI/CD pipelines using AWS CodePipeline or GitHub Actions to build, test, and deploy your microservices to the EKS clusters.

### Step 8: Implement Security Best Practices

1. Enable GuardDuty in all regions:

```bash
aws guardduty create-detector --enable --region us-east-1
aws guardduty create-detector --enable --region us-west-2
aws guardduty create-detector --enable --region eu-west-1
aws guardduty create-detector --enable --region ap-south-1
```

2. Enable AWS Config in all regions:

```bash
aws configservice put-configuration-recorder --configuration-recorder name=default,roleARN=<CONFIG_ROLE_ARN> --region us-east-1
aws configservice put-delivery-channel --delivery-channel name=default,s3BucketName=<CONFIG_BUCKET>,configSnapshotDeliveryProperties={deliveryFrequency=One_Hour} --region us-east-1
aws configservice start-configuration-recorder --configuration-recorder-name default --region us-east-1
```

3. Implement AWS Security Hub:

```bash
aws securityhub enable-security-hub --region us-east-1
aws securityhub enable-security-hub --region us-west-2
aws securityhub enable-security-hub --region eu-west-1
aws securityhub enable-security-hub --region ap-south-1
```

## Maintenance and Operations

### Regular Maintenance Tasks

1. Update EKS clusters to the latest Kubernetes version:

```bash
aws eks update-cluster-version --name <CLUSTER_NAME> --kubernetes-version <VERSION> --region <REGION>
```

2. Rotate IAM credentials regularly:

```bash
# Update IAM user access keys
aws iam create-access-key --user-name <USERNAME>
aws iam delete-access-key --user-name <USERNAME> --access-key-id <OLD_ACCESS_KEY_ID>
```

3. Monitor and optimize costs:

```bash
# Enable AWS Cost Explorer
aws ce enable-cost-explorer

# Create cost budget
aws budgets create-budget --account-id <ACCOUNT_ID> --budget file://budget.json --notifications-with-subscribers file://notifications.json
```

### Disaster Recovery

1. Regularly back up EKS cluster resources:

```bash
# Use Velero for Kubernetes backup
velero backup create <BACKUP_NAME> --include-namespaces <NAMESPACES>
```

2. Test failover procedures:

```bash
# Simulate AZ failure by cordoning nodes in one AZ
kubectl cordon -l topology.kubernetes.io/zone=<AZ_NAME>
```

3. Document and practice recovery procedures regularly.

## Conclusion

This implementation guide provides a comprehensive approach to deploying a multi-region EKS architecture with 5 VPCs. By following these steps, you'll create a secure, highly available infrastructure for your microservices application that spans multiple AWS regions and environments.