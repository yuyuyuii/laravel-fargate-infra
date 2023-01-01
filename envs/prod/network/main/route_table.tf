# パブリックサブネットに作るルートテーブル
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${aws_vpc.this.tags.Name}-public"
  }
}
# ルートテーブルに登録するルーティング設定
# デフォルトルートのみ登録。
# route_table_idにはどのルートテーブルに登録するかを定義
resource "aws_route" "internet_gateway_public" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.this.id
  route_table_id = aws_route_table.public.id
}

# どのルートテーブルとサブネットに紐付けるか
# [each.key]には[a]と[c]が入る
resource "aws_route_table_association" "public" {
  for_each = var.azs
  route_table_id = aws_route_table.public.id
  subnet_id = aws_subnet.public[each.key].id
}

# ▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼▲▼

# プライベートサブネット用のルートテーブルを複数作成する
resource "aws_route_table" "private" {
  for_each = var.azs
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${aws_vpc.this.tags.Name}-private-${each.key}"
  }
}

# nat_gatewayを作成する場合は、nat_gatewayのルートを複数作成する
resource "aws_route" "nat_gateway_private" {
  for_each = var.enable_nat_gateway ? var.azs : {}
  destination_cidr_block = "0.0.0.0/0"
  # var.single_nat_gatewayがtrueの時は"a"が複数作られ、falseの時は"a", "c"が作られる
  nat_gateway_id = aws_nat_gateway.this[var.single_nat_gateway ? keys(var.azs)[0] : each.key].id   
  route_table_id = aws_route_table.private[each.key].id
}

# プライベート用のルートテーブルとプライベートサブネットを紐付け
resource "aws_route_table_association" "private" {
  for_each = var.azs
  route_table_id = aws_route_table.private[each.key].id
  subnet_id = aws_subnet.private[each.key].id
}