#!/bin/bash
yum update -y
yum install -y aws-cli

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Test cross-account S3 access
aws s3 ls s3://${bucket_name}

# Create a test file and upload to cross-account S3
echo "Hello from Account 2 EC2 instance accessing Account 1 S3" > /tmp/cross-account-test.txt
aws s3 cp /tmp/cross-account-test.txt s3://${bucket_name}/account2-test.txt

# Download file from Account 1
aws s3 cp s3://${bucket_name}/account1-test.txt /tmp/downloaded-from-account1.txt

# Install Apache for web server
yum install -y httpd
systemctl start httpd
systemctl enable httpd

# Create a simple web page
cat > /var/www/html/index.html << EOF
<html>
<head><title>Account 2 EC2 Instance</title></head>
<body>
<h1>Account 2 EC2 Instance</h1>
<p>This instance can access cross-account S3 bucket: ${bucket_name}</p>
<p>Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)</p>
</body>
</html>
EOF