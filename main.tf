terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.34.0" # Explicitly pinned version
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.2.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.7.0"
    }
  }
}

# --- Provider ---
provider "aws" {
  region = var.aws_region
}

# --- Data: Ubuntu 24.04 AMI (Region-Agnostic) ---
data "aws_ami" "ubuntu_24_04" {
  most_recent = true
  owners      = ["099720109477"] # Canonical's Official AWS ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "oik8s_vpc" {
  source     = "./modules/vpc"
  vpc_name   = "oik8s-vpc"
  cidr_block = var.vpc_cidr
  env_name   = var.env_name
}

module "oik8s_ec2" {
  source                      = "./modules/ec2"
  ami_id                      = data.aws_ami.ubuntu_24_04.id
  control_plane_count         = var.control_plane_count
  worker_node_count           = var.worker_node_count
  gpu_count                   = var.gpu_count
  control_plane_instance_type = "t2.large"
  worker_node_instance_type   = "t2.large"
  gpu_node_instance_type      = "g5.xlarge"
  env_name                    = var.env_name
  oiadmin_password            = var.oiadmin_password

  # private_subnets_map = module.oik8s_vpc.private_subnets
  public_subnets_map = module.oik8s_vpc.public_subnets
  security_group_id  = module.oik8s_vpc.security_group
}

module "oik8s_nlb" {
  source              = "./modules/nlb"
  public_subnets_map  = module.oik8s_vpc.public_subnets
  vpc_id              = module.oik8s_vpc.vpc_id
  target_instance_ids = module.oik8s_ec2.control_plane_ids
  env_name            = var.env_name
}  env_name            = var.env_name
}
