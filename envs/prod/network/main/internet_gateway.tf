resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = {
    # vpcに付けたタグを利用する
    Name = aws_vpc.this.tags.Name
  }
}