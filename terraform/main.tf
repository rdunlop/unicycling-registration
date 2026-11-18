# unicycling-registration infrastructure, built from the shared modules in unicycling-infra.
# Pinned to a tag: bump the ref deliberately, then check the plan before applying.

module "alb" {
  source = "git::https://github.com/rdunlop/unicycling-infra.git//modules/alb-ingress?ref=v0.3.0"

  app_name              = "unicycling-registration"
  environment           = var.environment
  vpc_id                = var.vpc_id
  subnet_ids            = var.subnet_ids
  zone_id               = var.zone_id
  domain                = var.domain
  alb_domain            = var.registration_domain
  subject_alt_names     = var.subject_alt_names
  wildcard_domain       = var.wildcard_domain
  # The legacy EC2 target group is gone. Its 0% share of traffic is dropped in this change.
  legacy_ec2            = null
  ecs_target_group_name = "unicycling-reg-${var.environment}-ecs"
  ecs_traffic_weight    = var.ecs_traffic_weight

  # Staging checks /healthcheck, which lets basic auth stay on for the site.
  # Prod stays on "/" until its running image includes /healthcheck; flip it
  # after the prod deploy, or prod targets fail their health checks.
  ecs_health_check_path = var.environment == "staging" ? "/healthcheck" : "/"
}

module "ecs_app" {
  source = "git::https://github.com/rdunlop/unicycling-infra.git//modules/ecs-app?ref=v0.2.0"

  app_name                   = "unicycling-registration"
  environment                = var.environment
  region                     = "us-west-2"
  vpc_id                     = var.vpc_id
  subnet_ids                 = var.subnet_ids
  alb_security_group_id      = module.alb.alb_security_group_id
  target_group_arn           = module.alb.target_group_arn
  database_security_group_id = var.rds_security_group_id
  redis_security_group_id    = var.elasticache_security_group_id
  ecr_repository_url         = var.ecr_repository_url
  image_tag                  = var.image_tag

  # Staging is half the size of prod.
  web_cpu        = var.environment == "staging" ? 1024 : 2048
  web_memory     = var.environment == "staging" ? 2048 : 4096
  sidekiq_cpu    = var.environment == "staging" ? 512 : 1024
  sidekiq_memory = var.environment == "staging" ? 1024 : 2048

  # Staging only: Container Insights standard metrics cost about $70/month across the account.
  container_insights = var.environment == "staging" ? "disabled" : "enabled"

  environment_vars = [
    { name = "RAILS_ENV", value = var.rails_env },
    { name = "PORT", value = "3000" },
    { name = "RAILS_LOG_TO_STDOUT", value = "1" },
    { name = "RAILS_SERVE_STATIC_FILES", value = "true" },
    { name = "RAILS_MAX_THREADS", value = "5" },
    { name = "DOMAIN", value = var.domain },
    { name = "SSL_ENABLED", value = "false" },
    { name = "ROBOTS_DISALLOW_ALL", value = var.environment == "staging" ? "true" : "false" },
  ]

  web_environment_extra = [
    { name = "REDIS_CACHE_URL", value = "redis://127.0.0.1:6379/1" },
  ]

  # Web task only. Not essential, so a cache restart does not stop the web container.
  sidecars = [
    {
      name    = "redis-cache"
      image   = "redis:7-alpine"
      cpu     = 128
      memory  = 256
      command = ["redis-server", "--bind", "127.0.0.1", "--maxmemory", "128mb", "--maxmemory-policy", "allkeys-lru"]
    },
  ]

  # Staging only: HTTP basic auth gate. The SSM parameters must exist at
  # /unicycling-registration/staging/ before this applies, or tasks won't start.
  secret_names = concat([
    "SECRET_KEY_BASE",
    "DATABASE_HOST", "POSTGRES_USER", "POSTGRES_PASSWORD", "POSTGRES_DB",
    "REDIS_URL",
    "AWS_REGION", "AWS_BUCKET", "AWS_ACCESS_KEY", "AWS_SECRET_ACCESS_KEY",
    "MAIL_FULL_EMAIL", "MAIL_SKIP_CONFIRMATION",
    "ERROR_EMAILS", "SERVER_ADMIN_EMAIL", "PAYMENT_NOTICE_EMAIL",
    "GOOGLE_ANALYTICS_TRACKING_ID", "GOOGLE_ANALYTICS_4_TRACKING_ID",
    "HCAPTCHA_SECRET", "HCAPTCHA_SITE_KEY", "RECAPTCHA_PUBLIC_KEY", "RECAPTCHA_PRIVATE_KEY",
    "INSTANCE_CREATION_CODE", "SUPER_ADMIN_UPGRADE_CODE", "INDIVIDUAL_EMAIL_SENDING",
    "CACHE_INSTRUMENTATION", "ALB_LISTENER_ARN",
    "TRANSLATIONS_SUBDOMAIN", "TRANSLATION_WEBSITE_URL",
    "IUF_MEMBERSHIP_API_URL", "IUF_MEMBERSHIP_URL",
    "USA_WILDAPRICOT_ACCOUNT_ID", "USA_WILDAPRICOT_API_KEY",
    "ROLLBAR_ACCESS_TOKEN",
  ], var.environment == "staging" ? ["BASIC_AUTH_USERNAME", "BASIC_AUTH_PASSWORD"] : [])

  # Permissions for the app's own AWS calls. The ECS Exec permissions are added by the module.
  task_policy_statements = [
    {
      Effect   = "Allow"
      Action   = ["s3:PutObject", "s3:GetObject", "s3:DeleteObject", "s3:ListBucket"]
      Resource = "*"
    },
    {
      Effect   = "Allow"
      Action   = ["ses:SendRawEmail", "ses:SendEmail"]
      Resource = "*"
    },
    {
      Effect   = "Allow"
      Action   = ["acm:RequestCertificate", "acm:DescribeCertificate", "acm:ListCertificates"]
      Resource = "*"
    },
    {
      Effect   = "Allow"
      Action   = ["elasticloadbalancing:AddListenerCertificates", "elasticloadbalancing:DescribeListenerCertificates"]
      Resource = "*"
    },
  ]

  scheduled_tasks = [
    {
      name                = "update-registration-period"
      description         = "Daily rake update_registration_period (replaces whenever cron)"
      schedule_expression = "cron(0 0 * * ? *)"
      command             = ["bundle", "exec", "rake", "update_registration_period"]
    },
  ]
}
