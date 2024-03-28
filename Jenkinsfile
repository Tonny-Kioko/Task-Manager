pipeline {
    agent any

    stages {
        stage('Code Source') {
            steps {
                // Pull code from the Task-Manager repository
                git 'https://github.com/Tonny-Kioko/Task-Manager.git'
            }
        }

        stage('Image Build') {
            steps {
                // Use docker-compose to build images
                sh 'docker-compose -f docker-compose.yml build'
            }
        }

        stage('Task-Manager Deployment') {
            steps {
                // Pull images and deploy using kubectl
                sh 'kubectl apply -f web-deployment.yml'
                sh 'kubectl apply -f postgres-deployment.yml'
                sh 'kubectl apply -f postgres-configmap.yml'
                sh 'kubectl apply -f postgres-secrets.yml'
            }
        }
    }
}
