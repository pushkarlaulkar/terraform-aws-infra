output "control_plane_nlb_dns" {
  description = "The DNS name of the control plane Network Load Balancer"
  value       = aws_lb.oik8s_control_plane_nlb.dns_name
}