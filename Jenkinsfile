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
                    // Use docker build to build the image
                    dockerimage = sh(script: "docker build -t ${dockerimagename} .", returnStdout: true).trim()
                    sh 'docker run -d -p 8000:8000 ${dockerimagename}'
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
