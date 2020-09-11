# Deploy, Scale, and Update Your Website on Google Kubernetes Engine 
# https://www.qwiklabs.com/focuses/10470?parent=catalog

# Create a GKE cluster
gcloud config set compute/zone us-central1-f
gcloud container clusters create fancy-cluster --num-nodes 3
gcloud compute instances list

# Clone source repository
cd ~
git clone https://github.com/googlecodelabs/monolith-to-microservices.git
cd ~/monolith-to-microservices
./setup.sh
cd ~/monolith-to-microservices/monolith
npm start

# Create Docker container with Cloud Build
gcloud services enable cloudbuild.googleapis.com
cd ~/monolith-to-microservices/monolith
gcloud builds submit --tag gcr.io/${GOOGLE_CLOUD_PROJECT}/monolith:1.0.0 .

# Deploy container to GKE
kubectl create deployment monolith --image=gcr.io/${GOOGLE_CLOUD_PROJECT}/monolith:1.0.0

# Expose GKE Deployment
kubectl expose deployment monolith --type=LoadBalancer --port 80 --target-port 8080
kubectl get service

# Scale GKE deployment
kubectl scale deployment monolith --replicas=3
kubectl get all

# Make changes to the website
cd ~/monolith-to-microservices/react-app/src/pages/Home
mv index.js.new index.js
cat ~/monolith-to-microservices/react-app/src/pages/Home/index.js
cd ~/monolith-to-microservices/react-app
npm run build:monolith
cd ~/monolith-to-microservices/monolith
gcloud builds submit --tag gcr.io/${GOOGLE_CLOUD_PROJECT}/monolith:2.0.0 .

# Update website with zero downtime
kubectl set image deployment/monolith monolith=gcr.io/${GOOGLE_CLOUD_PROJECT}/monolith:2.0.0
kubectl get pods