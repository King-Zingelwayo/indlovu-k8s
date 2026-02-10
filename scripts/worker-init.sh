#!/bin/bash
set -e

# Disable swap
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Load kernel modules
cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

# Configure sysctl
cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sysctl --system

# Install containerd
apt-get update
apt-get install -y ca-certificates curl gnupg lsb-release
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -y containerd.io

# Configure containerd
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
systemctl restart containerd
systemctl enable containerd

# Install kubeadm, kubelet, kubectl
curl -fsSL https://pkgs.k8s.io/core:/stable:/v${kubernetes_version}/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v${kubernetes_version}/deb/ /" | tee /etc/apt/sources.list.d/kubernetes.list
apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

# Wait for master to be ready and retrieve join command
echo "Waiting for master to initialize..."
REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)

# Install AWS CLI if not present
if ! command -v aws &> /dev/null; then
  apt-get install -y awscli
fi

for i in {1..60}; do
  JOIN_COMMAND=$(aws ssm get-parameter \
    --name "/k8s/${cluster_name}/join-command" \
    --with-decryption \
    --query 'Parameter.Value' \
    --output text \
    --region $REGION 2>/dev/null)
  
  if [ -n "$JOIN_COMMAND" ] && [ "$JOIN_COMMAND" != "None" ]; then
    echo "Join command retrieved, joining cluster..."
    eval "sudo $JOIN_COMMAND"
    if [ $? -eq 0 ]; then
      echo "Worker node joined cluster successfully!"
      exit 0
    else
      echo "Join failed, retrying..."
    fi
  fi
  
  echo "Waiting for master... attempt $i/60"
  sleep 30
done

echo "Failed to retrieve join command from master after 30 minutes"
echo "Worker node initialization complete! Ready to join cluster manually."
exit 1
