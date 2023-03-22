pipeline {
    agent any
    environment {
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_DEFAULT_REGION = "eu-west-2"
    }
    stages {
        stage("Create NGINX-Controller") {
            steps {
                script {
                    dir('nginx-controller') {
                       sh "aws eks --region eu-west-2 update-kubeconfig --name exam"
                        sh "terraform init"
                        sh "terraform apply -auto-approve"
                    }
                }
            }
        }

        stage("Create Prometheus") {
            steps {
                script {
                    dir('kubernetes/prometheus') {
                        sh "terraform init"
                        sh "terraform apply -auto-approve"
                    }
                }
            }
        }

        stage("Deploy voting-app to EKS") {
            steps {
                script {
                    dir('kubernetes/voting-app') {
                        sh "terraform init"
                        sh "terraform apply -auto-approve"
                    }
                }
            }
        }

        stage("Deploy sock-shop to EKS") {
            steps {
                script {
                    dir('kubernetes/microservices') {
                        sh "terraform init"
                        sh "terraform apply -auto-approve"
                    }
                }
            }
        }

        stage("Deploy ingress-rule to EKS") {
            steps {
                script {
                    dir('kubernetes/ingress-rule') {
                        sh "terraform init"
                        sh "terraform apply -auto-approve"
                    }
                }
            }
        }
    }
}
