pipeline {
  agent any

  environment {
    DOCKER_IMAGE = "trend-app"
    AWS_REGION   = "ap-south-1"
    EKS_CLUSTER  = "trend-eks"
    KUBECONFIG = '/var/lib/jenkins/.kube/config'
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
            env.IMAGE_TAG = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
        }
        sh '''
            docker build -f Dockerfile -t $DOCKER_IMAGE:$IMAGE_TAG -t $DOCKER_IMAGE:latest .
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

    stages {
    stage('Deploy to EKS') {
        steps {
            sh '''
                aws eks update-kubeconfig --region ap-south-1 --name trend-eks
                kubectl get nodes
                kubectl apply -f k8s/deployment.yaml
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
