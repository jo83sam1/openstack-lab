# variables.tf
variable "project_id" {
  description = "The project ID for GCP"
  type        = string
}

variable "region" {
  description = "The region for GCP resources"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "The zone for GCP resources"
  type        = string
  default     = "us-central1-a"
}

variable "credentials_file" {
  description = "Path to the GCP service account key file"
  type        = string
  sensitive   = true
}

variable "ssh_user" {
  description = "Default SSH username"
  type        = string
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key file"
  type        = string
  sensitive   = true
}
