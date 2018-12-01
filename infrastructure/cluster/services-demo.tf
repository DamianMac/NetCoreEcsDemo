resource "aws_ecs_task_definition" "demoweb" {
  family                = "demoweb"
  container_definitions = "${file("tasks/demo.json")}"
}

resource "aws_ecs_service" "demoweb" {
  name            = "demoweb"
  cluster         = "${aws_ecs_cluster.main.id}"
  task_definition = "${aws_ecs_task_definition.demoweb.arn}"
  desired_count   = 1
  depends_on      = ["aws_iam_role_policy.ecs_service_role_policy"]

load_balancer {
    target_group_arn = "${aws_alb_target_group.tg-demoweb.id}"
    container_name   = "demoweb"
    container_port   = "4000"
  }
}




resource "aws_alb_target_group" "tg-demoweb" {
  name     = "tg-demoweb"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.main.id}"
  deregistration_delay  = 30
  

 health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 5
    path  = "/health"
  }

  depends_on = [
  "aws_alb.alb-staging-demo",
  ]
}


resource "aws_lb_listener_rule" "demoweb-listener-rule" {
  listener_arn = "${aws_alb_listener.demo-web-listener.arn}"
  priority     = 98

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.tg-demoweb.id}"
  }

  condition {
    field  = "path-pattern"
    values = ["*"]
  }

  depends_on = [
    "aws_alb_listener.demo-web-listener",
  ]
}



