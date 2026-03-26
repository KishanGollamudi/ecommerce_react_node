pipeline {
    agent any

    environment {
        AWS_REGION = "ap-south-1"
        AWS_ACCOUNT_ID = "YOUR_ACCOUNT_ID"

        BACKEND_REPO = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/smartcart-backend"
        FRONTEND_REPO = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/smartcart-frontend"
    }

    stages {

        stage('Checkout') {
            steps {
                git 'https://github.com/YOUR_USERNAME/YOUR_REPO.git'
            }
        }

        stage('Build Backend Image') {
            steps {
                sh 'docker build -t backend ./backend'
                sh 'docker tag backend:latest $BACKEND_REPO:latest'
            }
        }

        stage('Build Frontend Image') {
            steps {
                sh 'docker build -t frontend ./frontend'
                sh 'docker tag frontend:latest $FRONTEND_REPO:latest'
            }
        }

        stage('Login to ECR') {
            steps {
                sh '''
                aws ecr get-login-password --region $AWS_REGION \
                | docker login --username AWS --password-stdin \
                $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
                '''
            }
        }

        stage('Push to ECR') {
            steps {
                sh '''
                docker push $BACKEND_REPO:latest
                docker push $FRONTEND_REPO:latest
                '''
            }
        }
    }
}
