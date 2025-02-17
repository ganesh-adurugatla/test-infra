# terraform/outputs.tf

output "deployment_status" {
  description = "Status of the flask app deployment"
  value = {
    name              = kubernetes_deployment.flask_app.metadata[0].name
    namespace         = kubernetes_deployment.flask_app.metadata[0].namespace
    current_image     = kubernetes_deployment.flask_app.spec[0].template[0].spec[0].container[0].image
    desired_replicas  = kubernetes_deployment.flask_app.spec[0].replicas
  }
}

output "image_version" {
  description = "Current container image being used"
  value       = var.app_image
}
