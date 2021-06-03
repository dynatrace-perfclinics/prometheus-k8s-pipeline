#bash/bin
kubectl create namespace jenkins
helm repo add jenkinsci https://charts.jenkins.io
helm repo add nginx-stable https://helm.nginx.com/stable
helm repo update

#--create the storageClass
kubectl apply manifest/storageClass.yaml
#--Create the persistentVolume
kubectl apply manifest/jenkins-volume.yaml
#--create serviceAccount
kubectl apply manifest/jenkins-sa.yaml

#--deploy jenkins with helm
chart=jenkinsci/jenkins
helm install jenkins -n jenkins -f jenkins-values.yaml $chart

#deploy NGNIX controller and service
helm install nginx-ingress nginx-stable/nginx-ingress
export NGINX_INGRESS_IP=$(kubectl get service nginx-ingress-nginx-ingress -ojson | jq -r '.status.loadBalancer.ingress[].ip')
echo $NGINX_INGRESS_IP
kubectl apply -f manifest/ingress.yaml

#--print default jenkins password
JENKINSPASS=$(kubectl exec --namespace jenkins -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/chart-admin-password)
echo "url for jenkins http://${NGINX_INGRESS_IP}.nip.io"
echo "defualt user : admin"
echo "password : ${JENKINSPASS}"

