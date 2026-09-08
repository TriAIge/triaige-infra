resource "aws_lb" "alb_triaige" {
  name               = "alb-triaige"
  internal           = false
  load_balancer_type = "application"
  ip_address_type    = "ipv4"
  security_groups    = var.security_groups_id_alb
  subnets            = var.subnet_ids

  enable_deletion_protection = false

  tags = {
    Name = "alb-triaige"
  }
}

resource "aws_lb_target_group" "tg_orchestrator" {
  name        = "tg-orchestrator"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/actuator/health"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name = "tg-orchestrator"
  }
}

resource "aws_lb_target_group" "tg_ai" {
  name        = "tg-ai"
  port        = 8082
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/actuator/health"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name = "tg-ai"
  }
}

resource "aws_lb_target_group" "tg_notification" {
  name        = "tg-notification"
  port        = 8083
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/actuator/health"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name = "tg-notification"
  }
}

resource "aws_lb_target_group" "tg_frontend" {
  name        = "tg-frontend"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name = "tg-frontend"
  }
}

resource "aws_lb_target_group_attachment" "app" {
  for_each = {
    for pair in setproduct(
      ["orchestrator", "ai", "notification", "frontend"],
      [0, 1]
      ) : "${pair[0]}-${pair[1]}" => {
      port = {
        orchestrator = 8080
        ai           = 8082
        notification = 8083
        frontend     = 3000
      }[pair[0]]
      target = var.ec2_ids_triaige[pair[1]]
      target_group = {
        orchestrator = aws_lb_target_group.tg_orchestrator.arn
        ai           = aws_lb_target_group.tg_ai.arn
        notification = aws_lb_target_group.tg_notification.arn
        frontend     = aws_lb_target_group.tg_frontend.arn
      }[pair[0]]
    }
  }

  target_group_arn = each.value.target_group
  target_id        = each.value.target
  port             = each.value.port
}

resource "aws_lb_listener" "listener_80" {
  load_balancer_arn = aws_lb.alb_triaige.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_frontend.arn
  }
}

resource "aws_lb_listener_rule" "orchestrator_http" {
  listener_arn = aws_lb_listener.listener_80.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_orchestrator.arn
  }

  condition {
    path_pattern {
      values = ["/api/orchestrator/*"]
    }
  }
}

resource "aws_lb_listener_rule" "ai_http" {
  listener_arn = aws_lb_listener.listener_80.arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_ai.arn
  }

  condition {
    path_pattern {
      values = ["/api/ai/*"]
    }
  }
}

resource "aws_lb_listener_rule" "notification_http" {
  listener_arn = aws_lb_listener.listener_80.arn
  priority     = 30

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_notification.arn
  }

  condition {
    path_pattern {
      values = ["/api/notification/*"]
    }
  }
}

# listener_443 so existe se um certificado ACM real for passado em
# var.acm_certificate_arn (default ""). Ate la, o trafego roda por HTTP na
# porta 80 (listener_80 acima) - troque pra HTTPS quando tiver dominio+ACM.
resource "aws_lb_listener" "listener_443" {
  count             = var.acm_certificate_arn == "" ? 0 : 1
  load_balancer_arn = aws_lb.alb_triaige.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_frontend.arn
  }
}

resource "aws_lb_listener_rule" "orchestrator" {
  count        = var.acm_certificate_arn == "" ? 0 : 1
  listener_arn = aws_lb_listener.listener_443[0].arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_orchestrator.arn
  }

  condition {
    path_pattern {
      values = ["/api/orchestrator/*"]
    }
  }
}

resource "aws_lb_listener_rule" "ai" {
  count        = var.acm_certificate_arn == "" ? 0 : 1
  listener_arn = aws_lb_listener.listener_443[0].arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_ai.arn
  }

  condition {
    path_pattern {
      values = ["/api/ai/*"]
    }
  }
}

resource "aws_lb_listener_rule" "notification" {
  count        = var.acm_certificate_arn == "" ? 0 : 1
  listener_arn = aws_lb_listener.listener_443[0].arn
  priority     = 30

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_notification.arn
  }

  condition {
    path_pattern {
      values = ["/api/notification/*"]
    }
  }
}
