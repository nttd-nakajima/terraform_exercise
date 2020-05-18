# ===========================
# ALB
# ===========================
resource "aws_alb" "web" {
  name                       = "ex2-alb"
  security_groups            = [aws_security_group.alb.id]
  subnets                    = aws_subnet.public.*.id
  internal                   = false
  enable_deletion_protection = false

  tags = {
    Name = "ex2-alb"
  }
}

# ===========================
# ALB - Listener
# ===========================
resource "aws_alb_listener" "web" {
  load_balancer_arn = aws_alb.web.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.web.arn
  }
}

resource "aws_lb_listener_rule" "forward" {
  listener_arn = aws_alb_listener.web.arn
  priority     = 99

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.web.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}

resource "aws_alb_target_group" "web" {
  name     = "ex2-web-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    path = "/index.html"
  }
}

resource "aws_lb_target_group_attachment" "web" {
  count            = 2
  target_group_arn = element(aws_alb_target_group.web.*.arn, count.index % 2)
  target_id        = element(aws_instance.web.*.id, count.index % 2)
  port             = 80
}