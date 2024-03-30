pipeline {
    environment {
        dockerimagename = 'taskmanagerapp'
        dockerimage = ''
    }
    agent any

    tools {
        git 'Default'
    }

    stages {
        stage('Code Source') {
            steps {
                // Pull code from the Task-Manager repository
                checkout([$class: 'GitSCM', branches: [[name: '*/main']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[url: 'https://github.com/Tonny-Kioko/Task-Manager.git']]])
            }
        }

        stage('Image Build') {
            steps {
                script {
                    // Install docker-compose
                    sh 'pip3 install docker-compose'

                    // Use docker-compose to build images
                    dockerimage = sh(script: "docker-compose -f docker-compose.yml --build ${dockerimagename}", returnStdout: true).trim()
                    sh 'docker-compose up -d'
                }
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
