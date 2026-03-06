# Outputs for Control Plane Instances
output "control_plane_ips" {
  description = "Public and Private IPs for Control Plane nodes"
  value = [
    for i, instance in aws_instance.control_plane : {
      name       = instance.tags["Name"]
      public_ip  = instance.public_ip
      primary_private_ip  = instance.private_ip
      secondary_private_ip = aws_network_interface.control_plane_secondary_nic[i].private_ip
    }
  ]
}

# Outputs for Worker Node Instances
output "worker_node_ips" {
  description = "Public and Private IPs for Worker nodes"
  value = [
    for i, instance in aws_instance.worker_node : {
      name       = instance.tags["Name"]
      public_ip  = instance.public_ip
      primary_private_ip  = instance.private_ip
      secondary_private_ip = aws_network_interface.worker_node_secondary_nic[i].private_ip
    }
  ]
}

# Outputs for GPU Node Instances
output "gpu_node_ips" {
  description = "Public and Private IPs for GPU nodes"
  value = [
    for i, instance in aws_instance.gpu_node : {
      name       = instance.tags["Name"]
      public_ip  = instance.public_ip
      primary_private_ip  = instance.private_ip
      secondary_private_ip = aws_network_interface.gpu_node_secondary_nic[i].private_ip
    }
  ]
}

output "control_plane_ids" {
  description = "List of IDs of control plane instances"
  # The [*] is the 'splat' operator—it grabs all IDs from the count
  value = aws_instance.control_plane[*].id
}
