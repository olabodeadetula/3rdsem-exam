pipeline {
    agent any
    environment {
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_DEFAULT_REGION = "eu-west-2"
    }
    parameters{
        choice(name: 'ENVIRONMENT', choices: ['create', 'destroy'], description: 'create and destroy cluster with one click')
    }
    stages {
     
        stage("Create PROMETHEUS") {
             when {
                expression { params.ENVIRONMENT == 'create' }
            }
            steps {
                script {
                    dir('prometheus') {
                        sh "aws eks --region eu-west-2 update-kubeconfig --name exam"
                        sh "terraform init"
                        sh "terraform apply -auto-approve"
                    }
                }
            }
        }

        stage("Deploy voting-app to EKS") {
             when {
                expression { params.ENVIRONMENT == 'create' }
            }
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
             when {
                expression { params.ENVIRONMENT == 'create' }
            }
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
             when {
                expression { params.ENVIRONMENT == 'create' }
            }
            steps {
                script {
                    dir('kubernetes/ingress-rule') {
                        sh "terraform init"
                        sh "terraform apply -auto-approve"
                    }
                }
            }
        }


        stage("Create NGINX-Controller") {
             when {
                expression { params.ENVIRONMENT == 'create' }
            }
            steps {
                script {
                    dir('nginx-controller') {
                        sh "terraform init"
                        sh "terraform apply -auto-approve"
                    }
                }
            }
        }



         stage("Destroy PROMETHEUS") {
             when {
                expression { params.ENVIRONMENT == 'destroy' }
            }
            steps {
                script {
                    dir('prometheus') {
                        sh "terraform destroy -auto-approve"
                    }
                }
            }
        }

        stage("Destroy voting-app in EKS") {
             when {
                expression { params.ENVIRONMENT == 'destroy' }
            }
            steps {
                script {
                    dir('kubernetes/voting-app') {
                        sh "terraform destroy -auto-approve"
                    }
                }
            }
        }

        stage("Destroy sock-shop in EKS") {
             when {
                expression { params.ENVIRONMENT == 'destroy' }
            }
            steps {
                script {
                    dir('kubernetes/microservices') {
                        sh "terraform destroy -auto-approve"
                    }
                }
            }
        }

        stage("Destroy ingress rule in EKS") {
             when {
                expression { params.ENVIRONMENT == 'destroy' }
            }
            steps {
                script {
                    dir('kubernetes/ingress-rule') {
                        sh "terraform destroy -auto-approve"
                    }
                }
            }
        }
        
         stage("destroy NGINX-conroller") {
             when {
                expression { params.ENVIRONMENT == 'destroy' }
            }
            steps {
                script {
                    dir('nginx-controller') {
                         sh "terraform destroy -auto-approve"
                    }
                }
            }
        }

    }
}
