# Allow ECS tasks to reach the shared RDS instance on port 5432.
# Appends a rule to the existing security group rather than importing it.
resource "aws_security_group_rule" "rds_from_ecs" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = var.rds_security_group_id
  source_security_group_id = aws_security_group.ecs_tasks.id
  description              = "PostgreSQL from ECS tasks (${var.environment})"
}
