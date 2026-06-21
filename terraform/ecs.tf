resource "aws_ecs_cluster" "app" {
  name = "unicycling-registration-${var.environment}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name        = "unicycling-registration-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_log_group" "web" {
  name              = "/ecs/unicycling-registration-${var.environment}-web"
  retention_in_days = 30
  tags = { Environment = var.environment }
}

resource "aws_cloudwatch_log_group" "sidekiq" {
  name              = "/ecs/unicycling-registration-${var.environment}-sidekiq"
  retention_in_days = 30
  tags = { Environment = var.environment }
}

# ---- Container definition helpers ----

locals {
  ssm_prefix = "/unicycling-registration/${var.environment}"

  # Sensitive values injected from SSM Parameter Store at task launch.
  # Populate each before scaling the services up:
  #   aws ssm put-parameter --name "/unicycling-registration/{env}/SECRET_KEY_BASE" \
  #     --type SecureString --value "..." --region us-west-2
  ssm_secret_names = [
    "SECRET_KEY_BASE",

    # Database
    "DATABASE_HOST", "POSTGRES_USER", "POSTGRES_PASSWORD", "POSTGRES_DB",

    # Redis — REDIS_URL points to ElastiCache (Sidekiq + ActionCable).
    # REDIS_CACHE_URL (sidecar) is set directly in container_environment_web, not SSM.
    # REDIS_HOST / REDIS_PORT / REDIS_DB are EC2-only and not used on ECS.
    "REDIS_URL",

    # AWS
    "AWS_REGION", "AWS_BUCKET", "AWS_ACCESS_KEY", "AWS_SECRET_ACCESS_KEY",

    # Email
    "MAIL_FULL_EMAIL", "MAIL_SKIP_CONFIRMATION",
    "ERROR_EMAILS", "SERVER_ADMIN_EMAIL", "PAYMENT_NOTICE_EMAIL",

    # Analytics
    "GOOGLE_ANALYTICS_TRACKING_ID",
    "GOOGLE_ANALYTICS_4_TRACKING_ID",

    # Captcha
    "HCAPTCHA_SECRET", "HCAPTCHA_SITE_KEY",
    "RECAPTCHA_PUBLIC_KEY", "RECAPTCHA_PRIVATE_KEY",

    # App config
    "INSTANCE_CREATION_CODE",
    "SUPER_ADMIN_UPGRADE_CODE",
    "INDIVIDUAL_EMAIL_SENDING",
    "CACHE_INSTRUMENTATION",
    "ALB_LISTENER_ARN",

    # Translations / i18n
    "TRANSLATIONS_SUBDOMAIN", "TRANSLATION_WEBSITE_URL",

    # IUF membership
    "IUF_MEMBERSHIP_API_URL", "IUF_MEMBERSHIP_URL",

    # WildApricot (USA membership)
    "USA_WILDAPRICOT_ACCOUNT_ID", "USA_WILDAPRICOT_API_KEY",

    # Monitoring
    "ROLLBAR_ACCESS_TOKEN",
  ]

  container_secrets = [
    for name in local.ssm_secret_names : {
      name      = name
      valueFrom = "arn:aws:ssm:us-west-2:${data.aws_caller_identity.current.account_id}:parameter${local.ssm_prefix}/${name}"
    }
  ]

  # Non-sensitive config shared by both web and sidekiq containers.
  container_environment_base = [
    { name = "RAILS_ENV",                value = var.rails_env },
    { name = "PORT",                     value = "3000" },
    { name = "RAILS_LOG_TO_STDOUT",      value = "1" },
    { name = "RAILS_SERVE_STATIC_FILES", value = "true" },
    { name = "RAILS_MAX_THREADS",        value = "5" },
    { name = "DOMAIN",                   value = var.domain },
    { name = "SSL_ENABLED",              value = "false" },
    { name = "ROBOTS_DISALLOW_ALL",      value = var.environment == "staging" ? "true" : "false" },
  ]

  # Web only: cache sidecar URL. Sidekiq uses ElastiCache (REDIS_URL from SSM) for all Redis.
  container_environment_web = concat(local.container_environment_base, [
    { name = "REDIS_CACHE_URL", value = "redis://127.0.0.1:6379/1" },
  ])

  # Redis sidecar — web task only (Rails cache store). Sidekiq uses ElastiCache via REDIS_URL.
  # essential=false so a cache restart does not kill the web container.
  redis_sidecar = {
    name      = "redis-cache"
    image     = "redis:7-alpine"
    essential = false
    command   = ["redis-server", "--bind", "127.0.0.1", "--maxmemory", "128mb", "--maxmemory-policy", "allkeys-lru"]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.web.name
        "awslogs-region"        = "us-west-2"
        "awslogs-stream-prefix" = "redis-cache"
      }
    }
  }
}

# ---- Task definitions ----

resource "aws_ecs_task_definition" "web" {
  family                   = "unicycling-registration-${var.environment}-web"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 2048
  memory                   = 4096
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name      = "web"
      image     = "${var.ecr_repository_url}:${var.image_tag}"
      essential = true

      portMappings    = [{ containerPort = 3000, protocol = "tcp" }]
      linuxParameters = { initProcessEnabled = true }
      dependsOn       = [{ containerName = "redis-cache", condition = "START" }]

      environment = local.container_environment_web
      secrets     = local.container_secrets

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.web.name
          "awslogs-region"        = "us-west-2"
          "awslogs-stream-prefix" = "web"
        }
      }
    },
    local.redis_sidecar,
  ])

  tags = { Environment = var.environment }
}

resource "aws_ecs_task_definition" "sidekiq" {
  family                   = "unicycling-registration-${var.environment}-sidekiq"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name      = "sidekiq"
      image     = "${var.ecr_repository_url}:${var.image_tag}"
      essential = true
      command   = ["bundle", "exec", "sidekiq", "-C", "config/sidekiq.yml"]

      linuxParameters = { initProcessEnabled = true }

      environment = local.container_environment_base
      secrets     = local.container_secrets

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.sidekiq.name
          "awslogs-region"        = "us-west-2"
          "awslogs-stream-prefix" = "sidekiq"
        }
      }
    },
  ])

  tags = { Environment = var.environment }
}

# ---- ECS services ----
# desired_count starts at 0 — scale up after SSM parameters are populated.
# task_definition and desired_count are excluded from lifecycle management so
# that CircleCI deployments can update them without terraform reverting.

resource "aws_ecs_service" "web" {
  name                   = "unicycling-registration-${var.environment}-web"
  cluster                = aws_ecs_cluster.app.id
  task_definition        = aws_ecs_task_definition.web.arn
  desired_count          = 0
  launch_type            = "FARGATE"
  enable_execute_command = true

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs.arn
    container_name   = "web"
    container_port   = 3000
  }

  lifecycle {
    ignore_changes = [desired_count, task_definition]
  }

  tags = { Environment = var.environment }
}

resource "aws_ecs_service" "sidekiq" {
  name                   = "unicycling-registration-${var.environment}-sidekiq"
  cluster                = aws_ecs_cluster.app.id
  task_definition        = aws_ecs_task_definition.sidekiq.arn
  desired_count          = 0
  launch_type            = "FARGATE"
  enable_execute_command = true

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = true
  }

  lifecycle {
    ignore_changes = [desired_count, task_definition]
  }

  tags = { Environment = var.environment }
}
