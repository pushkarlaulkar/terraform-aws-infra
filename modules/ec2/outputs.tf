# Outputs for Control Plane Instances
output "control_plane_ips" {
  description = "Public and Private IPs for Control Plane nodes"
  value = [
    for instance in aws_instance.control_plane : {
      name       = instance.tags["Name"]
      public_ip  = instance.public_ip
      private_ip = instance.private_ip
    }
  ]
}

# Outputs for Worker Node Instances
output "worker_node_ips" {
  description = "Public and Private IPs for Worker nodes"
  value = [
    for instance in aws_instance.worker_node : {
      name       = instance.tags["Name"]
      public_ip  = instance.public_ip
      private_ip = instance.private_ip
    }
  ]
}

# Outputs for GPU Node Instances
output "gpu_node_ips" {
  description = "Public and Private IPs for GPU nodes"
  value = [
    for instance in aws_instance.gpu_node : {
      name       = instance.tags["Name"]
      public_ip  = instance.public_ip
      private_ip = instance.private_ip
    }
  ]
}

output "control_plane_ids" {
  description = "List of IDs of control plane instances"
  # The [*] is the 'splat' operator—it grabs all IDs from the count
  value = aws_instance.control_plane[*].id
}