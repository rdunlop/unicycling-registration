# Allow ECS tasks to reach ElastiCache (used for Sidekiq queue + ActionCable).
# The endpoint URL is stored in SSM as REDIS_URL — no data source needed here.
resource "aws_security_group_rule" "redis_from_ecs" {
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  security_group_id        = var.elasticache_security_group_id
  source_security_group_id = aws_security_group.ecs_tasks.id
  description              = "Redis from ECS tasks (${var.environment})"
}
