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
                    git  url:"https://github.com/dynatrace-perfclinics/prometheus-k8s-pipeline.git",
                        branch :'master'
                }
         }
         stage('Deploy Prometeus annotations') {
            steps {
                container('kubectl') {
                    script {
                        sh "sed -i s/CLUSTERNAME_TOREPLACE/${CLUSTERNAME}/ jenkins/service_jenkins.yaml"
                        sh "echo Deploying service to collect Jenkins Prometeus Metrics"
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
                                sh "monaco deploy -e monaco/k8sMonitoring/environment.yaml --project  monaco/k8sMonitoring -v

                             }
                        }
                    }
         }
    }
}