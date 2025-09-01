resource "aws_eip" "eip_private" {
  tags = merge(var.tags, {
    Name = "eip-${var.customer_group}-${var.env}"
  })
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.eip_private.id
  subnet_id     = aws_subnet.public_subnets[var.public_subnets[0].name].id
  tags = merge(var.tags, {
    Name = "ngtw-${var.customer_group}-${var.env}"
  })
}

resource "aws_route_table" "rtb_private" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(var.tags, {
    Name = "rtb-priv-${var.customer_group}-${var.env}"
  })
}

resource "aws_route" "route_private" {
  route_table_id         = aws_route_table.rtb_private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id
}

resource "aws_route_table_association" "rbt_associations" {
  for_each       = { for subnet in var.private_subnets : subnet.name => subnet }
  subnet_id      = aws_subnet.private_subnets[each.value.name].id
  route_table_id = aws_route_table.rtb_private.id
}
