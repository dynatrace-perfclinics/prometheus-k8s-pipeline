# Prometheus-k8s-Performance Clinic
Repository containing the files for the Performance Clinic related to Prometheus on K8s 


This repository showcase the usage of the Prometheus OpenMetrics Ingest by using GKE with :
- the HipsterShop
- the dynatrace sockshop
- Jenkins

## Prerequisite 
The following tools need to be install on your machine :
- jq
- kubectl
- git
- gcloud ( if you are using GKE)
- Helm
### 1.Create a Google Cloud Platform Project
```
PROJECT_ID="<your-project-id>"
gcloud services enable container.googleapis.com --project ${PROJECT_ID}
gcloud services enable monitoring.googleapis.com \
cloudtrace.googleapis.com \
clouddebugger.googleapis.com \
cloudprofiler.googleapis.com \
--project ${PROJECT_ID}
```
### 2.Create a GKE cluster
```
ZONE=us-central1-b
gcloud container clusters create onlineboutique \
--project=${PROJECT_ID} --zone=${ZONE} \
--machine-type=e2-standard-2 --num-nodes=4
```
### 3.Clone Github repo
```
git clone https://github.com/dynatrace-perfclinics/prometheus-k8s-pipeline
cd prometheus-k8s-pipeline
```
### Deploy the sample Application
#### 1.HipsterShop
```
cd hipstershop
./setup.sh
```
#### 2.Sockshop
```
cd ../sockshop
kubectl create -f ../manifests/k8s-namespaces.yml

kubectl -n sockshop-production create rolebinding default-view --clusterrole=view --serviceaccount=sockshop-production:default
kubectl -n sockshop-dev create rolebinding default-view --clusterrole=view --serviceaccount=sockshop-dev:default

kubectl apply -f ../manifests/backend-services/user-db/sockshop-dev/
kubectl apply -f ../manifests/backend-services/user-db/sockshop-production/

kubectl apply -f ../manifests/backend-services/shipping-rabbitmq/sockshop-dev/
kubectl apply -f ../manifests/backend-services/shipping-rabbitmq/sockshop-production/

kubectl apply -f ../manifests/backend-services/carts-db/

kubectl apply -f ../manifests/backend-services/catalogue-db/

kubectl apply -f ../manifests/backend-services/orders-db/

kubectl apply -f ../manifests/sockshop-app/sockshop-dev/
kubectl apply -f ../manifests/sockshop-app/sockshop-production/
```
### Prometheus
```
helm install prometheus stable/prometheus-operator
```
### Jenkins
```
cd jenkins
./deployJenkins.sh