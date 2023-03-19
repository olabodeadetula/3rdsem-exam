resource "kubernetes_deployment" "kube-voting-deployment" {
  metadata {
    name      = "voting-app-deployment"
    namespace =  kubernetes_namespace.kube-namespace.id
    labels = {
      name = "exam-voting-app"
    }
  }
  spec {
    replicas = 3
    selector {
      match_labels = {
        name = "voting-app-pod"
        app = "exam-voting-app"
      }
    }
    template {
      metadata {
        name =  "voting-app-pod"
        labels = {
          name = "voting-app-pod"
          app = "exam-voting-app"
        }
      }
      spec {
        container {
          image = "mcr.microsoft.com/azuredocs/azure-vote-front:v1"
          name  = "voting-app"
      port {
        container_port = 80
      }
      }
    }
  }
}
}
# Create kubernetes  for cart service
resource "kubernetes_service" "kube-voting-service" {
  metadata {
    name      = "voting-app-service"
    namespace =  kubernetes_namespace.kube-namespace.id
    labels = {
        name = "voting-app-service"
        app = "exam-voting-app"
    }
  }
  spec {
    selector = {
      name = "voting-app-pod"
      app = "exam-voting-app"
    }
    port {
      port        = 80
      target_port = 80
    }
  }
}
# New
resource "kubernetes_deployment" "kube-voting-backend-deployment" {
  metadata {
    name      = "voting-backend-deployment"
    namespace =  kubernetes_namespace.kube-namespace.id
    labels = {
      name = "exam-voting-app"
    }
  }
  spec {
    replicas = 3
    selector {
      match_labels = {
        name = "voting-app-pod"
        app = "exam-voting-app"
      }
    }
    template {
      metadata {
        name =  "voting-app-pod"
        labels = {
          name = "voting-app-pod"
          app = "exam-voting-app"
        }
      }
      spec {
        container {
          image = "mcr.microsoft.com/azuredocs/azure-vote-front:v1"
          name  = "backend-voting-app"
      port {
        container_port = 80
      }
      }
    }
  }
}
}
# Create kubernetes  for cart service
resource "kubernetes_service" "kube-voting-app-service" {
  metadata {
    name      = "voting-service"
    namespace =  kubernetes_namespace.kube-namespace.id
   /*  annotations = {
        prometheus.io/scrape: "true"
    } */
    labels = {
        name = "voting-service"
        app = "exam-voting-app"
    }
  }
  spec {
    selector = {
      name = "voting-app-pod"
      app = "exam-voting-app"
    }
    port {
      port        = 80
      target_port = 80
    }
  }
}
