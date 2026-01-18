#!/bin/bash

# K3s simple setup - all in one node

# 1. Specify k3s installation parameters
export INSTALL_K3S_VERSION="v1.27.6+k3s1" 
export K3S_TOKEN="my_super_secret_token"
export INSTALL_K3S_EXEC="--node-taint CriticalAddonsOnly=true:NoExecute --tls-san $(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"

# 2. Install k3s control panel
# INSTALL_K3S_SKIP_SELINUX_RPM=true sh - mainly to skip selinux rpm installation on Amazon Linux 2
curl -sfL https://get.k3s.io | INSTALL_K3S_SKIP_SELINUX_RPM=true sh -

# 3. Wait for k3s installation
while ! sudo systemctl is-active --quiet k3s; do
    sleep 2
    echo "Wait for K3s service ..."
done

# 4. Set permission for kubeconfig
mkdir -p /home/ssm-user/.kube
sudo cp /etc/rancher/k3s/k3s.yaml /home/ssm-user/.kube/config
sudo chown ssm-user:ssm-user /home/ssm-user/.kube/config
sed -i 's/127.0.0.1/'"$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"'/g' /home/ssm-user/.kube/config

# 5. Install common tools
sudo yum install -y git vim htop

echo "K3s cluster installed successfully!"
echo "API Server IP: https://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):6443"
echo "Use the following command to configure kubectl locally:"
echo "scp ssm-user@$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):~/.kube/config ~/.kube/k3s-config"
echo "export KUBECONFIG=~/.kube/k3s-config"