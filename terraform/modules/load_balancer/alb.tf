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

resource "aws_lb_target_group" "tg_triaige_80" {
  name        = "tg-triaige-80"
  port        = 80
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
    Name = "tg-triaige-80"
  }
}

resource "aws_lb_target_group_attachment" "tg_attach_triaige" {
  count = length(var.ec2_ids_triaige)

  target_group_arn = aws_lb_target_group.tg_triaige_80.arn
  target_id        = var.ec2_ids_triaige[count.index]
  port             = 80
}

resource "aws_lb_listener" "listener_80" {
  load_balancer_arn = aws_lb.alb_triaige.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_triaige_80.arn
  }
}
