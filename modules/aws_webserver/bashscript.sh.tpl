#!/bin/bash
set -ex

sudo yum -y update && sudo yum -y install iputils curl sshfs docker

sudo systemctl start docker
sudo systemctl enable docker

sudo usermod -aG wheel ec2-user
sudo usermod -a -G docker ec2-user

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 636276102612.dkr.ecr.us-east-1.amazonaws.com

curl -sLo kind https://kind.sigs.k8s.io/dl/v0.11.0/kind-linux-amd64
sudo install -o root -g root -m 0755 kind /usr/local/bin/kind

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

wget https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.18.0/kubeseal-0.18.0-linux-amd64.tar.gz
tar xfz kubeseal-0.18.0-linux-amd64.tar.gz
sudo install -m 755 kubeseal /usr/local/bin/kubeseal
