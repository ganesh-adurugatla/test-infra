output "deployment_status" {
  description = "Deployment Status"
  value = {
    name             = kubernetes_deployment.flask_app.metadata[0].name
    generation       = kubernetes_deployment.flask_app.metadata[0].generation
    replicas         = kubernetes_deployment.flask_app.spec[0].replicas
    current_image    = kubernetes_deployment.flask_app.spec[0].template[0].spec[0].container[0].image
  }
}
