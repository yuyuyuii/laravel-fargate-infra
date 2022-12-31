
# VPC外部からweb通信を許可するセキュリティグループを作成
resource "aws_security_group" "web" {
  name = "${aws_vpc.this.tags.Name}-web"
  vpc_id = aws_vpc.this.id

# inbound
  ingress {
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 80
    protocol = "tcp"
    to_port = 80
  }

  ingress {
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 443
    protocol = "tcp"
    to_port = 443
  }

# outbound
  egress {
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 0
    # -1は全てのプロトコルを許可
    protocol = "-1"
    to_port = 0
  }

  tags = {
    Name = "${aws_vpc.this.tags.Name}-web"
  }
}

# vpc内部リソースの通信の許可設定
resource "aws_security_group" "vpc" {
  name = "${aws_vpc.this.tags.Name}-vpc"
  vpc_id = aws_vpc.this.id

  ingress {
    from_port = 0
    to_port = 0
    protocol = -1
    # このセキュリティグループ自身が付けられたリソースからの通信を許可
    self = true
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  tags = {
    Name = "${aws_vpc.this.tags.Name}-vpc"
  }
}