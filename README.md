This Terraform Repo will deploy :-
- **VPC**
  - Subnets ( 2 subnets in each AZ ( 1 Private, 1 Public ) ). The number of available zones for a region are calculated with the data source ( aws_availability_zones ). So if a region has 6 AZ, there will be 12 subnets, 6 Private, 6 Public.
  - Route Tables
    - 1 Private ( Only Local Route ).
    - 1 Public ( Route to internet through IGW ).
  - Interet Gateway.
  - SG's
    - 1 SG for EC2 ( Allowing Port 22 and 6443 ).
    - 1 SG for NLB ( Allowing Port 6443 ).
- **EC2** ( with Public IP in public subnets ) nodes for Kubernetes
  - Control Plane ( Ubuntu 24.04 ).
  - Worker ( Ubuntu 24.04 ).
  - GPU VM with NVIDIA A10G ( Ubuntu 24.04 ).
- **NLB** ( Internet NLB to load balance Kubernetes API Server Port ( 6443 ) among the control plane nodes).

**Initialize**
```
terraform init
```

**Deploy**
```
terraform apply \
  -var 'aws_region=us-east-1' \
  -var 'env_name=demo' \
  -var 'vpc_cidr=10.0.0.0/16' \
  -var 'control_plane_count=1' \
  -var 'gpu_count=1' \
  -var 'worker_node_count=1' \
  -var 'oiadmin_password="Oiai@123!"'
```

**Output** ( Will show EC2 name, public ip, primary & secondary private ip's )
```
control_plane_ips = [
  {
    "name" = "demo-oik8s-control-plane-0"
    "primary_private_ip" = "10.0.0.206"
    "public_ip" = "54.175.229.134"
    "secondary_private_ip" = "10.0.0.123"
  },
]
gpu_node_ips = [
  {
    "name" = "demo-oik8s-gpu-node-0"
    "primary_private_ip" = "10.0.0.213"
    "public_ip" = "18.212.128.227"
    "secondary_private_ip" = "10.0.0.69"
  },
]
worker_node_ips = [
  {
    "name" = "demo-oik8s-worker-node-0"
    "primary_private_ip" = "10.0.0.68"
    "public_ip" = "50.16.63.78"
    "secondary_private_ip" = "10.0.0.211"
  },
]
```
