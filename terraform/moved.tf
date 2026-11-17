# Resources that moved into the unicycling-infra modules. These take effect on the next apply, which
# updates state without touching the infrastructure. Remove each block once every environment has
# been applied past this change.

# ---- alb-ingress ----

moved {
  from = aws_security_group.alb
  to   = module.alb.aws_security_group.alb
}

moved {
  from = aws_lb.app
  to   = module.alb.aws_lb.app
}

# Legacy EC2 path removed: the 0% target group and the port 80 rule on the EC2 security group.
removed {
  from = aws_lb_target_group.app
  lifecycle {
    destroy = true
  }
}

removed {
  from = aws_security_group_rule.ec2_from_alb
  lifecycle {
    destroy = true
  }
}

moved {
  from = aws_lb_target_group.ecs
  to   = module.alb.aws_lb_target_group.ecs
}

moved {
  from = aws_lb_listener.http
  to   = module.alb.aws_lb_listener.http
}

moved {
  from = aws_lb_listener.https
  to   = module.alb.aws_lb_listener.https
}

moved {
  from = aws_acm_certificate.app
  to   = module.alb.aws_acm_certificate.app
}

moved {
  from = aws_route53_record.acm_validation
  to   = module.alb.aws_route53_record.acm_validation
}

moved {
  from = aws_acm_certificate_validation.app
  to   = module.alb.aws_acm_certificate_validation.app
}

moved {
  from = aws_route53_record.app
  to   = module.alb.aws_route53_record.app
}

moved {
  from = aws_route53_record.registration
  to   = module.alb.aws_route53_record.alb
}

moved {
  from = aws_route53_record.wildcard
  to   = module.alb.aws_route53_record.wildcard
}

# ---- ecs-app ----

moved {
  from = aws_ecs_cluster.app
  to   = module.ecs_app.aws_ecs_cluster.app
}

moved {
  from = aws_cloudwatch_log_group.web
  to   = module.ecs_app.aws_cloudwatch_log_group.web
}

moved {
  from = aws_cloudwatch_log_group.sidekiq
  to   = module.ecs_app.aws_cloudwatch_log_group.sidekiq
}

moved {
  from = aws_security_group.ecs_tasks
  to   = module.ecs_app.aws_security_group.ecs_tasks
}

moved {
  from = aws_security_group_rule.rds_from_ecs
  to   = module.ecs_app.aws_security_group_rule.database_from_ecs
}

moved {
  from = aws_security_group_rule.redis_from_ecs
  to   = module.ecs_app.aws_security_group_rule.redis_from_ecs
}

moved {
  from = aws_iam_role.ecs_execution
  to   = module.ecs_app.aws_iam_role.ecs_execution
}

moved {
  from = aws_iam_role_policy_attachment.ecs_execution_managed
  to   = module.ecs_app.aws_iam_role_policy_attachment.ecs_execution_managed
}

moved {
  from = aws_iam_role_policy.ecs_execution_ssm
  to   = module.ecs_app.aws_iam_role_policy.ecs_execution_ssm
}

moved {
  from = aws_iam_role.ecs_task
  to   = module.ecs_app.aws_iam_role.ecs_task
}

moved {
  from = aws_iam_role_policy.ecs_task_permissions
  to   = module.ecs_app.aws_iam_role_policy.ecs_task_permissions
}

moved {
  from = aws_ecs_task_definition.web
  to   = module.ecs_app.aws_ecs_task_definition.web
}

moved {
  from = aws_ecs_task_definition.sidekiq
  to   = module.ecs_app.aws_ecs_task_definition.sidekiq
}

moved {
  from = aws_ecs_service.web
  to   = module.ecs_app.aws_ecs_service.web
}

moved {
  from = aws_ecs_service.sidekiq
  to   = module.ecs_app.aws_ecs_service.sidekiq
}

moved {
  from = aws_iam_role.eventbridge_ecs
  to   = module.ecs_app.aws_iam_role.eventbridge_ecs[0]
}

moved {
  from = aws_iam_role_policy.eventbridge_ecs
  to   = module.ecs_app.aws_iam_role_policy.eventbridge_ecs[0]
}

moved {
  from = aws_cloudwatch_event_rule.update_registration_period
  to   = module.ecs_app.aws_cloudwatch_event_rule.scheduled["update-registration-period"]
}

moved {
  from = aws_cloudwatch_event_target.update_registration_period
  to   = module.ecs_app.aws_cloudwatch_event_target.scheduled["update-registration-period"]
}
