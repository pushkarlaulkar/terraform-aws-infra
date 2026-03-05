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

Initialize
```
terraform init
```

Deploy
```
terraform apply \
  -var 'aws_region=us-east-1' \
  -var 'env_name=demo' \
  -var 'vpc_cidr=10.0.0.0/16' \
  -var 'control_plane_count=1' \
  -var 'gpu_count=1' \
  -var 'worker_node_count=1'
```
