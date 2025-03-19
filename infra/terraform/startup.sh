#!/bin/bash
# Script d'initialisation pour les instances Docker
sudo apt update -y
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker sirciti
