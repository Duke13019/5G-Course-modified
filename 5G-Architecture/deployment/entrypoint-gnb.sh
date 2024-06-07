#!/bin/bash
# Install the needed packages (wget +yq)
apt-get install wget
wget https://github.com/mikefarah/yq/releases/download/v4.12.2/yq_linux_amd64 -O /usr/bin/yq && chmod +x /usr/bin/yq

# Read the IP address from the shared volume
CORE_IP=$(cat /shared-data/core_ip.txt)

# Get the IP address of the gnb container
GNB_IP=$(hostname -I | awk '{print $1}')

# Write the GNB_IP to a file in the shared volume
echo $GNB_IP > /shared-data/gnb_ip.txt

# Export the shell variables to the environment
export GNB_IP
export CORE_IP

# Update the configuration files using the yq 
yq eval '.amfConfigs[0].address = env(CORE_IP)' ../config/open5gs-gnb.yaml -i
yq eval '.ngapIp = env(GNB_IP)'  ../config/open5gs-gnb.yaml -i 
yq eval '.gtpIp = env(GNB_IP)'  ../config/open5gs-gnb.yaml -i 
yq eval '.linkIp = env(GNB_IP)'  ../config/open5gs-gnb.yaml -i

# Start gnb services
exec ./nr-gnb -c ../config/open5gs-gnb.yaml


# Keep the container running
tail -f /dev/null

