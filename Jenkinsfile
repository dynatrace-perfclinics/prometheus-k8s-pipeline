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
                agent { label 'monaco-runner' }
                steps {

                    git  url:"https://github.com/dynatrace-perfclinics/prometheus-k8s-pipeline.git",
                        branch :'master'
                }
            }
        stage('Deploy Prometeus annotations') {
            steps {
                container('kubectl') {
                    script{
                        sed -i "s/CLUSTERNAME_TOREPLACE/${CLUSTERNAME}/" jenkins/service_jenkins.yaml
                        echo "Deploying service to collect Jenkins Prometeus Metrics"
                        kubectl apply -f jenkins/service_jenkins.yaml
                    }
                }
            }
        }
         stage('Configure dynatrace with Monaco') {
                    steps {
                        container('monaco') {
                            withCredentials([string(credentialsId: 'DT_TOKEN', variable: 'TOKEN')]) {
                                sed -i "s,DT_URL_TO_REPLACE,${DT_URL}/" monaco/k8sMonitoring/environment.yaml
                                sed -i "s/DT_API_TOKEN/${TOKEN}/" monaco/k8sMonitoring/environment.yaml
                                echo "Deploying service to collect Jenkins Prometeus Metrics"
                                monaco deploy -e monaco/k8sMonitoring/environment.yaml --project  monaco/k8sMonitoring -v
                            }
                        }
                    }
                }
    }
}