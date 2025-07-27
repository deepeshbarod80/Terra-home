ICMP - Interenet Control Message Protocol 
Defination - Interenet Control Message Protocol is a 

Requirements of Ec2 instance:
- VPC - Allow DNS hostnames, DNS Resolution, Flow logs, Cloudwatch, etc
- Subnet public/private 
- IGW - Internet Gateway for public subnet
- Route Tables - Configure Available ip addresses
- Nat Gateway - keep inside public subnet for accessing internet for public subnet
- Security groups - Allow inbound and outbound traffic
- Key-Pair - Create key-pairs to login in instance via SSH
- AMI - keep to select suitable OS in VM like ubuntu
- 

''' Resource Creation '''
--> Follow the sequence;
1) Steps to Create VPC:
---> Go to Create VPC --> Choose VPC only ---> Give 'Name tag' 
---> in IPv4 CIDR block Select "IPv4 CIDR manual input"  
---> Give "IPv4 CIDR block" like "10.0.0.0/16" 
---> in IPv6 CIDR block Choose "No IPv6 CIDR block"  
---> In Tenancy choose "Default" ---> Click "Create VPC"

2) Steps to Create Subnet:
---> Go to Create Subnet --> 
---> Select "VPC" in which you want to create subnet
---> Give "Subnet Name" 
---> Select Availability Zone in which you want to create Subnet
---> Give "IPv4 subnet CIDR block" like 10.0.0.0/24 from inside 10.0.0.0/16 of VPC
---> Click "Create Subnet"

3) Steps to Create Internet Gateway:
---> Go to "Create internet gateway"
---> provide "name-tag"
---> Click "Create internet gateway"
Then,
---> Go to "Attch VPC"
---> Select VPC which you want to connect
---> Click "Attach Internet Gateway"

4) Steps to Create Route Table:
---> Go to "Create Route Table"
---> In Route table settings provide "Name"
---> Select VPC then Click "Create Route Table"
Then,
---> Go to "Edit Route"
---> Click on "Add route"
---> In 'Destination' select "0.0.0.0/0" for All Traffic
---> In 'Target' select "Internet Gateway" and choose your <IGW-id>
---> Click on "Save Changes"
Then,
---> Go to "subnet associations" of this route table
---> then go to "Edit subnet associations" and Select <Public-Subnet-id> 
---> Click on "Save Associations"

5) Steps to Create Security Group:
---> Go to "Create security group"
---> In Basic Detais Section provide "Security group name", "Description" and Select VPC.
---> Create Inbound rules" for SSH, HTTP, HTTPS,etc 
---> Create Outbound rules" for updates, etc.
---> Create Tags             <Optional>
---> Click "Create Security Group"

6) Steps to Create Key-Pair:
---> Go to ec2 ---> then "Network & Security" ---> Click on "Create key pair"
---> provide <key-pair-name> like "test-key"
---> in 'Key pair type' select "RSA"
---> in 'Private key file format' select ".pem" for open SSH access
---> click "Create Key Pair"



7) Steps to Create Nat Gateway:
---> first Create Elastic IP, then
---> Go to Create NAT Grateway
---> 
-------------------------------------------------------------------------------



''' VPC Peering '''
// VPC peering is a process in which you connect 2 diffrent VPCs to each other.
- Before Creating VPC peering you need 2 VPCs, Subnets, SGs, IGWs, Route Tables, Ec2(Running)

A. Create Peering Connection;
---> Go to VPC ---> Click on "Peering Connection" ---> Click on "Create Peering Connection"
---> In "Peering connection settings" provide "Name" 
---> Select a local VPC to peer with VPC-ID <Requester-VPC>
---> Select "AWS-Account" and "Region" of <Accepter-VPC>
---> Select a remote VPC to peer with VPC ID <Accepter-VPC>
---> then click "Create Peering Connection"
---> Accept the request of <Accepter-VPC> 

B. Configure DNS Settings;
---> Allow accepter VPC to resolve DNS of hosts in requester VPC to private IP addresses
---> Allow requester VPC to resolve DNS of hosts in accepter VPC to private IP addresses

c. Configure Subnets for Peering Connection;
---> Copy "CIDR block of Public IPs of first VPC"    <for-first-VPC>
---> then Open "Second VPC's Route Table"
---> Open "Routes" tab ---> click on "Edit routes" ---> click on "Add route"
---> In "Destination search bar" provide "CIDR block of Public IPs of first VPC"
---> In 'Target' tab Select "Peering Connection" ---> add "CIDR block of IPs of first VPC"
---> Click on "Save Changes".
// Then;
---> Copy "CIDR block of Public IPs of second VPC"    <for-second-VPC>
---> then Open "First VPC's Route Table"
---> Open "Routes" tab ---> click on "Edit routes" ---> click on "Add route"
---> In "Destination search bar" provide "CIDR block of Public IPs of second VPC"
---> In 'Target' tab Select "Peering Connection" ---> add "CIDR block of IPs of first VPC"
---> Click on "Save Changes".

D. Configure Security Groups for Peering Connection;
---> Copy "CIDR block of Public IPs of first VPC"
---> then Open "Second VPC's Security Groups"
---> open "Edit inbound rules" ---> Click "add new rule"
---> Select type as "All ICMP - IPv4", then add "CIDR block of IPs of first VPC" and save rules.
// Then;
---> Copy "CIDR block of Public IPs of second VPC"
---> then Open "First VPC's Security Groups"
---> open "Edit inbound rules" ---> Click "add new rule"
---> Select type as "All ICMP - IPv4", then add "CIDR block of IPs of Second VPC" and save rules.

E. Testing peering connection;
- Now Open both instances terminals defferently
- in first terminal run command "ping <second instance private-ip>"
- in second terminal run command "ping <first instance private-ip>"
- Your ping will be successfull if not then check the configuration.
----------------------------------------------------------------------------------











