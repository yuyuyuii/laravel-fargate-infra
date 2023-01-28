resource "aws_nat_gateway" "this" {
  for_each = var.enable_nat_gateway ? local.nat_gateway_azs : {}
  # nat_gatewayに紐付けるelastic IPのidを割り当て
  allocation_id = aws_eip.nat_gateway[each.key].id
  # nat_gatewayを紐づけるサブネット。パブリックサブネットを割り当て
  subnet_id = aws_subnet.public[each.key].id

  tags = {
    Name = "${aws_vpc.this.tags.Name}-${each.key}"
  }
}