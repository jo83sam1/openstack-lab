#!/bin/bash

# Make sure you have provided a project name as input
if [ -z "$1" ]; then
  echo "Usage: $0 <PROJECT_NAME>"
  exit 1
fi

PROJECT_NAME="$1"
REGION="us-central1"  # You can modify this if needed, or make it dynamic too

# Generate the Ansible inventory filename dynamically based on the project name
INVENTORY_FILE="inventory_${PROJECT_NAME}.ini"

# Initialize the inventory file
echo "[all]" > "$INVENTORY_FILE"
echo "" >> "$INVENTORY_FILE"

# Fetch compute instances using gcloud
echo "Fetching compute instances in project: $PROJECT_NAME"

# Loop over all instances and fetch their external IPs (if any)
gcloud compute instances list --project="$PROJECT_NAME" --format="json" | jq -r '.[] | "\(.name) \(.networkInterfaces[0].accessConfigs[0].natIP)"' | while read line; do
    INSTANCE_NAME=$(echo $line | awk '{print $1}')
    EXTERNAL_IP=$(echo $line | awk '{print $2}')

    if [ "$EXTERNAL_IP" != "null" ]; then
        # Add instance to the inventory if it has an external IP
        echo "$INSTANCE_NAME ansible_host=$EXTERNAL_IP" >> "$INVENTORY_FILE"
    fi
done

# Fetch Terraform outputs for predefined instances
Bastion_IP=$(terraform output -raw bastion_external_ip)
Controller_IP=$(terraform output -raw controller_internal_ip)
Compute_IP=$(terraform output -raw compute_internal_ip)

# Add predefined instances to the inventory if they exist
echo "[bastion]" >> "$INVENTORY_FILE"
if [ ! -z "$Bastion_IP" ]; then
    echo "$Bastion_IP" >> "$INVENTORY_FILE"
fi
echo "" >> "$INVENTORY_FILE"

echo "[controller]" >> "$INVENTORY_FILE"
if [ ! -z "$Controller_IP" ]; then
    echo "$Controller_IP" >> "$INVENTORY_FILE"
fi
echo "" >> "$INVENTORY_FILE"

echo "[compute]" >> "$INVENTORY_FILE"
if [ ! -z "$Compute_IP" ]; then
    echo "$Compute_IP" >> "$INVENTORY_FILE"
fi
echo "" >> "$INVENTORY_FILE"

# Add any other host groups or variables you need
echo "[all:vars]" >> "$INVENTORY_FILE"
echo "ansible_ssh_user=ubuntu" >> "$INVENTORY_FILE"

# Final message
echo "Ansible inventory file '$INVENTORY_FILE' generated successfully!"