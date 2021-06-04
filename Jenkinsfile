pipeline {
    agent {
        label 'monaco-runner'
    }
    environment {
        DT_URL="${env.DT_TENANT}"
        CLUSTERNAME="${env.CLUSTERNAME}"
    }
    stages {
         stage('Checkout') {
                steps {
                checkout([$class: 'GitSCM',
                          branches: [[name: 'master']],
                          extensions: [],
                          userRemoteConfigs: [[url: 'https://github.com/dynatrace-perfclinics/prometheus-k8s-pipeline']]])

                }
         }
         stage('Deploy Prometeus annotations') {
            steps {
                container('monaco') {
                    withKubeCredentials([[credentialsId: 'kubeconfig']) {
                        sh "sed -i s/CLUSTERNAME_TOREPLACE/${CLUSTERNAME}/ jenkins/service_jenkins.yaml"
                        sh "echo Deploying service to collect Jenkins Prometeus Metrics"
                        sh "cat jenkins/service_jenkins.yaml"
                        sh "kubectl get pods"
                        sh "kubectl apply -f jenkins/service_jenkins.yaml"
                    }
                }
            }
         }
         stage('Configure dynatrace with Monaco') {
                    steps {
                        container('monaco') {
                            withCredentials([string(credentialsId: 'DT_TOKEN', variable: 'TOKEN')]) {
                                sh "sed -i s,DT_URL_TO_REPLACE,${DT_URL}, monaco/k8sMonitoring/environment.yaml"
                                sh "sed -i s/DT_API_TOKEN/${TOKEN}/ monaco/k8sMonitoring/environment.yaml"
                                sh "echo Deploying service to collect Jenkins Prometeus Metrics"
                                sh "monaco deploy -e monaco/k8sMonitoring/environment.yaml --project  monaco/k8sMonitoring -v"
                             }
                        }
                    }
         }
    }
}