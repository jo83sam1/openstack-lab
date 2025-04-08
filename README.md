# OpenStack Lab on GCP and AWS

This project automates the deployment of a multi-node OpenStack cluster using Terraform and Ansible.

## Structure
- `terraform/` – Infrastructure provisioning code for GCP and AWS
- `ansible/` – OpenStack setup using Ansible roles
- `scripts/` – Utility scripts like dynamic inventory

## Usage

### Terraform
```bash
cd terraform/gcp  # or terraform/aws
terraform init
terraform apply -var-file="terraform.tfvars"
```

### Ansible
```bash
cd ansible
ansible-playbook -i inventory/hosts.ini site.yml
```
