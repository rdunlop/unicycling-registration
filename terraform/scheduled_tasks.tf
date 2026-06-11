# Replaces the whenever/cron setup that ran on EC2.
# EventBridge triggers one-off ECS tasks on a schedule; each task exits when done.
# Note: encryption:renew_and_update_certificate (Let's Encrypt) is NOT replicated
# here — ACM handles certificate renewal automatically.

resource "aws_iam_role" "eventbridge_ecs" {
  name = "unicycling-registration-${var.environment}-eventbridge-ecs"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "events.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "eventbridge_ecs" {
  name = "run-ecs-task"
  role = aws_iam_role.eventbridge_ecs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "ecs:RunTask"
        Resource = "arn:aws:ecs:us-west-2:${data.aws_caller_identity.current.account_id}:task-definition/${aws_ecs_task_definition.web.family}"
        Condition = {
          ArnLike = { "ecs:cluster" = aws_ecs_cluster.app.arn }
        }
      },
      {
        Effect = "Allow"
        Action = "iam:PassRole"
        Resource = [
          aws_iam_role.ecs_execution.arn,
          aws_iam_role.ecs_task.arn,
        ]
      },
    ]
  })
}

# ---- rake update_registration_period ----
# Mirrors: every 1.day, at: '12am' in config/schedule.rb

resource "aws_cloudwatch_event_rule" "update_registration_period" {
  name                = "unicycling-registration-${var.environment}-update-registration-period"
  description         = "Daily rake update_registration_period (replaces whenever cron)"
  schedule_expression = "cron(0 0 * * ? *)"
}

resource "aws_cloudwatch_event_target" "update_registration_period" {
  rule     = aws_cloudwatch_event_rule.update_registration_period.name
  arn      = aws_ecs_cluster.app.arn
  role_arn = aws_iam_role.eventbridge_ecs.arn

  ecs_target {
    # No revision number — EventBridge picks up the latest active task definition
    # after each deployment.
    task_definition_arn = "arn:aws:ecs:us-west-2:${data.aws_caller_identity.current.account_id}:task-definition/${aws_ecs_task_definition.web.family}"
    task_count          = 1
    launch_type         = "FARGATE"

    network_configuration {
      subnets          = var.subnet_ids
      security_groups  = [aws_security_group.ecs_tasks.id]
      assign_public_ip = true
    }
  }

  input = jsonencode({
    containerOverrides = [{
      name    = "web"
      command = ["bundle", "exec", "rake", "update_registration_period"]
    }]
  })
}
