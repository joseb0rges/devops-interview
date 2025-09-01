resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(var.tags, {
    "Name" : "igw-${var.customer_group}-${var.env}"
  })
}

resource "aws_route_table" "rtb_public" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(var.tags, {
    Name = "rtb-pub-${var.customer_group}-${var.env}"
  })
}

resource "aws_route" "route_public" {
  route_table_id         = aws_route_table.rtb_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "rtb_associations_public" {
  for_each       = { for subnet in var.public_subnets : subnet.name => subnet }
  subnet_id      = aws_subnet.public_subnets[each.value.name].id
  route_table_id = aws_route_table.rtb_public.id
}
