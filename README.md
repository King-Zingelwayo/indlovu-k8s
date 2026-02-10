# Two-Node Kubernetes Cluster on AWS with Terraform

Production-ready Infrastructure-as-Code solution for deploying a complete Kubernetes cluster on AWS EC2 instances.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                      AWS VPC (10.0.0.0/16)              │
│                                                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │         Public Subnet (10.0.1.0/24)                │ │
│  │                                                     │ │
│  │  ┌──────────────────┐                              │ │
│  │  │  NAT Instance    │                              │ │
│  │  │  t3.nano         │                              │ │
│  │  └──────────────────┘                              │ │
│  │                                                     │ │
│  └────────────────────────────────────────────────────┘ │
│                           │                              │
│  ┌────────────────────────────────────────────────────┐ │
│  │        Private Subnet (10.0.2.0/24)                │ │
│  │                                                     │ │
│  │  ┌──────────────────┐    ┌──────────────────┐    │ │
│  │  │  Master Node     │    │  Worker Node     │    │ │
│  │  │  t3.medium       │    │  t3.medium       │    │ │
│  │  │  2 vCPU, 4GB RAM │    │  2 vCPU, 4GB RAM │    │ │
│  │  │  30GB EBS        │    │  30GB EBS        │    │ │
│  │  │  Control Plane   │◄───┤  kubelet         │    │ │
│  │  │  + Worker        │    │  kube-proxy      │    │ │
│  │  └──────────────────┘    └──────────────────┘    │ │
│  │                                                     │ │
│  └────────────────────────────────────────────────────┘ │
│                           │                              │
│                  ┌────────▼────────┐                     │
│                  │ Internet Gateway │                     │
│                  └─────────────────┘                     │
└─────────────────────────────────────────────────────────┘
```

## Features

- ✅ Private subnet for enhanced security
- ✅ NAT instance for cost-effective egress (87% cheaper than NAT Gateway)
- ✅ Production-ready Kubernetes v1.28+
- ✅ Automated infrastructure provisioning with Terraform
- ✅ Both flat and modular Terraform architectures
- ✅ Containerd runtime with systemd cgroup driver
- ✅ Flannel CNI for pod networking
- ✅ Encrypted EBS volumes
- ✅ Comprehensive security group configuration
- ✅ Automated initialization scripts
- ✅ Complete documentation and examples
- ✅ Cost-optimized for learning and development

## File Structure

```
.
├── main.tf                      # Flat architecture - all resources
├── variables.tf                 # Input variables
├── outputs.tf                   # Output values
├── versions.tf                  # Provider versions
├── locals.tf                    # Local values
├── terraform.tfvars             # Variable values
├── main-modular.tf              # Modular architecture entry point
├── outputs-modular.tf           # Modular outputs
├── modules/
│   ├── vpc/                     # VPC module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── security/                # Security groups & SSH key
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── compute/                 # EC2 instances
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── scripts/
│   ├── master-init.sh           # Master node initialization
│   └── worker-init.sh           # Worker node initialization
├── k8s-examples/
│   ├── nginx-deployment.yaml    # Sample deployment
│   ├── multi-container-pod.yaml # Multi-container example
│   └── test-cluster.sh          # Cluster test script
├── deploy.sh                    # Automated deployment script
├── Makefile                     # Automation commands
├── QUICKSTART.md                # Quick start guide
├── README.md                    # This file
├── ARCHITECTURE.md              # Detailed architecture
├── TROUBLESHOOTING.md           # Troubleshooting guide
└── .gitignore                   # Git ignore rules
```

## Prerequisites

1. **AWS Account** with appropriate IAM permissions
2. **AWS CLI** installed and configured
   ```bash
   aws configure
   ```
3. **Terraform** >= 1.0
   ```bash
   # macOS
   brew install terraform
   
   # Linux
   wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
   unzip terraform_1.6.0_linux_amd64.zip
   sudo mv terraform /usr/local/bin/
   ```
4. **SSH Key Pair** (auto-generated if missing)

## Quick Start

See [QUICKSTART.md](QUICKSTART.md) for the fastest path to a running cluster.

## Detailed Deployment Instructions

### Step 1: Clone and Configure

```bash
# Navigate to project directory
cd baremetal

# Review and customize variables (optional)
vim terraform.tfvars
```

### Step 2: Choose Architecture

**Option A: Flat Architecture (Recommended for Learning)**
```bash
# Use default main.tf
terraform init
terraform plan
terraform apply
```

**Option B: Modular Architecture (Recommended for Production)**
```bash
# Rename files to use modular architecture
mv main.tf main-flat.tf
mv outputs.tf outputs-flat.tf
mv main-modular.tf main.tf
mv outputs-modular.tf outputs.tf

terraform init
terraform plan
terraform apply
```

### Step 3: Wait for Initialization

Master node initialization takes 5-10 minutes. Monitor progress:

```bash
# Get master IP from Terraform output
MASTER_IP=$(terraform output -raw master_public_ip)

# SSH and watch logs
ssh -i ~/.ssh/id_rsa ubuntu@$MASTER_IP
sudo tail -f /var/log/cloud-init-output.log
```

### Step 4: Verify Master

```bash
# On master node
kubectl get nodes
kubectl get pods -A

# Should see master node as Ready
# All system pods should be Running
```

### Step 5: Join Worker Node

```bash
# On master, get join command
cat /home/ubuntu/join-command.sh

