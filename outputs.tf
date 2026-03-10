# Accessing the control plane IPs from the ec2 module
output "control_plane_ips" {
  description = "Public and Private IPs for Control Plane nodes"
  value       = module.oik8s_ec2.control_plane_ips
}

# Accessing the worker node IPs from the ec2 module
output "worker_node_ips" {
  description = "Public and Private IPs for Worker nodes"
  value       = module.oik8s_ec2.worker_node_ips
}

# Accessing the GPU node IPs from the ec2 module
output "gpu_node_ips" {
  description = "Public and Private IPs for GPU nodes"
  value       = module.oik8s_ec2.gpu_node_ips
}

output "bastion_host_ip" {
  description = "Public and Private IPs for Bastion host"
  value       = module.oik8s_ec2.bastion_host_ip
}

output "nlb_dns_name" {
  description = "API server endpoint"
  value       = "${module.oik8s_nlb.control_plane_nlb_dns}:6443"
}
