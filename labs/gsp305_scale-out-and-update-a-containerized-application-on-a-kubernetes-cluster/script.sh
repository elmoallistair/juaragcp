# Scale Out and Update a Containerized Application on a Kubernetes Cluster
# https://www.qwiklabs.com/focuses/1739?parent=catalog

# Task 1 : Check that there is a tagged image in gcr.io for echo-app:v2
mkdir echo-web && cd echo-web
gsutil cp -r gs://$DEVSHELL_PROJECT_ID/echo-web-v2.tar.gz .
tar -xzf echo-web-v2.tar.gz
rm echo-web-v2.tar.gz
docker build -t echo-app:v2 .
docker tag echo-app:v2 gcr.io/$DEVSHELL_PROJECT_ID/echo-app:v2
docker push gcr.io/$DEVSHELL_PROJECT_ID/echo-app:v2

# Task 2 : Echo-app:v2 is running on the Kubernetes cluster
gcloud container clusters get-credentials echo-cluster --zone=us-central1-a
kubectl create deployment echo-web --image=gcr.io/qwiklabs-resources/echo-app:v2

# Task 3 : The Kubernetes cluster deployment reports 2 replicas.
kubectl scale deployment echo-web --replicas=2

# Task 4 : The application must respond to web requests with V2.0.0
kubectl expose deployment echo-web --type=LoadBalancer --port 80 --target-port 8000
