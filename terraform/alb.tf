resource "aws_lb" "app" {
  name               = "unicycling-registration-${var.environment}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.subnet_ids

  tags = {
    Name        = "unicycling-registration-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "app" {
  name     = "unicycling-registration-${var.environment}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    # "/" returns 302 for unauthenticated users; 200-399 accepts redirects.
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 30
    timeout             = 5
    matcher             = "200-399"
  }

  tags = {
    Name        = "unicycling-registration-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_lb_target_group_attachment" "app" {
  target_group_arn = aws_lb_target_group.app.arn
  target_id        = var.ec2_instance_id
  port             = 80
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# ECS target group — ip type required for Fargate awsvpc networking.
resource "aws_lb_target_group" "ecs" {
  name        = "unicycling-reg-${var.environment}-ecs"
  port        = 3000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 30
    timeout             = 10
    matcher             = "200-399"
  }

  tags = {
    Name        = "unicycling-reg-${var.environment}-ecs"
    Environment = var.environment
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.app.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate_validation.app.certificate_arn

  # Weighted split between EC2 and ECS. Set ecs_traffic_weight=0 to keep all
  # traffic on EC2, or raise it gradually during cutover (Phase 8/11).
  default_action {
    type = "forward"
    forward {
      target_group {
        arn    = aws_lb_target_group.app.arn
        weight = 100 - var.ecs_traffic_weight
      }
      target_group {
        arn    = aws_lb_target_group.ecs.arn
        weight = var.ecs_traffic_weight
      }
    }
  }
}
