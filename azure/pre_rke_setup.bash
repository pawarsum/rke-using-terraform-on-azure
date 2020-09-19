#!/bin/bash
echo "Installing docker from curl https://releases.rancher.com/install-docker/18.09.2.sh..."
curl https://releases.rancher.com/install-docker/18.09.2.sh | sh

echo "Add docker to the user group"
sudo usermod -aG docker ${username}