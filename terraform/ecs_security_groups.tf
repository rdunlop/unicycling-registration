# Security group for ECS Fargate tasks (web + sidekiq).
# Inbound restricted to the ALB only; egress open so tasks can reach
# RDS, ElastiCache, ECR, SSM, and external APIs.
resource "aws_security_group" "ecs_tasks" {
  name        = "unicycling-registration-${var.environment}-ecs-tasks"
  description = "ECS Fargate tasks for ${var.environment}"
  vpc_id      = var.vpc_id

  ingress {
    description     = "App port from ALB"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "unicycling-registration-${var.environment}-ecs-tasks"
    Environment = var.environment
  }
}
