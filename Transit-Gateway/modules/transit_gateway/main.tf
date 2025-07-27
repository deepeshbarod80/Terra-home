resource "aws_ec2_transit_gateway" "main" {
  description                     = "Multi-Region Transit Gateway for Microservices"
  amazon_side_asn                 = var.amazon_side_asn
  auto_accept_shared_attachments  = "enable"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"
  
  tags = {
    Name = "microservices-transit-gateway"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc" {
  for_each = var.vpc_attachments
  
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = each.value.vpc_id
  subnet_ids         = each.value.subnet_ids
  
  dns_support                                     = "enable"
  transit_gateway_default_route_table_association = true
  transit_gateway_default_route_table_propagation = true
  
  tags = {
    Name = "${each.key}-tgw-attachment"
  }
}

resource "aws_ec2_transit_gateway_route_table" "main" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  
  tags = {
    Name = "microservices-tgw-rt"
  }
}

resource "aws_ec2_transit_gateway_route" "routes" {
  for_each = var.vpc_attachments
  
  destination_cidr_block         = each.value.vpc_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc[each.key].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main.id
}

# Cross-region TGW peering if needed
resource "aws_ec2_transit_gateway_peering_attachment" "peering" {
  for_each = var.tgw_peering_connections
  
  peer_account_id         = each.value.peer_account_id
  peer_region             = each.value.peer_region
  peer_transit_gateway_id = each.value.peer_transit_gateway_id
  transit_gateway_id      = aws_ec2_transit_gateway.main.id
  
  tags = {
    Name = "tgw-peering-${var.region}-to-${each.value.peer_region}"
  }
}

# RAM sharing for cross-account TGW
resource "aws_ram_resource_share" "tgw_share" {
  count = length(var.ram_principals) > 0 ? 1 : 0
  
  name                      = "transit-gateway-share"
  allow_external_principals = true
  
  tags = {
    Name = "transit-gateway-share"
  }
}

resource "aws_ram_resource_association" "tgw_share" {
  count = length(var.ram_principals) > 0 ? 1 : 0
  
  resource_arn       = aws_ec2_transit_gateway.main.arn
  resource_share_arn = aws_ram_resource_share.tgw_share[0].arn
}

resource "aws_ram_principal_association" "tgw_share" {
  count = length(var.ram_principals)
  
  principal          = var.ram_principals[count.index]
  resource_share_arn = aws_ram_resource_share.tgw_share[0].arn
}