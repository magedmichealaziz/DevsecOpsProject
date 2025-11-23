output "control_plane_ip" {
  description = "IP address of control plane node"
  value       = hcloud_server.control_plane.ipv4_address
}

output "worker_1_ip" {
  description = "IP address of worker node 1"
  value       = hcloud_server.worker_node_1.ipv4_address
}

output "worker_2_ip" {
  description = "IP address of worker node 2"
  value       = hcloud_server.worker_node_2.ipv4_address
}

output "kubeconfig_command" {
  description = "Command to retrieve kubeconfig"
  value       = "ssh root@${hcloud_server.control_plane.ipv4_address} cat /etc/kubernetes/admin.conf > kubeconfig.yml"
}

output "cluster_info" {
  description = "Cluster connection information"
  value       = <<EOT

Kubernetes Cluster Deployment Complete!

Control Plane Node: ${hcloud_server.control_plane.ipv4_address} (VM1-masterK8S-Jenkins)
Worker Node 1: ${hcloud_server.worker_node_1.ipv4_address} (VM2-worker1-Nexus-Prometheus-Grafana)
Worker Node 2: ${hcloud_server.worker_node_2.ipv4_address} (VM3-worker2-SonarQube)

To get kubeconfig run:
ssh root@${hcloud_server.control_plane.ipv4_address} cat /etc/kubernetes/admin.conf > kubeconfig.yml

To use kubectl:
export KUBECONFIG=./kubeconfig.yml

EOT
}