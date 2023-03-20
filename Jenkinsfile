pipeline {
    agent any
    environment {
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_DEFAULT_REGION = "eu-west-2"
    }
    stages {
        stage("Create nginx-conroller") {
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

        stage("Create prometheus") {
            steps {
                script {
                    dir('prometheus') {
                        sh "terraform init"
                        sh "terraform apply -auto-approve"
                    }
                }
            }
        }

        stage("Deploy voting-app to EKS") {
            steps {
                script {
                    dir('voting-app') {
                        sh "kubectl apply -f voting.yaml"
                    }
                }
            }
        }

        stage("Deploy sock-shop to EKS") {
            steps {
                script {
                    dir('microservices') {
                        sh "kubectl apply -f complete-deployment.yaml"
                    }
                }
            }
        }

        stage("Deploy ingress-rule to EKS") {
            steps {
                script {
                    dir('ingress-rule') {
                        sh "terraform init"
                        sh "terraform apply -auto-approve"
                    }
                }
            }
        }
    }
}
