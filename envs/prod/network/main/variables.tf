variable "vpc_cidr" {
  type    = string
  default = "172.31.0.0/16"
}

variable "azs" {
  # map型でリソースを定義する
  type = map(object({
    public_cidr  = string
    private_cidr = string
  }))
  # アベイラビリティゾーンを2つ利用する/20で
  default = {
    # aがkey, public_cidr, private_cidrがvalur
    a = {
      public_cidr  = "172.31.0.0/20"
      private_cidr = "172.31.48.0/20"
    },
    c = {
      public_cidr  = "172.31.16.0/20"
      private_cidr = "172.31.64.0/20"
    },
    # アベイラビリティゾーンを三つ使う場合は以下の様にする
    # d = {
    #   public_cidr = "172.31.32.0/20"
    #   private_cidr = "172.31.80.0/20"
    # }
  }
}

# enable_nat_gatewayがtrueの時にnat_gatewayが作成される
# applyするときに-varオプションをつけてfalseを指定し、実行するとnat_gatewayは作られない
# terraform apply -var='enable_nat_gateway=false'
variable "enable_nat_gateway" {
  type    = bool
  default = true
}

variable "single_nat_gateway" {
  type    = bool
  default = true
}