# SSH to worker
WORKER_IP=$(terraform output -raw worker_public_ip)
ssh -i ~/.ssh/id_rsa ubuntu@$WORKER_IP

# Run join command (copy from master)
sudo kubeadm join <MASTER_IP>:6443 --token <TOKEN> \
  --discovery-token-ca-cert-hash sha256:<HASH>
```

### Step 6: Verify Cluster

```bash
# On master
kubectl get nodes
# Both nodes should show as Ready

kubectl get pods -A
# All pods should be Running
```

## Configuration Options

Edit `terraform.tfvars` to customize:

| Variable | Default | Description |
|----------|---------|-------------|
| aws_region | us-east-1 | AWS region |
| cluster_name | k8s-cluster | Cluster name |
| master_instance_type | t3.medium | Master instance type |
| worker_instance_type | t3.medium | Worker instance type |
| public_key_path | ~/.ssh/id_rsa.pub | SSH public key path |
| pod_network_cidr | 10.244.0.0/16 | Pod network CIDR |
| vpc_cidr | 10.0.0.0/16 | VPC CIDR |
| kubernetes_version | 1.28 | Kubernetes version |

## Testing the Cluster

### Run Automated Tests

```bash
chmod +x k8s-examples/test-cluster.sh
./k8s-examples/test-cluster.sh
```

### Manual Testing

```bash
# Deploy nginx
kubectl apply -f k8s-examples/nginx-deployment.yaml

# Check status
kubectl get deployments
kubectl get pods
kubectl get svc

# Access service
NODE_IP=$(terraform output -raw master_public_ip)
curl http://$NODE_IP:30080
```

### Deploy Multi-Container Pod

```bash
kubectl apply -f k8s-examples/multi-container-pod.yaml
kubectl get pods
kubectl logs multi-container-pod -c sidecar
```

## Troubleshooting

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for detailed troubleshooting steps.

### Quick Checks

```bash
# Check node status
kubectl get nodes -o wide

# Check system pods
kubectl get pods -n kube-system

# Check kubelet
sudo systemctl status kubelet

# View logs
sudo journalctl -u kubelet -f
```

## Cost Breakdown

### Hourly Costs
- 2x t3.medium EC2: $0.0416/hour × 2 = $0.0832/hour
- 1x t3.nano NAT: $0.0052/hour
- 60GB EBS gp3: $0.08/GB-month ÷ 730 hours = $0.0066/hour
- Data transfer: ~$0.001/hour
- **Total: ~$0.11/hour**

### Monthly Costs (if left running 24/7)
- EC2 instances: ~$60/month
- NAT instance: ~$4/month
- EBS storage: ~$6/month
- Data transfer: ~$4/month
- **Total: ~$74/month**

### Cost Savings vs NAT Gateway
- NAT Gateway: ~$32/month + data processing fees
- NAT Instance (t3.nano): ~$4/month
- **Savings: ~$28/month (87% cheaper)**

### Cost Optimization
```bash
# Destroy when not in use
terraform destroy -auto-approve

# Or stop instances (still charges for EBS)
aws ec2 stop-instances --instance-ids <INSTANCE_IDS>
```

## Cleanup

```bash
# Destroy all resources
terraform destroy

# Or use Makefile
make destroy
```

## Production Recommendations

This setup is optimized for learning and development. For production:

1. **High Availability**
   - Use 3+ master nodes
   - Deploy across multiple availability zones
   - Use AWS ELB for API server

2. **Security**
   - Restrict security group rules to specific IPs
   - Use private subnets with NAT gateway
   - Enable AWS CloudTrail and VPC Flow Logs
   - Use AWS Secrets Manager for sensitive data

3. **Networking**
   - Use AWS VPC CNI instead of Flannel
   - Implement network policies
   - Use private API server endpoint

4. **Storage**
   - Use EBS CSI driver for persistent volumes
   - Implement backup strategy
   - Use EFS for shared storage

5. **Monitoring**
   - Install metrics-server
   - Deploy Prometheus and Grafana
   - Enable CloudWatch Container Insights

6. **Scaling**
   - Use larger instance types (t3.large or m5.large)
   - Implement cluster autoscaler
   - Use managed node groups

7. **Consider Managed Services**
   - AWS EKS (Elastic Kubernetes Service)
   - Reduces operational overhead
   - Built-in HA and security

## Useful Commands

```bash
# Terraform
make init          # Initialize Terraform
make plan          # Show execution plan
make apply         # Apply changes
make destroy       # Destroy infrastructure

# SSH
make ssh-master    # SSH to master node
make ssh-worker    # SSH to worker node

# Logs
make logs-master   # View master init logs
make logs-worker   # View worker init logs

# Kubernetes
kubectl get nodes                    # List nodes
kubectl get pods -A                  # List all pods
kubectl get svc -A                   # List all services
kubectl describe node <NODE>         # Node details
kubectl logs <POD> -n <NAMESPACE>    # Pod logs
kubectl exec -it <POD> -- /bin/bash  # Shell into pod
```

## Architecture Details

See [ARCHITECTURE.md](ARCHITECTURE.md) for:
- Detailed network diagrams
- Component architecture
- Port matrix
- Security group rules
- Data flow diagrams

## Support and Contributing

For issues or questions:
1. Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
2. Review cloud-init logs on nodes
3. Check Kubernetes component logs

## License

This project is provided as-is for educational purposes.

## Acknowledgments

- Kubernetes documentation
- Terraform AWS provider documentation
- AWS best practices guides
