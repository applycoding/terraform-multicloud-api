resource "aws_security_group" "alb" {
  name        = "${var.name}-alb"
  description = "Public HTTPS entry point for the demo API."
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, { Name = "${var.name}-alb" })
}

resource "aws_vpc_security_group_ingress_rule" "https" {
  security_group_id = aws_security_group.alb.id
  description       = "HTTPS from the public internet"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_lb" "this" {
  name                       = "${var.name}-alb"
  load_balancer_type         = "application"
  internal                   = false
  ip_address_type            = "ipv4"
  security_groups            = [aws_security_group.alb.id]
  subnets                    = var.public_subnet_ids
  drop_invalid_header_fields = true
  enable_deletion_protection = true
  enable_http2               = true
  idle_timeout               = 60
  desync_mitigation_mode     = "strictest"

  access_logs {
    bucket  = aws_s3_bucket.alb.id
    prefix  = "alb"
    enabled = true
  }

  tags = merge(var.tags, { Name = "${var.name}-alb" })

  depends_on = [aws_s3_bucket_policy.alb]
}

resource "aws_lb_target_group" "api" {
  #checkov:skip=CKV_AWS_378:TLS terminates at the load balancer. Tasks speak HTTP on a private subnet and are not reachable from the internet.
  name                 = "${var.name}-api"
  port                 = var.container_port
  protocol             = "HTTP"
  protocol_version     = "HTTP1"
  target_type          = "ip"
  vpc_id               = var.vpc_id
  deregistration_delay = 30

  health_check {
    enabled             = true
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
    port                = "traffic-port"
  }

  tags = merge(var.tags, { Name = "${var.name}-api" })
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }

  tags = merge(var.tags, { Name = "${var.name}-https" })
}
