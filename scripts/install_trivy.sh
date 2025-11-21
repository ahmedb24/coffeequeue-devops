#!/bin/bash

#Install necessary dependencies
sudo apt-get install wget apt-transport-https gnupg lsb-release -y

#Download Trivy GPG key
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null

#Add Trivy repository to Apt sources
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list

#Update package manager repositories
sudo apt-get update
sudo apt-get install trivy -y