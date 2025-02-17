# main.tf
provider "google" {
  project = var.project_id
  region  = var.region
}

data "google_client_config" "current" {}

data "google_container_cluster" "my_cluster" {
  name     = "autopilot-cluster-1-test"
  location = var.region
}

provider "kubernetes" {
  host  = "https://${data.google_container_cluster.my_cluster.endpoint}"
  token = data.google_client_config.current.access_token
  cluster_ca_certificate = base64decode(
    data.google_container_cluster.my_cluster.master_auth[0].cluster_ca_certificate
  )
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
      }
    }
  }
}
