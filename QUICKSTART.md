# Kubernetes Cluster Quick Start Guide

Get your 2-node Kubernetes cluster running on AWS in under 15 minutes!

## Prerequisites Checklist

- [ ] AWS account with appropriate permissions
- [ ] AWS CLI installed and configured (`aws configure`)
- [ ] Terraform >= 1.0 installed
- [ ] SSH key pair (will be auto-generated if missing)
- [ ] ~$0.10/hour budget (~$70/month if left running)

## 3-Command Quick Deploy

```bash
# 1. Initialize Terraform
terraform init

# 2. Deploy infrastructure
terraform apply -auto-approve

# 3. Wait 5-10 minutes, then SSH to master
ssh -i ~/.ssh/id_rsa ubuntu@<MASTER_IP>
```

Or use the automated script:

```bash
chmod +x deploy.sh
./deploy.sh
```

## First Steps After Deployment

### 1. Verify Master Node (wait 5-10 minutes after apply)

```bash
# SSH to master
ssh -i ~/.ssh/id_rsa ubuntu@<MASTER_IP>

# Check cluster status
kubectl get nodes
kubectl get pods -A

# Get join command
cat /home/ubuntu/join-command.sh
```

### 2. Join Worker Node

```bash
# Copy the join command from master, then SSH to worker
ssh -i ~/.ssh/id_rsa ubuntu@<WORKER_IP>

# Run the join command (example)
sudo kubeadm join <MASTER_IP>:6443 --token <TOKEN> --discovery-token-ca-cert-hash sha256:<HASH>
```

### 3. Verify Cluster

Back on the master:

```bash
kubectl get nodes
# Should show both nodes as Ready

kubectl get pods -A
# All pods should be Running
```

## Quick Test Deployment

```bash
# Deploy test nginx application
kubectl apply -f k8s-examples/nginx-deployment.yaml

# Check deployment
kubectl get deployments
kubectl get pods
kubectl get svc

# Access the service
curl http://<NODE_IP>:30080
```

## Quick Troubleshooting

### Nodes Not Ready?
```bash
# Check kubelet status
sudo systemctl status kubelet

# Check logs
sudo journalctl -u kubelet -f
```

### Worker Won't Join?
```bash
# On master, generate new token
kubeadm token create --print-join-command

# On worker, reset and try again
sudo kubeadm reset -f
sudo <new-join-command>
```

### Pods Stuck Pending?
```bash
# Check pod details
kubectl describe pod <POD_NAME>

# Check node resources
kubectl describe nodes
```

## Cost Estimates

**Hourly:** ~$0.10/hour
- 2x t3.medium instances: $0.0416/hour each
- 60GB EBS gp3: $0.008/hour
- Data transfer: minimal

**Monthly (if left running):** ~$70/month
- 2x t3.medium: ~$60/month
- 60GB EBS: ~$6/month
- Other: ~$4/month

**Recommendation:** Destroy when not in use!

```bash
terraform destroy -auto-approve
```

## Using the Makefile

```bash
make help          # Show all commands
make apply         # Deploy infrastructure
make ssh-master    # SSH to master node
make ssh-worker    # SSH to worker node
make logs-master   # View initialization logs
make destroy       # Destroy everything
```

## Next Steps

- Read [README.md](README.md) for detailed documentation
- Check [ARCHITECTURE.md](ARCHITECTURE.md) for infrastructure details
- See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common issues
- Explore [k8s-examples/](k8s-examples/) for sample applications

## Important Notes

- Master initialization takes 5-10 minutes
- Worker must be joined manually after master is ready
- Join tokens expire after 24 hours
- Always destroy resources when done to avoid charges
- Security groups allow SSH from anywhere (restrict in production)

## Support

For issues, check:
1. Cloud-init logs: `sudo tail -f /var/log/cloud-init-output.log`
2. Kubelet logs: `sudo journalctl -u kubelet -f`
3. [TROUBLESHOOTING.md](TROUBLESHOOTING.md) guide
