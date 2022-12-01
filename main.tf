terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "~> 4.38.0"
    }
  }
}

provider "google" {
  project = "project"
}

resource "google_container_cluster" "cluster" {
  name     = "test"
  location = "asia-southeast1-b"
  min_master_version = "1.22.12-gke.300"
  network = "projects/gcp-202011216-001/global/networks/XXXX"
  subnetwork = "projects/gcp-202011216-001/regions/asia-southeast1/subnetworks/XXXX"
  default_max_pods_per_node = 64
  remove_default_node_pool = true
  initial_node_count       = 1
  enable_intranode_visibility = false
  ip_allocation_policy {
    cluster_secondary_range_name = "gke-pods"
    services_secondary_range_name = "gke-service"
  }
  resource_labels = {
    "env" = "test"
  }
  addons_config {
    http_load_balancing {
      disabled = false
    }
    horizontal_pod_autoscaling {
      disabled = false
    }
    network_policy_config {
      disabled = false
    }
  }
  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }
  private_cluster_config {
    enable_private_endpoint = false
    enable_private_nodes = true
    master_ipv4_cidr_block = "172.16.0.0/28"
  }
  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }
  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS"]
  }  
  node_config {
    machine_type = "e2-medium"
    disk_size_gb = 100
    disk_type    = "pd-standard"
    image_type   = "COS_CONTAINERD"
    oauth_scopes    = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/trace.append"
    ]
    metadata = {
      disable-legacy-endpoints = "true"
    }      
  } 
}

resource "google_container_node_pool" "aaa" {
  name       = "aaa"
  project    = "project"
  location   = google_container_cluster.cluster.location
  cluster    = google_container_cluster.cluster.name
  node_count = 6
  node_locations = [
    google_container_cluster.cluster.location
  ]
  node_config {
    machine_type = "n2-standard-8"
    disk_size_gb = 100
    disk_type    = "pd-standard"
    image_type   = "COS_CONTAINERD"
    oauth_scopes    = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/trace.append"
    ]
  }
  management {
    auto_repair  = true
    auto_upgrade = false
  }
  upgrade_settings {
    max_surge       = 1
    max_unavailable = 0
  }
}