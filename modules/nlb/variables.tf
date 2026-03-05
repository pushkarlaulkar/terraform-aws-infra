variable "public_subnets_map" {
  description = "Map of subnet names to subnet IDs"
  type        = map(string)
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "target_instance_ids" {
  type        = list(string)
  description = "List of instance IDs to attach to the TG"
}

variable "env_name" {
  description = "Env Name"
  type        = string
}