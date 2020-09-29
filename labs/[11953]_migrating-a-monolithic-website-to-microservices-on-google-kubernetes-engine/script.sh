# Migrating a Monolithic Website to Microservices on Google Kubernetes Engine 
# https://www.qwiklabs.com/focuses/11953?parent=catalog

# Environment Setup
gcloud config set compute/zone us-central1-f

# Clone Source Repository
cd ~
git clone https://github.com/googlecodelabs/monolith-to-microservices.git
cd ~/monolith-to-microservices
./setup.sh

# Create a GKE Cluster
gcloud services enable container.googleapis.com
gcloud container clusters create fancy-cluster --num-nodes 3
gcloud compute instances list

# Deploy Existing Monolith
cd ~/monolith-to-microservices
./deploy-monolith.sh
kubectl get service monolith

# Migrate Orders to a microservice
## Create new orders microservice
cd ~/monolith-to-microservices/microservices/src/orders
gcloud builds submit --tag gcr.io/${GOOGLE_CLOUD_PROJECT}/orders:1.0.0 .
kubectl create deployment orders --image=gcr.io/${GOOGLE_CLOUD_PROJECT}/orders:1.0.0
kubectl get all
kubectl expose deployment orders --type=LoadBalancer --port 80 --target-port 8081
kubectl get service orders
# Reconfigure Monolith
cd ~/monolith-to-microservices/react-app
nano .env.monolith
npm run build:monolith
cd ~/monolith-to-microservices/monolith
gcloud builds submit --tag gcr.io/${GOOGLE_CLOUD_PROJECT}/monolith:2.0.0 .
kubectl set image deployment/monolith monolith=gcr.io/${GOOGLE_CLOUD_PROJECT}/monolith:2.0.0

# Migrate Products to Microservice
## Create new Products microservice
cd ~/monolith-to-microservices/microservices/src/products
gcloud builds submit --tag gcr.io/${GOOGLE_CLOUD_PROJECT}/products:1.0.0 .
kubectl create deployment products --image=gcr.io/${GOOGLE_CLOUD_PROJECT}/products:1.0.0
kubectl expose deployment products --type=LoadBalancer --port 80 --target-port 8082
kubectl get service products
## Reconfigure Monolith
cd ~/monolith-to-microservices/react-app
nano .env.monolith
npm run build:monolith
cd ~/monolith-to-microservices/monolith
gcloud builds submit --tag gcr.io/${GOOGLE_CLOUD_PROJECT}/monolith:3.0.0 .
kubectl set image deployment/monolith monolith=gcr.io/${GOOGLE_CLOUD_PROJECT}/monolith:3.0.0

# Migrate frontend to microservice
## Create New Frontend Microservice
cd ~/monolith-to-microservices/react-app
cp .env.monolith .env
npm run build
cd ~/monolith-to-microservices/microservices/src/frontend
gcloud builds submit --tag gcr.io/${GOOGLE_CLOUD_PROJECT}/frontend:1.0.0 .
kubectl create deployment frontend --image=gcr.io/${GOOGLE_CLOUD_PROJECT}/frontend:1.0.0
kubectl expose deployment frontend --type=LoadBalancer --port 80 --target-port 8080
## Delete The Monolith
kubectl delete deployment monolith
kubectl delete service monolith
## Test Your Work
kubectl get services