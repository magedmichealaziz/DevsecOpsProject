all:
  hosts:
    ${control_plane_ip}:
    ${worker_1_ip}:
    ${worker_2_ip}:
  children:
    control_plane:
      hosts:
        ${control_plane_ip}:
    workers:
      hosts:
        ${worker_1_ip}:
        ${worker_2_ip}:
  vars:
    ansible_user: root
    ansible_ssh_private_key_file: ${ssh_private_key}
    ansible_ssh_common_args: '-o StrictHostKeyChecking=no'