resource "aws_ecs_cluster" "this" {
  name = "${local.name_prefix}-${local.service_name}"
  # ECSのタスクを実行するインフラを決める。fargateを使うからfargateにする
  capacity_providers = [
    "FARGATE",
    # fargate_spotという仕組みを使って中断する可能性はあるけど、７割引の料金でfargateを使える
    "FARGATE_SPOT"
  ]
  tags = {
    Name = "${local.name_prefix}-${local.service_name}"
  }
}

resource "aws_ecs_task_definition" "this" {
  # タスク定義の名前を指定
  family = "${local.name_prefix}-${local.service_name}"
  # タスクロールのARNを指定。使わない場合は省略できる
  task_role_arn = aws_iam_role.ecs_task.arn
  # コンテナで使用するDockerネットワーキングモードを指定する。Fargateはaws_vpcを指定
  network_mode = "awsvpc"
  # ECSの起動タイプを指定。FargateはFARGATEを指定
  requires_compatibilities = [
    "FARGATE"
  ]
  # タスク実行ロールのARN
  execution_role_arn = aws_iam_role.ecs_task_execution.arn
  # メモリとCPUを指定
  memory = "512"
  cpu    = "256"
  # タスクで動かす各コンテナの設定(nginx, phpの設定を記述)
  container_definitions = jsonencode(
    [
      {
        # コンテナ名
        name = "nginx"
        # コンテナで使用するイメージとURL, タグを指定。各ECRの最新を使用する
        image = "${module.nginx.ecr_repository_this_repository_url}:latest"
        # どのポート, プロトコルを使用するか
        portMappings = [
          {
            containerPort = 80
            protocol      = "tcp"
          }
        ]
        # コンテナに渡す環境変数
        enviroment = []
        # パラメータストア又は、Secret Managetを指定するとその値がコンテナに環境変数として渡される
        secret = []
        # phpのコンテナが起動したら、nginxのコンテナも起動
        depends_on = [
          {
            containerName = "php"
            condition     = "START"
          }
        ]
        # ボリュームのマウントポイントを指定
        mountPoints = [
          {
            containerPath = "/var/run/php-fpm"
            sourceVolume  = "php-fpm-socket"
          }
        ]
        # コンテナのログ設定。logDriverに"awslogs"を指定するとCloudWatch logにコンテナのログが出力される
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = "/ecs/${local.name_prefix}-${(local.service_name)}/nginx"
            awslogs-region        = data.aws_region.current.id
            awslogs-stream-prefix = "ecs"
          }
        }
      },
      {
        name         = "php"
        image        = "${module.php.ecr_repository_this_repository_url}:latest"
        portMappings = []
        enviroment   = []
        secrets = [
          {
            name      = "APP_KEY"
            valueFrom = "/${local.system_name}/${local.env_name}/${local.service_name}/APP_KEY"
          }
        ]
        mountPoints = [
          {
            containerPath = "/var/run/php-fpm"
            sourceVolume  = "php-fpm-socket"
          }
        ]
        logConfigration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = "/ecs/${local.name_prefix}-${local.service_name}/php"
            awslogs-region        = data.aws_region.current.id
            awslogs-stream-prefix = "ecs"
          }
        }
      }
    ]
  )
  volume {
    name = "php-fpm-socket"
  }
  tags = {
    name = "${local.name_prefix}-${local.service_name}"
  }
}