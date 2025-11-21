pipeline {
    agent any

    tools {
        jdk 'jdk21'
        maven 'maven3'
    }

    environment {
        SCANNER_HOME= tool 'sonar-scanner'
    }

    stages {
        stage('Git Checkout') {
            steps {
                git branch: 'main', credentialsId: 'git-cred', url: 
                'file:///home/jenkins-user/coffeequeue-devops'
            }
        }

        stage('Compile') {
            steps {
                sh "cd coffeequeue && mvn compile"
            }
        }

        stage('Test') {
            steps {
                sh "cd coffeequeue && mvn test"
            }
        }

        stage('File System Scan') {
            steps {
                sh "trivy fs --format table --output trivy-fs-report.html ."
            }
        }  
        
        stage('SonarQube Analsyis') {
            steps {
                withSonarQubeEnv('sonar') {
                    sh ''' $SCANNER_HOME/bin/sonar-scanner \
                    -Dsonar.projectName=CoffeeQueue \
                    -Dsonar.projectKey=CoffeeQueue \
                    -Dsonar.java.binaries=. '''
                }
            }
        }

        stage('Quality Gate') {
            steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'sonar-token'
                }
            }
        }

        stage('Build') {
            steps {
                sh "cd coffeequeue && mvn package"
            }
        }

        stage('Build & Tag Docker Image') {
            steps {
                script {
sh script: """#!/bin/bash
set +x
cat <<EOT >> application.properties
spring.application.name=coffee-queuee
server.port=8080

spring.datasource.url=${DB_URL}
spring.datasource.username=${DB_USERNAME}
spring.datasource.password=${DB_PASSWORD}
spring.datasource.driver-class-name=org.postgresql.Driver

spring.jpa.hibernate.ddl-auto=none
spring.jpa.show-sql=false
spring.jpa.properties.hibernate.format_sql=true
spring.jpa.properties.hibernate.jdbc.lob.non_contextual_creation=true

# Naming strategy (optional, keeps entity field names as-is)
spring.jpa.hibernate.naming.physical-strategy=org.hibernate.boot.model.naming.PhysicalNamingStrategyStandardImpl

logging.level.org.hibernate.SQL=INFO
logging.level.org.hibernate.type.descriptor.sql=INFO
logging.level.com.example.coffeequeue=DEBUG
EOT"""
                }
                withDockerRegistry(credentialsId: 'nexus-cred', url: 'http://10.10.2.119:8081') {
                    sh "docker build -t 10.10.2.119:8081/stratalyze/coffeequeue:latest ."
                }
            } 
        }

        stage('Docker Image Scan') {
            steps {
                sh "trivy image --format table --output trivy-image-report.html \
                10.10.2.119:8081/stratalyze/coffeequeue:latest"
            }
        }
        
        stage('Push Docker Image') {
            steps {
                withDockerRegistry(credentialsId: 'nexus-cred', url: 'http://10.10.2.119:8081') {
                    sh "docker push 10.10.2.119:8081/stratalyze/coffeequeue:latest"
                }
            }
        }

        stage('Deploy To Kubernetes') {
            steps {
                withKubeConfig(caCertificate: '', clusterName: 'kind-coffeequeue', 
                contextName: 'kind-coffeequeue', credentialsId: 'kubeconfig', 
                namespace: 'default', restrictKubeConfigAccess: false, 
                serverUrl: 'https://127.0.0.1:35937') {
                        sh "kubectl version"
                        sh "kubectl apply -f k8s"
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                withKubeConfig(caCertificate: '', clusterName: 'kind-coffeequeue', 
                contextName: 'kind-coffeequeue', credentialsId: 'kubeconfig', 
                namespace: 'default', restrictKubeConfigAccess: false, 
                serverUrl: 'https://127.0.0.1:35937') {
                        sh "kubectl get pods"
                        sh "kubectl get service"
                }
            }
        }        
    }

    post {
        always {
            script {
                def jobName = env.JOB_NAME
                def buildNumber = env.BUILD_NUMBER
                def pipelineStatus = currentBuild.result ?: 'UNKNOWN'
                def bannerColor = pipelineStatus.toUpperCase() == 'SUCCESS' ? 'GREEN' : 'RED'
                def body = """
                    <html>
                    <body>
                        <div style="border: 4px solid ${bannerColor}; padding: 10px;">
                            <h2>
                                ${jobName} - Build #${buildNumber}
                            </h2>
                            <div style="background-color: ${bannerColor}; padding: 10px;">
                                <h3 style="color: white;">
                                    Pipeline Status: ${pipelineStatus.toUpperCase()}
                                </h3>
                            </div>
                            <p>
                                Check the <a href="${BUILD_URL}">console output</a>.
                            </p>
                        </div>    
                    </body>
                    </html>
                """

                emailext(
                    subject: "${jobName} - Build #${buildNumber} - ${pipelineStatus.toUpperCase()}",
                    body: body,
                    to: 'ahmedbellok24@gmail.com',
                    from: 'jenkins@gmail.com',
                    replyTo: 'jenkins@gmail.com',
                    mimeType: 'text/html',
                    attachmentsPattern: 'trivy-image-report.html'
                )
                cleanWs()
            }
        }
        // success {
        //     // Actions on successful completion
        //     echo 'Pipeline successfully completed!'
        // }
        // failure {
        //     // Actions on failure
        //     script {
        //         // Example of sending a notification
        //         // slackSend channel: '#build-failures', message: "Build failed: ${env.JOB_NAME} ${env.BUILD_NUMBER}"
        //     }
        // }
    }
}