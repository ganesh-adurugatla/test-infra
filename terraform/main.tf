# terraform/main.tf
provider "google" {
  project = var.project_id
  region  = var.region
}

# Get GKE cluster info
data "google_container_cluster" "my_cluster" {
  name     = "autopilot-cluster-1-test"  # This should be your actual GKE cluster name
  location = var.region
}

# Configure Kubernetes provider with GKE authentication
provider "kubernetes" {
  host                   = "https://${data.google_container_cluster.my_cluster.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(data.google_container_cluster.my_cluster.master_auth[0].cluster_ca_certificate)
}

data "google_client_config" "default" {}

resource "kubernetes_deployment" "flask_app" {
  metadata {
    name      = "flask-app"
    namespace = "default"
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "flask-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "flask-app"
        }
      }

      spec {
        container {
          name  = "flask-app"
          image = var.app_image

          port {
            container_port = 8080
            protocol      = "TCP"
          }

          resources {
            limits = {
              "ephemeral-storage" = "1Gi"
            }
            requests = {
              cpu               = "500m"
              memory           = "2Gi"
              ephemeral-storage = "1Gi"
            }
          }

          security_context {
            capabilities {
              drop = ["NET_RAW"]
            }
          }
        }

        security_context {
          seccomp_profile {
            type = "RuntimeDefault"
          }
        }

        toleration {
          key      = "kubernetes.io/arch"
          operator = "Equal"
          value    = "amd64"
          effect   = "NoSchedule"
        }
      }
    }

    strategy {
      type = "RollingUpdate"
      rolling_update {
        max_surge       = "25%"
        max_unavailable = "25%"
      }
    }
  }

  lifecycle {
    ignore_changes = [
      # Ignore changes to these annotations as they are managed by GKE
      metadata[0].annotations["autopilot.gke.io/resource-adjustment"],
      metadata[0].annotations["autopilot.gke.io/warden-version"]
    ]
  }
}

# Service to expose the application
resource "kubernetes_service" "flask_app" {
  metadata {
    name      = "flask-app"
    namespace = "default"
  }

  spec {
    selector = {
      app = kubernetes_deployment.flask_app.spec[0].template[0].metadata[0].labels.app
    }

    port {
      port        = 80
      target_port = 8080
    }

    type = "LoadBalancer"
  }
}
