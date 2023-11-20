locals {
  cluster_nodes = [for node_num in range(1, var.cluster_nodes_count + 1): "node-${node_num}"]
}

resource "random_password" "mysql" {
  length           = 16
  special          = true
  override_special = ""
}


resource "nebius_compute_gpu_cluster" "slurm-cluster" {
  name               = "slurm-cluster"
  interconnect_type  = "InfiniBand"
  zone               = var.region
}

resource "nebius_iam_service_account" "saccount" {
  name        = "sa-slurm"
  description = "Service account for slurm cluster"
  folder_id   = var.folder_id
}

resource "nebius_resourcemanager_folder_iam_member" "monitoring-editor" {
  folder_id   = var.folder_id
  role        = "monitoring.editor"
  member      = "serviceAccount:${nebius_iam_service_account.saccount.id}"
}

resource "nebius_resourcemanager_folder_iam_member" "container-editor" {
  folder_id   = var.folder_id
  role        = "container-registry.editor"
  member      = "serviceAccount:${nebius_iam_service_account.saccount.id}"
}

resource "nebius_compute_instance" "slurm-node" {
  for_each       = toset( local.cluster_nodes )
  name           = "${each.key}"
  hostname       = "${each.key}"
  platform_id    = "gpu-h100-b"
  zone           = "eu-north1-c"
  gpu_cluster_id = nebius_compute_gpu_cluster.slurm-cluster.id
  service_account_id = nebius_iam_service_account.saccount.id

  resources {
    cores  = "160"
    memory = "1280"
    gpus   = "8"
  }

  boot_disk {
    initialize_params {
      image_id = var.ib_image_id
      size = "1024"
      type = "network-ssd"
    }
  }

  network_interface {
    subnet_id = nebius_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    install-unified-agent = 1
    user-data = templatefile(
      "${path.module}/files/cloud-config.yaml.tftpl", {
        ENROOT_VERSION = "3.4.1"
        is_master      = "0"
        sshkey         = var.sshkey
      })
  }
}


resource "nebius_compute_instance" "master" {
  name           = "node-master"
  platform_id    = "standard-v2"
  hostname       = "node-master"
  zone           = var.region
  
  resources {
    cores  = "16"
    memory = "32"
  }

  boot_disk {
    initialize_params {
      image_id = var.ib_image_id
      size = "100"
      type = "network-ssd"
    }
  }

  network_interface {
    subnet_id = nebius_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    user-data = templatefile(
      "${path.module}/files/cloud-config.yaml.tftpl", {
        ENROOT_VERSION = "3.4.1"
        is_master      = "1"
        sshkey         = var.sshkey
      })
  }
}

resource "nebius_mdb_mysql_cluster" "slurm-mysql-cluster" {
  name                = "nebius-mysql-cluster"
  environment         = "PRODUCTION"
  network_id          = nebius_vpc_network.slurm-network.id
  version             = "8.0" 

  resources {
    resource_preset_id = "s3-c8-m32"
    disk_type_id       = "network-ssd"
    disk_size          = "200"
  }
  mysql_config = {
    innodb_lock_wait_timeout = 900
  }

  host {
    zone             = var.region
    subnet_id        = nebius_vpc_subnet.subnet-1.id
    assign_public_ip = true
  }
}

resource "nebius_mdb_mysql_database" "slurm-db" {
  cluster_id = nebius_mdb_mysql_cluster.slurm-mysql-cluster.id
  name       = "slurm-db"
}

resource "nebius_mdb_mysql_user" "slurmuser" {
  cluster_id =  nebius_mdb_mysql_cluster.slurm-mysql-cluster.id
  name       = "slurm"
  password   = random_password.mysql.result
  permission {
    database_name = nebius_mdb_mysql_database.slurm-db.name
    roles         = ["ALL"]
  }
}



resource "nebius_vpc_network" "slurm-network" {
  name = "slurm-network"
}

resource "nebius_vpc_subnet" "subnet-1" {
  name           = "subnet-1"
  zone           = "eu-north1-c"
  v4_cidr_blocks = ["192.168.10.0/24"]
  network_id     = nebius_vpc_network.slurm-network.id
}
