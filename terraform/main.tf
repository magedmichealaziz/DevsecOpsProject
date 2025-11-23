terraform {
  required_version = ">= 1.0"
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.42"
    }
    local = {
      source = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token
}

# Use existing SSH key "my-study-key"
data "hcloud_ssh_key" "existing_key" {
  name = "my-study-key"
}

# Create private network with unique name
resource "hcloud_network" "k8s_network" {
  name     = "k8s-network-${formatdate("YYYYMMDD-hhmmss", timestamp())}"
  ip_range = "10.0.0.0/16"
}

resource "hcloud_network_subnet" "k8s_subnet" {
  network_id   = hcloud_network.k8s_network.id
  type         = "server"
  network_zone = "eu-central"
  ip_range     = "10.0.1.0/24"
}

# Create control plane node
resource "hcloud_server" "control_plane" {
  name        = "VM1-masterK8S-Jenkins"
  server_type = var.control_plane_type
  image       = var.os_image
  location    = var.location
  ssh_keys    = [data.hcloud_ssh_key.existing_key.id]
  
  network {
    network_id = hcloud_network.k8s_network.id
    ip         = "10.0.1.10"
  }

  user_data = file("${path.module}/user_data_control_plane.sh")

  labels = {
    role = "control-plane"
  }

  depends_on = [hcloud_network_subnet.k8s_subnet]
}

# Create worker node 1
resource "hcloud_server" "worker_node_1" {
  name        = "VM2-worker1-Nexus-Prometheus-Grafana"
  server_type = var.worker_type
  image       = var.os_image
  location    = var.location
  ssh_keys    = [data.hcloud_ssh_key.existing_key.id]
  
  network {
    network_id = hcloud_network.k8s_network.id
    ip         = "10.0.1.11"
  }

  user_data = file("${path.module}/user_data_worker.sh")

  labels = {
    role = "worker"
  }

  depends_on = [hcloud_network_subnet.k8s_subnet]
}

# Create worker node 2
resource "hcloud_server" "worker_node_2" {
  name        = "VM3-worker2-SonarQube"
  server_type = var.worker_type
  image       = var.os_image
  location    = var.location
  ssh_keys    = [data.hcloud_ssh_key.existing_key.id]
  
  network {
    network_id = hcloud_network.k8s_network.id
    ip         = "10.0.1.12"
  }

  user_data = file("${path.module}/user_data_worker.sh")

  labels = {
    role = "worker"
  }

  depends_on = [hcloud_network_subnet.k8s_subnet]
}

# Generate Ansible inventory
resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/inventory.tpl", {
    control_plane_ip = hcloud_server.control_plane.ipv4_address
    worker_1_ip      = hcloud_server.worker_node_1.ipv4_address
    worker_2_ip      = hcloud_server.worker_node_2.ipv4_address
    ssh_private_key  = var.ssh_private_key_path
  })
  filename = "../ansible/inventory.yml"
}