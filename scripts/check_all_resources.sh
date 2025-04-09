#!/bin/bash

# Function to list resources for a specific project
list_resources() {
    local project="$1"
    echo "Listing resources for project: $project"
    gcloud config set project "$project"

    # List compute instances
    echo "  Compute Instances:"
    gcloud compute instances list --format="table(name, zone, status)"
    
    # List disks
    echo "  Disks:"
    gcloud compute disks list --format="table(name, zone, status)"
    
    # List external IPs
    echo "  External IPs:"
    gcloud compute addresses list --format="table(name, region, status)"
    
    # List snapshots
    echo "  Snapshots:"
    gcloud compute snapshots list --format="table(name, status, creationTimestamp)"
    
    # List networks
    echo "  Networks:"
    # gcloud compute networks list --format="table(name, subnetworks, routingConfig)"
    gcloud compute networks list --filter="name!='default'" --format="table(name, subnetworks, routingConfig)"
}

# List all projects
projects=$(gcloud projects list --format="value(projectId)")

# Iterate over each project and list resources
for project in $projects; do
    list_resources "$project"
done
