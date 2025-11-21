#!/bin/bash

#Update package manager repositories
sudo apt-get update && sudo apt upgrade -y

#Install necessary dependencies
sudo apt-get install -y ca-certificates curl

#Create directory for Docker GPG key
sudo install -m 0755 -d /etc/apt/keyrings

#Download Docker's GPG key
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg-o /etc/apt/keyrings/docker.asc

#Ensure proper permissions for the key
sudo chmod a+r /etc/apt/keyrings/docker.asc

#Add Docker repository to Apt sources
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \ $(./etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

#Update package manager repositories
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

#Add the current user to the docker group to run Docker commands without sudo
sudo usermod -aG docker $USER




#Install OpenJDK 21 JRE Headless
sudo apt install openjdk-21-jre-headless -y

#Download Jenkins GPG key
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
  
#Add Jenkins repository to package manager sources
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

# Update package manager repositories
sudo apt-get update

#Install Jenkins
sudo apt-get install jenkins -y




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




#Install necessary dependencies
sudo apt-get install wget apt-transport-https gnupg lsb-release -y

#Download Trivy GPG key
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null

#Add Trivy repository to Apt sources
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list

#Update package manager repositories
sudo apt-get update
sudo apt-get install trivy -y
