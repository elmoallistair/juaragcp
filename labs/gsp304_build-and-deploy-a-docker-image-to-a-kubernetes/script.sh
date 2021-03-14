# Build and Deploy a Docker Image to a Kubernetes Cluster
# https://www.qwiklabs.com/focuses/1738?parent=catalog

# Task 1 : An application image with a v1 tag has been pushed to the gcr.io repository
mkdir echo-web && cd echo-web
gsutil cp -r gs://$DEVSHELL_PROJECT_ID/echo-web.tar.gz .
tar -xzf echo-web.tar.gz
rm echo-web.tar.gz
cd echo-web
docker build -t echo-app:v1 .
docker tag echo-app:v1 gcr.io/$DEVSHELL_PROJECT_ID/echo-app:v1
docker push gcr.io/$DEVSHELL_PROJECT_ID/echo-app:v1

# Task 2 : A new Kubernetes cluster exists (zone: us-central1-a)
gcloud config set compute/zone us-central1-a
gcloud container clusters create echo-cluster --num-nodes=2 --machine-type=n1-standard-2

# Task 3 : Check that an application has been deployed to the cluster
kubectl create deployment echo-web --image=gcr.io/$DEVSHELL_PROJECT_ID/echo-app:v1

# Task 4 : Test that a service exists that responds to requests like Echo-app
kubectl expose deployment echo-web --type=LoadBalancer --port 80 --target-port 8000
