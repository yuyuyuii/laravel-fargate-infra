# 変数の型だけ定義し、値は呼び出しもとで定義する

variable "name" {
  type = string
}

variable "holding_count" {
  type = number
  default = 10
}