pipeline {
    agent any

    environment {
        DOCKERHUB_USER = 'sakthi312'         // DockerHub username
        IMAGE_NAME = 'trend-app'              // DockerHub repo name
        CLUSTER_NAME = 'trend-cluster'        // EKS cluster name
        REGION = 'ap-south-1'                 // AWS region
    }

    stages {
        stage('Checkout Code') {
            steps {
                // ✅ Use Jenkins Git credentials for GitHub
                git branch: 'main', url: 'https://github.com/Sakthi-312/Trend.git', credentialsId: 'github-token'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                echo "🚧 Building Docker image..."
                docker build -t $DOCKERHUB_USER/$IMAGE_NAME:latest .
                '''
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                    sh '''
                    echo "🔐 Logging in to DockerHub..."
                    echo "$PASSWORD" | docker login -u "$USERNAME" --password-stdin
                    docker push $DOCKERHUB_USER/$IMAGE_NAME:latest
                    '''
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                sh '''
                echo "🚀 Deploying to EKS..."
                aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME
                kubectl apply -f deployment.yaml
                kubectl apply -f service.yaml
                kubectl get svc
                '''
            }
        }
    }

    post {
        success {
            echo "✅ Deployment completed successfully!"
        }
        failure {
            echo "❌ Pipeline failed! Check logs for details."
        }
    }
}
