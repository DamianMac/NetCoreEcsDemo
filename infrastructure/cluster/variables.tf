variable "region" {
  description = "The AWS region to create resources in."
  default     = "ap-southeast-2"
}

variable "az1" {
  description = "Primary availability zone"
  default     = "ap-southeast-2a"
}

variable "az2" {
  description = "Secondary availability zone"
  default     = "ap-southeast-2c"
}

variable "ecs_cluster_name" {
  description = "The name of the Amazon ECS cluster."
  default     = "staging-demo-cluster"
}

variable "amis" {
  description = "Which AMI to spawn. Defaults to the AWS ECS optimized images."

  default = {
    ap-southeast-2 = "ami-efda148d"
  }
}

variable "autoscale_min" {
  default     = "1"
  description = "Minimum autoscale (number of EC2)"
}

variable "autoscale_max" {
  default     = "4"
  description = "Maximum autoscale (number of EC2)"
}

variable "autoscale_desired" {
  default     = "2"
  description = "Desired autoscale (number of EC2)"
}

variable "instance_type" {
  default = "t2.medium"
}

