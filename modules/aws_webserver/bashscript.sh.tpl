#!/bin/bash
set -ex

sudo yum -y update && sudo yum -y install iputils curl docker

sudo systemctl start docker
sudo systemctl enable docker

sudo usermod -aG wheel ec2-user
sudo usermod -a -G docker ec2-user

aws s3 cp s3://bucket-sanah/script/docker-deploy.sh /home/ec2-user/docker-deploy.sh
chmod +x /home/ec2-user/docker-deploy.sh
/home/ec2-user/docker-script.sh

curl -sLo kind https://kind.sigs.k8s.io/dl/v0.11.0/kind-linux-amd64
sudo install -o root -g root -m 0755 kind /usr/local/bin/kind
rm -f ./kind

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm -f ./kubectl

cat <<EOF | kind create cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  image: kindest/node:v1.19.11@sha256:07db187ae84b4b7de440a73886f008cf903fcf5764ba8106a9fd5243d6f32729
  extraPortMappings:
  - containerPort: 30000
    hostPort: 30000
  - containerPort: 30001
    hostPort: 30001
EOF