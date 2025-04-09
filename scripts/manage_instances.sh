#!/bin/bash

# Set variables
ZONE="us-central1-a"
PROJECT="joeopenstack"
TF_STATE_FILE="terraform.tfstate"  # Terraform state file

# Function to extract instance names from Terraform state
get_instance_names() {
  INSTANCE_NAMES=$(jq -r '.resources[] | select(.type=="google_compute_instance") | .name' $TF_STATE_FILE)
  echo "$INSTANCE_NAMES"
}

# Function to extract network resources from Terraform state
get_network_resources() {
  NETWORK_RESOURCES=$(jq -r '.resources[] | select(.type=="google_compute_network" or .type=="google_compute_subnetwork") | .name' $TF_STATE_FILE)
  echo "$NETWORK_RESOURCES"
}

# Function to extract storage resources from Terraform state
get_storage_resources() {
  STORAGE_RESOURCES=$(jq -r '.resources[] | select(.type=="google_compute_disk") | .name' $TF_STATE_FILE)
  echo "$STORAGE_RESOURCES"
}

# Function to start an instance
start_instance() {
  echo "Starting instance: $1..."
  gcloud compute instances start $1 --zone=$ZONE --project=$PROJECT
}

# Function to stop an instance
stop_instance() {
  echo "Stopping instance: $1..."
  gcloud compute instances stop $1 --zone=$ZONE --project=$PROJECT
}

# Function to check the status of an instance
check_status() {
  STATUS=$(gcloud compute instances describe $1 --zone=$ZONE --project=$PROJECT --format="get(status)")
  echo "The status of $1 is: $STATUS"
}

# Function to delete network resources
delete_network_resource() {
  echo "Deleting network resource: $1..."
  gcloud compute networks subnets delete $1 --region=$ZONE --project=$PROJECT
}

# Function to delete storage resources
delete_storage_resource() {
  echo "Deleting storage resource: $1..."
  gcloud compute disks delete $1 --zone=$ZONE --project=$PROJECT
}

# Function to display the usage message
usage() {
  echo "Usage: $0 {start|stop|status|delete} [all|instance_name|network_name|storage_name]"
  exit 1
}

# Check the command line argument and perform the corresponding operation
if [ $# -lt 1 ]; then
  usage
fi

ACTION=$1
TARGET=$2

# If 'all' is provided, get all instance, network, and storage resources
if [ "$TARGET" == "all" ]; then
  INSTANCES=$(get_instance_names)
  NETWORKS=$(get_network_resources)
  STORAGE=$(get_storage_resources)
else
  INSTANCES=$TARGET
  NETWORKS=$TARGET
  STORAGE=$TARGET
fi

# Loop through each instance
for INSTANCE in $INSTANCES; do
  case "$ACTION" in
    start)
      start_instance $INSTANCE
      ;;
    stop)
      stop_instance $INSTANCE
      ;;
    status)
      check_status $INSTANCE
      ;;
    delete)
      echo "Delete action is not supported for instances."
      ;;
    *)
      usage
      ;;
  esac
done

# Loop through each network resource
for NETWORK in $NETWORKS; do
  case "$ACTION" in
    delete)
      delete_network_resource $NETWORK
      ;;
    *)
      echo "No action supported for networks other than delete."
      ;;
  esac
done

# Loop through each storage resource
for DISK in $STORAGE; do
  case "$ACTION" in
    delete)
      delete_storage_resource $DISK
      ;;
    *)
      echo "No action supported for storage other than delete."
      ;;
  esac
done
