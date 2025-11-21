#!/bin/bash

#Install Kind
KIND_VERSION=v0.30.0
curl -Lo ./kind "https://github.com/kubernetes-sigs/kind/releases/download/${KIND_VERSION}/kind-linux-amd64"

#Ensure proper permissions for kind binary
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

#Install kubectl
KUBECTL_VERSION=v1.34.0
curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

