pipeline{
    agent any
    tools{
        jdk 'jdk17'
        nodejs 'node'
    }
    environment {
        SCANNER_HOME = tool 'sonar-scanner'
    }
    stages {
        stage('Sonarqube Analysis'){
            steps {
                withSonarQubeEnv('sonar-server'){
                    sh '''
                       $SCANNER_HOME/bin/sonar-scanner \
                       -Dsonar.projectKey=om \
                       '''
                }
            }
        }
        stage('quality gate'){
            steps {
            script {
                waitForQualityGate abortPipeline: false
             }
            }
        }
        stage('Install Dependencies'){
            steps {
                sh "npm install"
            }
          }
          stage('OWASP FS SCAN'){
            steps {
                dependencyCheck additionalArguments: '--scan ./ --disableYarnAudit --disableNodeAudit', odcInstallation: 'DP-Check'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
          }
            stage('Docker Scout FS'){
            steps {
                script{
                    withDockerRegistry(credentialsId: 'docker') {
                        sh 'docker-scout quickview'
                        sh 'docker-scout cves'
                }
            }
          }
        }
        stage('Docker build & push'){
            steps {
                script{
                    withDockerRegistry(credentialsId: 'docker',) {
                        sh 'docker build -t hotstar .'
                        sh 'docker tag hotstar omghag18/hotstar:latest'
                        sh 'docker push omghag18/hotstar:latest'
                    }
                }
            }
        }
        stage('Docker scout image'){
            steps {
                script{
                    withDockerRegistry(credentialsId: 'docker',) {
                        sh 'docker-scout quickview omghag18/hotstar:latest'
                        sh 'docker-scout cves omghag18/hotstar:latest'
                        sh 'docker-scout recommendations omghag18/hotstar:latest'
                    }
                }
            }
        }
        stage('deploy docker'){
            steps{
                sh 'docker rm -f hotstar || true'
                sh 'docker run -d --name hotstar -p 3000:3000 omghag18/hotstar:latest'
            }
        }
        stage('Deploy to kubernets'){
            steps{
                script{
                    dir('K8s') {
                        withKubeConfig(caCertificate: '', clusterName: '', contextName: '', credentialsId: 'k8s', namespace: '', restrictKubeConfigAccess: false, serverUrl: '') {
                                sh 'kubectl apply -f deployment.yml'
                                sh 'kubectl apply -f service.yml'
                        }   
                    }
                }
            }
        }
    }
}
