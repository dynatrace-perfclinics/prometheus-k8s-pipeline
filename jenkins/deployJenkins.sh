#bash/bin
NAMESPACE="jenkins"
kubectl create namespace ${NAMESPACE}
helm repo add jenkinsci https://charts.jenkins.io
helm repo add nginx-stable https://helm.nginx.com/stable
helm repo update

#--create the storageClass
kubectl apply manifest/storageClass.yaml
#--Create the persistentVolume
kubectl apply manifest/jenkins-volume.yaml
#--create serviceAccount
kubectl apply manifest/jenkins-sa.yaml

# Get the service account token and CA cert.
SA_SECRET_NAME=$(kubectl get -n ${NAMESPACE} sa/jenkins -o "jsonpath={.secrets[0]..name}")
# Note: service account token is stored base64-encoded in the secret but must
# be plaintext in kubeconfig.
SA_TOKEN=$(kubectl get -n ${NAMESPACE} secrets/${SA_SECRET_NAME} -o "jsonpath={.data['token']}" | base64 ${BASE64_DECODE_FLAG})
CA_CERT=$(kubectl get -n ${NAMESPACE} secrets/${SA_SECRET_NAME} -o "jsonpath={.data['ca\.crt']}")

# Extract cluster IP from the current context
CURRENT_CONTEXT=$(kubectl config current-context)
CURRENT_CLUSTER=$(kubectl config view -o jsonpath="{.contexts[?(@.name == \"${CURRENT_CONTEXT}\"})].context.cluster}")
CURRENT_CLUSTER_ADDR=$(kubectl config view -o jsonpath="{.clusters[?(@.name == \"${CURRENT_CLUSTER}\"})].cluster.server}")

echo "Writing kubeconfig."
cat > kubeconfig <<EOF
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ${CA_CERT}
    server: ${CURRENT_CLUSTER_ADDR}
  name: ${CURRENT_CLUSTER}
contexts:
- context:
    cluster: ${CURRENT_CLUSTER}
    user: ${SA_NAME}
  name: ${CURRENT_CONTEXT}
current-context: ${CURRENT_CONTEXT}
kind: Config
preferences: {}
users:
- name: ${SA_NAME}
  user:
    token: ${SA_TOKEN}
EOF

cat kubeconfig
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

