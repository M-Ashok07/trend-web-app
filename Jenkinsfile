pipeline {
    agent any

    environment {
        APP_NAME = "trend-app"
        DOCKER_IMAGE = "ashok948/${APP_NAME}"
        AWS_REGION = "ap-south-1"
        EKS_CLUSTER = "trend-eks"
    }

    stages {

        stage('Checkout SCM') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/M-Ashok07/trend-web-app.git',
                    credentialsId: 'github-creds'
            }
        }

        stage('Set Image Tag') {
            steps {
                script {
                    env.IMAGE_TAG = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
                    echo "IMAGE_TAG = ${env.IMAGE_TAG}"
                }
            }
        }

        stage('Docker Login') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', 
                                                 usernameVariable: 'USERNAME', 
                                                 passwordVariable: 'PASSWORD')]) {
                    sh 'echo $PASSWORD | docker login -u $USERNAME --password-stdin'
                }
            }
        }

        stage('Build Image') {
            steps {
                sh """
                    docker build -t ${DOCKER_IMAGE}:${IMAGE_TAG} .
                    docker tag ${DOCKER_IMAGE}:${IMAGE_TAG} ${DOCKER_IMAGE}:latest
                """
            }
        }

        stage('Push Image') {
            steps {
                sh """
                    docker push ${DOCKER_IMAGE}:${IMAGE_TAG}
                    docker push ${DOCKER_IMAGE}:latest
                """
            }
        }

        stage('Deploy to EKS') {
    steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-login']]) {
            sh """
                aws eks update-kubeconfig --region ${AWS_REGION} --name ${EKS_CLUSTER} --alias ${EKS_CLUSTER}
                export KUBECONFIG=$HOME/.kube/config
                kubectl get nodes
                kubectl apply -f k8s/deployment.yaml --validate=false
                kubectl apply -f k8s/service.yaml --validate=false
            """
        }
    }
}

    post {
        always {
            cleanWs()
        }
    }
}
