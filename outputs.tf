resource "local_file" "slurm-inventory" {
  content  = templatefile(
      "${path.module}/files/inventory.tpl", {
        is_mysql    = var.mysql_jobs_backend
        platform_id = var.platform_id
        master      = "${nebius_compute_instance.master.network_interface.0.nat_ip_address} ansible_user=slurm"
        nodes       = join("\n", [for node in nebius_compute_instance.slurm-node: "${node.network_interface.0.nat_ip_address} ansible_user=slurm"])
      })
  filename = "./inventory.yaml"
}

resource "local_file" "slurm-conf" {
  content  = templatefile(
      "${path.module}/files/slurm.conf.tpl", {
        cluster_nodes_count = var.cluster_nodes_count
        hostname            = var.mysql_jobs_backend ? nebius_mdb_mysql_cluster.slurm-mysql-cluster[0].host[0].fqdn : ""
        password            = random_password.mysql.result
        is_mysql            = var.mysql_jobs_backend
      })
  filename = "files/slurm.conf"
}

resource "local_file" "slurmdbd-conf" {
  count = var.mysql_jobs_backend ? 1 : 0
  content  = templatefile(
      "${path.module}/files/slurmdbd.conf.tpl", {
        hostname = nebius_mdb_mysql_cluster.slurm-mysql-cluster[0].host[0].fqdn
        password = random_password.mysql.result
      })
  filename = "files/slurmdbd.conf"
}