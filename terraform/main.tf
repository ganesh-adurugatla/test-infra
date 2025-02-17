provider "google" {
  project = var.project_id
  region  = var.region
}

provider "kubernetes" {
  config_path = "~/.kube/config"  # Make sure you have cluster credentials
}

resource "kubernetes_deployment" "flask_app" {
  metadata {
    name = "flask-app"
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
}
