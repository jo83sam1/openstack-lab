#!/bin/bash

# Define functions for each option
start() {
  for instance in "${instances[@]}"; do
    echo "Starting $instance..."
    gcloud compute instances start "$instance" --zone "$zone"
  done
}

stop() {
  for instance in "${instances[@]}"; do
    echo "Stopping $instance..."
    gcloud compute instances stop "$instance" --zone "$zone"
  done
}

status() {
  if [ "$1" == "all" ]; then
    for instance in "${instances[@]}"; do
      echo "The status of $instance is: $(gcloud compute instances describe "$instance" --zone "$zone" --format 'get(status)')"
    done
  else
    echo "The status of $1 is: $(gcloud compute instances describe "$1" --zone "$zone" --format 'get(status)')"
  fi
}

terraform_destroy() {
  echo "Destroying existing Terraform resources..."
  terraform destroy -auto-approve
  rm -rf .terraform terraform.tfstate* *.backup
}

# List of instances
instances=("bastion" "compute" "controller")  # Modify as per your instances
zone="your-gcp-zone"  # Replace with the GCP zone you're using

# Main logic for the script
if [ "$1" == "start" ]; then
  start
elif [ "$1" == "stop" ]; then
  stop
elif [ "$1" == "status" ]; then
  if [ -n "$2" ] && [ "$2" == "all" ]; then
    status "all"
  else
    status "$2"
  fi
elif [ "$1" == "destroy" ]; then
  terraform_destroy
else
  echo "Usage: $0 {start|stop|status|destroy}"
fi
