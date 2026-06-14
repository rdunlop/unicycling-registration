output "alb_dns_name" {
  description = "ALB DNS name — use this to smoke-test before DNS cutover"
  value       = aws_lb.app.dns_name
}

output "acm_certificate_arn" {
  description = "ARN of the ACM certificate"
  value       = aws_acm_certificate_validation.app.certificate_arn
}

output "target_group_arn" {
  description = "ARN of the ALB target group (EC2)"
  value       = aws_lb_target_group.app.arn
}

output "https_listener_arn" {
  description = "ARN of the HTTPS ALB listener — set as ALB_LISTENER_ARN in SSM/env so the Rails app can attach per-tenant ACM certs at runtime"
  value       = aws_lb_listener.https.arn
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.app.name
}

output "ecs_web_service_name" {
  description = "ECS web service name"
  value       = aws_ecs_service.web.name
}

output "ecs_sidekiq_service_name" {
  description = "ECS sidekiq service name"
  value       = aws_ecs_service.sidekiq.name
}

output "ecs_target_group_arn" {
  description = "ARN of the ECS ALB target group"
  value       = aws_lb_target_group.ecs.arn
}
