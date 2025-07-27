# AWS CloudWatch Metric Alarm for VPN Tunnel Status
resource "aws_cloudwatch_metric_alarm" "vpn_tunnel_status" {
  alarm_name          = "vpn-tunnel-status"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "TunnelState"
  namespace           = "AWS/VPN"
  period              = "300"
  statistic           = "Maximum"
  threshold           = "1"
  alarm_description   = "This metric monitors VPN tunnel status"
  alarm_actions       = []
  
  dimensions = {
    VpnId = aws_vpn_connection.aws_to_gcp_vpn.id
    TunnelIpAddress = aws_vpn_connection.aws_to_gcp_vpn.tunnel1_address
  }
}

# GCP Monitoring - Uptime Check for VPN Tunnel
resource "google_monitoring_uptime_check_config" "vpn_tunnel_check" {
  display_name = "vpn-tunnel-check"
  timeout      = "60s"
  period       = "300s"
  
  http_check {
    path           = "/"
    port           = "443"
    use_ssl        = true
    validate_ssl   = true
  }
  
  monitored_resource {
    type = "uptime_url"
    labels = {
      project_id = var.gcp_project_id
      host       = "example.com"  # Replace with an actual endpoint to monitor
    }
  }
}