# Create the Network Load Balancer
resource "aws_lb" "oik8s_control_plane_nlb" {
  name               = "${var.env_name}-oik8s-control-plane-nlb"
  internal           = false # Set to true if you only want internal VPC access
  load_balancer_type = "network"
  subnets            = values(var.public_subnets_map)

  security_groups = [aws_security_group.oik8s_nlb_sg.id]

  enable_deletion_protection = false

  tags = {
    Name = "${var.region}-${var.env_name}-oik8s-control-plane-nlb"
  }
}

# Create the Target Group for Port 6443
resource "aws_lb_target_group" "cp_6443_tg" {
  name     = "${var.region}-${var.env_name}-cp-6443-tg"
  port     = 6443
  protocol = "TCP"
  vpc_id   = var.vpc_id # Ensure you pass your VPC ID to the module

  health_check {
    protocol = "TCP"
    port     = 6443
    interval = 30
  }
}

# Create the Listener
resource "aws_lb_listener" "cp_listener" {
  load_balancer_arn = aws_lb.oik8s_control_plane_nlb.arn
  port              = "6443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.cp_6443_tg.arn
  }
}

# Attach the Control Plane Instances to the Target Group
resource "aws_lb_target_group_attachment" "cp_attachment" {
  count            = length(var.target_instance_ids)
  target_group_arn = aws_lb_target_group.cp_6443_tg.arn
  target_id        = var.target_instance_ids[count.index]
  port             = 6443
}

resource "aws_security_group" "oik8s_nlb_sg" {
  name        = "${var.region}-${var.env_name}-oik8s-nlb-sg-allow-6443"
  description = "Security group for NLB allowing port 6443"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow Kubernetes API Server traffic"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound: Allow everything to everywhere
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.region}-${var.env_name}-oik8s-nlb-sg-allow-6443"
  }
}
