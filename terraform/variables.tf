variable "hcloud_token" {
  description = "Hetzner Cloud API Token"
  type        = string
  sensitive   = true
}

variable "location" {
  description = "Hetzner Cloud location"
  type        = string
  default     = "nbg1"
}

variable "control_plane_type" {
  description = "Server type for control plane node"
  type        = string
  default     = "cx23"
}

variable "worker_type" {
  description = "Server type for worker nodes"
  type        = string
  default     = "cx23"
}

variable "os_image" {
  description = "Operating system image"
  type        = string
  default     = "ubuntu-24.04"
}

variable "ssh_private_key_path" {
  description = "Path to SSH private key"
  type        = string
  default     = "~/.ssh/id_rsa"
}