resource "aws_ecs_cluster" "main" {
  name = "staging-demo-cluster"
}

resource "aws_autoscaling_group" "ecs-cluster" {
  #availability_zones = ["${var.availability_zone}"]
  name                 = "ECS ${var.ecs_cluster_name}"
  min_size             = "${var.autoscale_min}"
  max_size             = "${var.autoscale_max}"
  desired_capacity     = "${var.autoscale_desired}"
  health_check_type    = "EC2"
  launch_configuration = "${aws_launch_configuration.ecs.name}"
  vpc_zone_identifier  = ["${aws_subnet.main.id}"]
}

resource "aws_launch_configuration" "ecs" {
  name_prefix                 = "ECS ${var.ecs_cluster_name}-"
  image_id                    = "${lookup(var.amis, var.region)}"
  instance_type               = "${var.instance_type}"
  security_groups             = ["${aws_security_group.ecs-staging.id}"]
  iam_instance_profile        = "${aws_iam_instance_profile.ecs.name}"
  associate_public_ip_address = true
  user_data                   = "#!/bin/bash\necho ECS_CLUSTER='${var.ecs_cluster_name}' > /etc/ecs/ecs.config"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role" "ecs_host_role" {
  name               = "ecs_host_role"
  assume_role_policy = "${file("policies/ecs-role.json")}"
}

resource "aws_iam_role_policy" "ecs_instance_role_policy" {
  name   = "ecs_instance_role_policy"
  policy = "${file("policies/ecs-instance-role-policy.json")}"
  role   = "${aws_iam_role.ecs_host_role.id}"
}

resource "aws_iam_role" "ecs_service_role" {
  name               = "ecs_service_role"
  assume_role_policy = "${file("policies/ecs-role.json")}"
}

resource "aws_iam_role_policy" "ecs_service_role_policy" {
  name   = "ecs_service_role_policy"
  policy = "${file("policies/ecs-service-role-policy.json")}"
  role   = "${aws_iam_role.ecs_service_role.id}"
}

resource "aws_iam_instance_profile" "ecs" {
  name  = "ecs-instance-profile"
  path  = "/"
  roles = ["${aws_iam_role.ecs_host_role.name}"]
}
