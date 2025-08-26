pipeline {
  agent any

  environment {
    DOCKER_IMAGE = "trend-app"
    AWS_REGION   = "ap-south-1"
    EKS_CLUSTER  = "trend-eks"
  }

  triggers { githubPush() }

  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Docker Login') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-creds',
                          usernameVariable: 'DOCKER_USER',
                          passwordVariable: 'DOCKER_PASS')]) {
          sh '''
            echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
          '''
        }
      }
    }

    stage('Build Image') {
      steps {
        script {
          def tag = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
          env.IMAGE_TAG = tag
        }
        sh '''
          docker build -t $DOCKER_IMAGE:$IMAGE_TAG -t $DOCKER_IMAGE:latest .
        '''
      }
    }

    stage('Push Image') {
      steps {
        sh '''
          docker push $DOCKER_IMAGE:$IMAGE_TAG
          docker push $DOCKER_IMAGE:latest
        '''
      }
    }

    stage('Set kubeconfig') {
      steps {
        sh '''
          aws eks update-kubeconfig --region $AWS_REGION --name $EKS_CLUSTER
          kubectl version --client
          kubectl get nodes
        '''
      }
    }

    stage('Deploy to EKS') {
      steps {
        // Patch image in deployment and apply manifests
        sh '''
          # Ensure manifests are present
          test -f k8s/deployment.yaml
          test -f k8s/service.yaml

          # Update the image to the new tag
          kubectl set image deployment/trend-frontend web=$DOCKER_IMAGE:$IMAGE_TAG --record || \
          kubectl apply -f k8s/deployment.yaml

          # Ensure service exists
          kubectl apply -f k8s/service.yaml

          kubectl rollout status deployment/trend-frontend
        '''
      }
    }
  }

  post {
    always {
      sh 'docker logout || true'
    }
  }
}
