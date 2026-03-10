variable "control_plane_count" {
  description = "Number of control plane nodes (1 or 3)"
  type        = number
}

variable "worker_node_count" {
  description = "Number of worker nodes (1 or 3)"
  type        = number
}

variable "gpu_count" {
  description = "Number of GPU nodes"
  type        = number
}

variable "expose_api_publicly" {
  description = "Enable public access to the K8s API (port 6443)"
  type        = bool
  default     = true
}

variable "aws_region" {
  description = "The AWS region to deploy into"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
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
