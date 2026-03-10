variable "region" {
  description = "The AWS region to deploy into"
  type        = string
}

variable "ami_id" {
  description = "The AMI ID passed from the root data source"
  type        = string
}

variable "control_plane_count" {
  type = number
}

variable "worker_node_count" {
  description = "Number of worker nodes (1 or 3)"
  type        = number
}

variable "gpu_count" {
  type = number
}

#variable "private_subnets_map" {
#  description = "Map of subnet names to subnet IDs"
#  type        = map(string)
#}

variable "public_subnets_map" {
  description = "Map of subnet names to subnet IDs"
  type        = map(string)
}

variable "security_group_id" {
  type = string
}

variable "control_plane_instance_type" {
  type = string
}

variable "worker_node_instance_type" {
  type = string
}

variable "gpu_node_instance_type" {
  type = string
}

variable "env_name" {
  description = "Env Name"
  type        = string
}

variable "oiadmin_password" {
  description = "The password for the oiadmin user"
  type        = string
  sensitive   = true
}
