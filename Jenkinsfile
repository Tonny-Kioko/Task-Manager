pipeline {
    agent any

    stages {
        stage('Source Code') {
            steps{
                // In this stage, we will pull the repository
                git 'https://github.com/Tonny-Kioko/Task-Manager.git'
            }
        }
    }
    

    stage('Building Images') {
        steps {
            // In this stage, we will build multiple images required using docker-compose
            sh 'docker-compose -f docker-compose.yml build'
        }
    }


    stage('Task-Manager Deployment') {
        steps{
            // In this stage, we will pull created images and deploy them using kubectl
            sh 'kubectl apply -f postgres-secrets.yml'
            sh 'kubectl apply -f postgres-configmap.yml'
            sh 'kubectl apply -f web-deployment.yml'
            sh 'kubectl apply -f postgres-deployment.yml'           
            
        }
    }
}