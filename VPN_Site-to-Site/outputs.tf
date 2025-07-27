output "aws_vpn_connection_id" {
  description = "The ID of the VPN connection"
  value       = aws_vpn_connection.aws_to_gcp_vpn.id
}

output "aws_customer_gateway_id" {
  description = "The ID of the customer gateway"
  value       = aws_customer_gateway.gcp_customer_gateway.id
}

output "aws_vpn_gateway_id" {
  description = "The ID of the VPN gateway"
  value       = aws_vpn_gateway.aws_vpn_gateway.id
}

output "gcp_vpn_gateway_id" {
  description = "The ID of the GCP VPN gateway"
  value       = google_compute_vpn_gateway.gcp_vpn_gateway.id
}

output "gcp_vpn_tunnel_id" {
  description = "The ID of the GCP VPN tunnel"
  value       = google_compute_vpn_tunnel.gcp_vpn_tunnel1.id
}

output "gcp_vpn_ip" {
  description = "The external IP address for the GCP VPN gateway"
  value       = google_compute_address.gcp_vpn_ip.address
}

output "aws_vpn_tunnel1_address" {
  description = "The public IP address of the first VPN tunnel"
  value       = aws_vpn_connection.aws_to_gcp_vpn.tunnel1_address
}

output "aws_vpn_tunnel2_address" {
  description = "The public IP address of the second VPN tunnel"
  value       = aws_vpn_connection.aws_to_gcp_vpn.tunnel2_address
}