resource "aws_security_group" "alb" {
  name        = "unicycling-registration-${var.environment}-alb"
  description = "ALB security group for ${var.environment}"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "unicycling-registration-${var.environment}-alb"
    Environment = var.environment
  }
}

# Adds port 80 ingress from the ALB to the existing EC2 security group.
# Does not import or replace the full security group — only appends a rule.
resource "aws_security_group_rule" "ec2_from_alb" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = var.ec2_security_group_id
  source_security_group_id = aws_security_group.alb.id
  description              = "Allow HTTP from ${var.environment} ALB"
}
