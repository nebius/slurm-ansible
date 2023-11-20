resource "local_file" "slurm-inventory" {
  content  = templatefile(
      "${path.module}/files/inventory.tpl", {
        master = "${nebius_compute_instance.master.network_interface.0.nat_ip_address} ansible_user=slurm"
        nodes = join("\n", [for node in nebius_compute_instance.slurm-node: "${node.network_interface.0.nat_ip_address} ansible_user=slurm"])
      })
  filename = "./inventory.yaml"
}

output "mysql_password" {
  description = "Password for mysql user slurm for slurmdb database"
  value       = random_password.mysql.result
  sensitive   = true
}


# output "hostname" {
#   description = "Hostname"
#   value       = nebius_mdb_mysql_cluster.slurm-mysql-cluster.host[0].fqdn
# }


resource "local_file" "slurm-conf" {
  content  = templatefile(
      "${path.module}/files/slurm.conf.tpl", {
        cluster_nodes_count = var.cluster_nodes_count
        hostname = nebius_mdb_mysql_cluster.slurm-mysql-cluster.host[0].fqdn
        password = random_password.mysql.result
      })
  filename = "files/slurm.conf"
}

resource "local_file" "slurmdbd-conf" {
  content  = templatefile(
      "${path.module}/files/slurmdbd.conf.tpl", {
        hostname = nebius_mdb_mysql_cluster.slurm-mysql-cluster.host[0].fqdn
        password = random_password.mysql.result
      })
  filename = "files/slurmdbd.conf"
}