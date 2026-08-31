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
    path                = "/"
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
    path                = "/health"
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
    path                = "/health"
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

resource "aws_lb_target_group" "tg_mcp" {
  name        = "tg-mcp"
  port        = 8084
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name = "tg-mcp"
  }
}

resource "aws_lb_target_group_attachment" "bff_front" {
  for_each = {
    orchestrator = { port = 8080, target = var.ec2_ids_triaige[0], target_group = aws_lb_target_group.tg_orchestrator.arn }
    ai          = { port = 8082, target = var.ec2_ids_triaige[0], target_group = aws_lb_target_group.tg_ai.arn }
    notification = { port = 8083, target = var.ec2_ids_triaige[0], target_group = aws_lb_target_group.tg_notification.arn }
    frontend    = { port = 3000, target = var.ec2_ids_triaige[0], target_group = aws_lb_target_group.tg_frontend.arn }
  }

  target_group_arn = each.value.target_group
  target_id        = each.value.target
  port             = each.value.port
}

resource "aws_lb_target_group_attachment" "mcp" {
  target_group_arn = aws_lb_target_group.tg_mcp.arn
  target_id        = var.ec2_ids_triaige[1]
  port             = 8084
}

resource "aws_lb_listener" "listener_443" {
  count              = var.acm_certificate_arn == "" ? 0 : 1
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

resource "aws_lb_listener_rule" "mcp" {
  count        = var.acm_certificate_arn == "" ? 0 : 1
  listener_arn = aws_lb_listener.listener_443[0].arn
  priority     = 40

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_mcp.arn
  }

  condition {
    path_pattern {
      values = ["/api/mcp/*"]
    }
  }
}
