output "alb_dns_name" {
  description = "ALB DNS name, to smoke-test before DNS cutover"
  value       = module.alb.alb_dns_name
}

output "acm_certificate_arn" {
  description = "ARN of the ACM certificate"
  value       = module.alb.acm_certificate_arn
}

output "target_group_arn" {
  description = "ARN of the ECS ALB target group (the EC2 target group was removed in v0.2.0 of the modules)"
  value       = module.alb.target_group_arn
}

output "https_listener_arn" {
  description = "ARN of the HTTPS ALB listener. Set as ALB_LISTENER_ARN so the app can attach per-tenant ACM certs."
  value       = module.alb.https_listener_arn
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = module.ecs_app.cluster_name
}

output "ecs_web_service_name" {
  description = "ECS web service name"
  value       = module.ecs_app.web_service_name
}

output "ecs_sidekiq_service_name" {
  description = "ECS sidekiq service name"
  value       = module.ecs_app.sidekiq_service_name
}

output "ecs_target_group_arn" {
  description = "ARN of the ECS ALB target group"
  value       = module.alb.target_group_arn
}
