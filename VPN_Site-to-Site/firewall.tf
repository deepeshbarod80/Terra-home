# AWS Security Group for VPN traffic
resource "aws_security_group" "vpn_traffic" {
  name        = "vpn-traffic"
  description = "Allow traffic from GCP VPC"
  vpc_id      = aws_vpc.aws_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.gcp_subnet_cidr]
    description = "Allow all inbound traffic from GCP subnet"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "vpn-traffic"
  }
}

# GCP Firewall Rules
resource "google_compute_firewall" "allow_aws_traffic" {
  name    = "allow-aws-traffic"
  network = google_compute_network.gcp_vpc.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  source_ranges = [var.aws_vpc_cidr]
  target_tags   = ["vpn"]
}

resource "google_compute_firewall" "allow_internal" {
  name    = "allow-internal"
  network = google_compute_network.gcp_vpc.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  source_ranges = [var.gcp_subnet_cidr]
}