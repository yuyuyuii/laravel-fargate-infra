resource "aws_iam_user" "github" {
  name = "${local.name_prefix}-${local.service_name}-github"
  tags = {
    "Name" = "${local.name_prefix}-${local.service_name}-github"
  }
}

# デプロイを実行するユーザ権限を持つrole(グループ的なやつ)
# こいつを作っただけだと権限はまだない。このロールに権限を付与するポリシーを付与する必要がある。
resource "aws_iam_role" "deployer" {
  name = "${local.name_prefix}-${local.service_name}-deployer"

  # 一時的に権限を実行権限を得るロール？
  # deployerというロールが一時的にAWSリソースからどんな操作を許可をするかを定義
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "sts:AssumeRole",
            # aws-actions/configure-aws-credentialsの機能を利用してる
            # デフォルトでsessionタグっていうのを受け渡しをしているからTagSessionを許可してないとエラーになる
            # deploy.ymlにデプロイ時に上記機能を利用してることを記載してる
            "sts:TagSession"
          ],
          "Principal" : {
            "AWS" : aws_iam_user.github.arn
          }
        }
      ]
    }
  )
  tags = {
    "Name" = "${local.name_prefix}-${local.service_name}-deployer"
  }
}

# ロールにecrへのデプロイ権限を付与するためのポリシー
# dataはtfstateでは管理してないリソースを参照する時に使うもの。以下のポリシーはAWSが管理してるポリシーだからdataで定義する
# AmazonEC2ContainerRegistryPowerUserはECRへの読み書き権限を持ってる
data "aws_iam_policy" "ecr_power_user" {
  # ポリシーの参照先を定義して
  arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

# ロールへ割り当てるポリシーを定義
# roleはdeployerへ、ポリシーはecr_power_userへつける
resource "aws_iam_policy_attachment" "role_deployer_policy_ecr_power_user" {
  name = "role_deployer_policy_ecr_power_user"
  roles      = ["${aws_iam_role.deployer.name}"]
  policy_arn = data.aws_iam_policy.ecr_power_user.arn
}


