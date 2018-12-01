resource "aws_alb" "alb-staging-demo" {
  name            = "alb-staging-demo"
  security_groups = ["${aws_security_group.load_balancers.id}"]
  subnets         = ["${aws_subnet.main.id}", "${aws_subnet.secondary.id}"]
  idle_timeout = 30
}

resource "aws_alb_listener" "demo-web-listener" {
    load_balancer_arn = "${aws_alb.alb-staging-demo.id}"
    port              = "80"
    protocol          = "HTTP"
    
  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
      host  =   "www.google.com"
    }
  }
}
