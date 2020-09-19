terraform {
  required_providers {
    rke = {
      source  = "rancher/rke"
      version = "1.1.0"
    }
  }
}

provider "rke" {
  log_file = "rke_debug.log"
  debug    = "true"
}

module "nodes" {
  source = "./azure"
}

resource "rke_cluster" "cluster" {
  nodes {
    address          = module.nodes.public_ip
    internal_address = module.nodes.internal_ip
    user             = "kuberoot"
    role             = ["controlplane", "worker", "etcd"]
    ssh_key          = file("~/.ssh/id_rsa")
    docker_socket    = "/var/run/docker.sock"
  }
}

resource "local_file" "kube_cluster_yaml" {
  filename = "kube_config_cluster.yml"
  content  = rke_cluster.cluster.kube_config_yaml
}
