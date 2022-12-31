resource "aws_subnet" "public" {
  # for_eachを使えば、リソースを定義した分作成できる
  # variables.tfに定義したazsのリソースを割り当てる
  # map型のキーの部分がリソースのキーになるから、aws_subnet.public["a"]とaws_subnet.public["c"]が作成される
  for_each = var.azs
  # availability_zonnをdataリソースで定義した名前(ap-northeast-1)とeach.key(a)を割り当て
  # ap-northeast-1aがavailability_zoneとなる
  availability_zone = "${data.aws_region.current.name}${each.key}"
  # variables.tfに定義したvalue値のpubilc_cidrを割り当て
  cidr_block = each.value.public_cidr
  # trueにするとサブネット内のリソースにパブリックIPアドレスが自動で割り当てられる
  map_public_ip_on_launch = true
  # vpc_idはvpcのリソースのidを指定
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${aws_vpc.this.tags.Name}-public-${each.key}"
  }
}


resource "aws_subnet" "private" {
  for_each = var.azs
  availability_zone = "${data.aws_region.current.name}${each.key}"
  cidr_block = each.value.private_cidr
  map_public_ip_on_launch = false
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${aws_vpc.this.tags.Name}-private-${each.key}"
  }
}