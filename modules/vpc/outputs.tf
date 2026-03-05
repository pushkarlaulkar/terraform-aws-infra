output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.oik8s_vpc.id
}

output "az_list" {
  value = data.aws_availability_zones.available.names
}

output "az_count" {
  value = length(data.aws_availability_zones.available.names)
}

output "public_subnets" {
  value = { for s in aws_subnet.public_subnet : s.tags["Name"] => s.id }
}

output "private_subnets" {
  value = { for s in aws_subnet.private_subnet : s.tags["Name"] => s.id }
}

output "security_group" {
  value = aws_default_security_group.oik8s_default_sg.id
}