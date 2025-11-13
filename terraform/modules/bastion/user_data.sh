#!/bin/bash
# Bastion Host Initialization Script (Stable Version)
set -xe

# Log setup
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1
echo "===== Bastion setup started at $(date) ====="

# Function to safely run yum commands (wait for lock)
yum_safe() {
  local retries=10
  local count=0
  until yum "$@" -y; do
    ((count++))
    if [ "$count" -ge "$retries" ]; then
      echo "YUM lock could not be acquired after $retries attempts"
      return 1
    fi
    echo "YUM lock held, retrying ($count/$retries)..."
    sleep 10
  done
}

# System update
echo "===== System update ====="
yum_safe update

# Basic packages
echo "===== Installing base tools ====="
yum_safe install unzip git jq tree wget curl vim htop net-tools amazon-ssm-agent

# Install AWS CLI v2
echo "===== Installing AWS CLI ====="
cd /tmp
curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
./aws/install || true
rm -rf awscliv2.zip aws
aws --version || echo "AWS CLI install verification failed."

# Install kubectl (latest stable)
echo "===== Installing kubectl ====="
KUBECTL_VERSION="$(curl -L -s https://dl.k8s.io/release/stable.txt)"
if [[ -n "$KUBECTL_VERSION" ]]; then
  curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
  install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
  kubectl version --client --short || true
else
  echo "Failed to fetch kubectl version. Skipping."
fi

# Install eksctl
echo "===== Installing eksctl ====="
curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz"
tar -xzf eksctl_$(uname -s)_amd64.tar.gz -C /usr/local/bin
chmod +x /usr/local/bin/eksctl
rm -f eksctl_$(uname -s)_amd64.tar.gz
eksctl version || true

# Install Helm
echo "===== Installing Helm ====="
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash || true
helm version || true

# Install Docker
echo "===== Installing Docker ====="
yum_safe install docker
systemctl enable docker
systemctl start docker
usermod -aG docker ec2-user || true

# Install Java & Jenkins
echo "===== Installing Java & Jenkins ====="
yum_safe install java-17-amazon-corretto
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
yum_safe install jenkins
systemctl enable jenkins
systemctl start jenkins

# Create secondary user
echo "===== Creating jump user ====="
useradd -m -s /bin/bash jump || true
usermod -aG wheel jump || true

# Ensure SSM Agent is running
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

echo "===== Bastion setup completed successfully at $(date) ====="

