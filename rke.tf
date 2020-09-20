terraform {
  required_providers {
    rke = {
      source  = "rancher/rke"
      version = "1.1.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.28.0"
    }
  }
  ##To enable Azure Strorage as terraform backend
  /*backend "azurerm" {
    resource_group_name  = "XXXXXXXXXXXXXXXXX"
    storage_account_name = "XXXXXXXXXXXXXXXXX"
    container_name       = "XXXXXXXXXXXXXXXXX"
    key                  = "XXXXXXXXXXXXXXXXX"
  }*/
}

module "nodes" {
  source   = "./azure"
  username = var.username
}

resource "rke_cluster" "cluster" {
  nodes {
    address          = module.nodes.public_ip
    internal_address = module.nodes.internal_ip
    user             = var.username
    role             = ["controlplane", "worker", "etcd"]
    ssh_key          = file("~/.ssh/id_rsa")
    docker_socket    = "/var/run/docker.sock"
  }
}

resource "local_file" "kube_cluster_yaml" {
  filename = "kube_config_cluster.yml"
  content  = rke_cluster.cluster.kube_config_yaml
}
