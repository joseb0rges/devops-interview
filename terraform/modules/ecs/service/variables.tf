variable "subnet_ids_priv" { type = list(string)}
variable "app_name" {}
variable "project_name" {}
variable "env" {}
variable "listener" {}
variable "container_definitions_path" {}
variable "container_port" {}
variable "vpc_id" {}
variable "log_group_path" {}
variable "alb_sg_id" {}
variable "target_group_arn" {}
variable "service_name" {}
variable "cluster_arn" {}
variable "container_name" {}