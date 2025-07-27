
# AWS VPC and Subnets
resource "aws_vpc" "aws_vpc" {
  cidr_block           = var.aws_vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "aws-vpc-vpn"
  }
}

resource "aws_subnet" "aws_private_subnet" {
  vpc_id            = aws_vpc.aws_vpc.id
  cidr_block        = var.aws_private_subnet_cidr
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "aws-private-subnet"
  }
}

# AWS Customer Gateway
resource "aws_customer_gateway" "gcp_customer_gateway" {
  bgp_asn    = 65000
  ip_address = google_compute_address.gcp_vpn_ip.address
  type       = "ipsec.1"

  tags = {
    Name = "gcp-customer-gateway"
  }
}

# AWS Virtual Private Gateway
resource "aws_vpn_gateway" "aws_vpn_gateway" {
  vpc_id = aws_vpc.aws_vpc.id

  tags = {
    Name = "aws-vpn-gateway"
  }
}

# AWS VPN Connection
resource "aws_vpn_connection" "aws_to_gcp_vpn" {
  vpn_gateway_id      = aws_vpn_gateway.aws_vpn_gateway.id
  customer_gateway_id = aws_customer_gateway.gcp_customer_gateway.id
  type                = "ipsec.1"
  static_routes_only  = true

  tags = {
    Name = "aws-to-gcp-vpn"
  }
}

# AWS VPN Connection Route
resource "aws_vpn_connection_route" "aws_to_gcp_route" {
  destination_cidr_block = var.gcp_subnet_cidr
  vpn_connection_id      = aws_vpn_connection.aws_to_gcp_vpn.id
}

# AWS Route Table for Private Subnet
resource "aws_route_table" "aws_private_route_table" {
  vpc_id = aws_vpc.aws_vpc.id

  route {
    cidr_block = var.gcp_subnet_cidr
    gateway_id = aws_vpn_gateway.aws_vpn_gateway.id
  }

  tags = {
    Name = "aws-private-route-table"
  }
}

resource "aws_route_table_association" "aws_private_route_assoc" {
  subnet_id      = aws_subnet.aws_private_subnet.id
  route_table_id = aws_route_table.aws_private_route_table.id
}

# GCP VPC and Subnets
resource "google_compute_network" "gcp_vpc" {
  name                    = "gcp-vpc-vpn"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "gcp_private_subnet" {
  name          = "gcp-private-subnet"
  ip_cidr_range = var.gcp_subnet_cidr
  region        = var.gcp_region
  network       = google_compute_network.gcp_vpc.id
}

# GCP External IP for VPN
resource "google_compute_address" "gcp_vpn_ip" {
  name   = "gcp-vpn-ip"
  region = var.gcp_region
}

# GCP VPN Gateway
resource "google_compute_vpn_gateway" "gcp_vpn_gateway" {
  name    = "gcp-vpn-gateway"
  network = google_compute_network.gcp_vpc.id
  region  = var.gcp_region
}

# GCP Forwarding Rules
resource "google_compute_forwarding_rule" "fr_esp" {
  name        = "fr-esp"
  ip_protocol = "ESP"
  ip_address  = google_compute_address.gcp_vpn_ip.address
  target      = google_compute_vpn_gateway.gcp_vpn_gateway.id
  region      = var.gcp_region
}

resource "google_compute_forwarding_rule" "fr_udp500" {
  name        = "fr-udp500"
  ip_protocol = "UDP"
  port_range  = "500"
  ip_address  = google_compute_address.gcp_vpn_ip.address
  target      = google_compute_vpn_gateway.gcp_vpn_gateway.id
  region      = var.gcp_region
}

resource "google_compute_forwarding_rule" "fr_udp4500" {
  name        = "fr-udp4500"
  ip_protocol = "UDP"
  port_range  = "4500"
  ip_address  = google_compute_address.gcp_vpn_ip.address
  target      = google_compute_vpn_gateway.gcp_vpn_gateway.id
  region      = var.gcp_region
}

# GCP VPN Tunnel
resource "google_compute_vpn_tunnel" "gcp_vpn_tunnel1" {
  name               = "gcp-vpn-tunnel1"
  peer_ip            = aws_vpn_connection.aws_to_gcp_vpn.tunnel1_address
  shared_secret      = aws_vpn_connection.aws_to_gcp_vpn.tunnel1_preshared_key
  ike_version        = 1
  target_vpn_gateway = google_compute_vpn_gateway.gcp_vpn_gateway.id
  local_traffic_selector = [var.gcp_subnet_cidr]
  remote_traffic_selector = [var.aws_vpc_cidr]
  region             = var.gcp_region

  depends_on = [
    google_compute_forwarding_rule.fr_esp,
    google_compute_forwarding_rule.fr_udp500,
    google_compute_forwarding_rule.fr_udp4500
  ]
}

# GCP Route for VPN Tunnel
resource "google_compute_route" "gcp_to_aws_route" {
  name                = "gcp-to-aws-route"
  network             = google_compute_network.gcp_vpc.id
  dest_range          = var.aws_vpc_cidr
  priority            = 1000
  next_hop_vpn_tunnel = google_compute_vpn_tunnel.gcp_vpn_tunnel1.id
}