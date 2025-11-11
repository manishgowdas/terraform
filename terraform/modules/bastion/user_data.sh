#!/bin/bash
# Bastion Host Initialization Script

set -xe

echo "===== System update ====="
yum update -y

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
yum install -y unzip
unzip -q awscliv2.zip
./aws/install
rm -rf awscliv2.zip aws

# Install Kubernetes tools
curl -o /usr/local/bin/kubectl -LO "https://dl.k8s.io/release/$(curl -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x /usr/local/bin/kubectl

curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz"
tar -xzf eksctl_$(uname -s)_amd64.tar.gz -C /usr/local/bin
chmod +x /usr/local/bin/eksctl
rm -f eksctl_$(uname -s)_amd64.tar.gz

# Install Helm
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Install Docker
yum install -y docker
systemctl enable docker
systemctl start docker
usermod -aG docker ec2-user || true

# Install Java & Jenkins
yum install -y java-17-amazon-corretto
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
yum upgrade -y
yum install -y jenkins
systemctl enable jenkins
systemctl start jenkins

# Create a secondary user
useradd -m -s /bin/bash jump || true
usermod -aG wheel jump

# Install common utilities
yum install -y git jq tree wget curl vim htop net-tools

# Ensure SSM Agent
if ! systemctl is-enabled amazon-ssm-agent &>/dev/null; then
  yum install -y amazon-ssm-agent
fi
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

echo "===== Bastion setup complete ====="
