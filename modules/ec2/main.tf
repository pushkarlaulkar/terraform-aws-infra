# Generate a secure Private Key
resource "tls_private_key" "oik8s_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content = tls_private_key.oik8s_key.private_key_pem

  # abspath ensures we go to the actual root folder on your machine
  filename = "${abspath(path.root)}/oik8s-key.pem"

  file_permission = "0400"
}

# Create the AWS Key Pair using the public half
resource "aws_key_pair" "oik8s_key_pair" {
  key_name   = "oik8s-key"
  public_key = tls_private_key.oik8s_key.public_key_openssh
}

resource "aws_instance" "control_plane" {
  count         = var.control_plane_count
  ami           = var.ami_id
  instance_type = var.control_plane_instance_type
  #associate_public_ip_address = false
  subnet_id = values(var.public_subnets_map)[count.index % length(var.public_subnets_map)]
  #subnet_id              = values(var.private_subnets_map)[count.index % length(var.private_subnets_map)]
  vpc_security_group_ids = [var.security_group_id]

  # Link the key pair here
  key_name = aws_key_pair.oik8s_key_pair.key_name

  user_data = <<-EOF
            #!/bin/bash

            hostnamectl set-hostname "${var.env_name}-oik8s-control-${count.index}"

            echo "127.0.0.1 ${var.env_name}-oik8s-control-${count.index}" >> /etc/hosts
            apt update
            apt install podman -y
            EOF

  tags = {
    Name = "${var.env_name}-oik8s-control-plane-${count.index}"
  }
}

resource "aws_instance" "worker_node" {
  count         = var.worker_node_count
  ami           = var.ami_id
  instance_type = var.worker_node_instance_type
  #associate_public_ip_address = false
  subnet_id = values(var.public_subnets_map)[count.index % length(var.public_subnets_map)]
  #subnet_id              = values(var.private_subnets_map)[count.index % length(var.private_subnets_map)]
  vpc_security_group_ids = [var.security_group_id]

  # Link the key pair here
  key_name = aws_key_pair.oik8s_key_pair.key_name

  user_data = <<-EOF
            #!/bin/bash

            hostnamectl set-hostname "${var.env_name}-oik8s-oicm-${count.index}"

            echo "127.0.0.1 ${var.env_name}-oik8s-oicm-${count.index}" >> /etc/hosts
            apt update
            apt install podman -y
            EOF

  tags = {
    Name = "${var.env_name}-oik8s-worker-node-${count.index}"
  }
}

resource "aws_instance" "gpu_node" {
  count         = var.gpu_count
  ami           = var.ami_id
  instance_type = var.gpu_node_instance_type
  #associate_public_ip_address = false
  subnet_id = values(var.public_subnets_map)[count.index % length(var.public_subnets_map)]
  #subnet_id              = values(var.private_subnets_map)[count.index % length(var.private_subnets_map)]
  vpc_security_group_ids = [var.security_group_id]

  # Link the key pair here
  key_name = aws_key_pair.oik8s_key_pair.key_name

  user_data = <<-EOF
            #!/bin/bash

            hostnamectl set-hostname "${var.env_name}-oik8s-gpu-${count.index}"

            echo "127.0.0.1 ${var.env_name}-oik8s-gpu-${count.index}" >> /etc/hosts
            apt update
            apt install podman -y
            EOF

  tags = {
    Name = "${var.env_name}-oik8s-gpu-node-${count.index}"
  }
}