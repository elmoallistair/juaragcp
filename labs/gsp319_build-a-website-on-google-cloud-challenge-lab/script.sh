# Build a Website on Google Cloud: Challenge Lab
# https://www.qwiklabs.com/focuses/11765?parent=catalog

# Setup
gcloud config set compute/zone us-central1-a

# Task 1: Download the monolith code and build your container
# Reference: Deploy Your Website on Cloud Run
git clone https://github.com/googlecodelabs/monolith-to-microservices.git
cd ~/monolith-to-microservices
./setup.sh

gcloud services enable container.googleapis.com
gcloud container clusters create fancy-cluster --num-nodes 3
gcloud compute instances list

cd ~/monolith-to-microservices
./deploy-monolith.sh
kubectl get service monolith

cd ~/monolith-to-microservices/monolith
gcloud builds submit --tag gcr.io/${GOOGLE_CLOUD_PROJECT}/fancytest:1.0.0 .

# Task 2: Create a kubernetes cluster and deploy the application
# Reference: Lab Deploy, Scale, and Update Your Website on Google Kubernetes Engine
kubectl create deployment fancytest --image=gcr.io/${GOOGLE_CLOUD_PROJECT}/fancytest:1.0.0
kubectl get all
kubectl expose deployment fancytest --type=LoadBalancer --port 80 --target-port 8080
kubectl get service fancytest

# Task 3: Create a containerized version of your Microservices
# Reference: Lab Migrating a Monolithic Website to Microservices on Google Kubernetes Engine
cd ~/monolith-to-microservices/microservices/src/orders
gcloud builds submit --tag gcr.io/${GOOGLE_CLOUD_PROJECT}/orders:1.0.0 .
cd ~/monolith-to-microservices/microservices/src/products
gcloud builds submit --tag gcr.io/${GOOGLE_CLOUD_PROJECT}/products:1.0.0 .

# Task 4: Deploy the new microservices
kubectl create deployment orders --image=gcr.io/${GOOGLE_CLOUD_PROJECT}/orders:1.0.0
kubectl create deployment products --image=gcr.io/${GOOGLE_CLOUD_PROJECT}/products:1.0.0
kubectl get all
kubectl expose deployment orders --type=LoadBalancer --port 80 --target-port 8081
kubectl expose deployment products --type=LoadBalancer --port 80 --target-port 8082
kubectl get service orders
kubectl get service products


# Task 5: Create a containerized version of the Frontend microservice
cd ~/monolith-to-microservices/react-app
kubectl get service # Copy the EXTERNAL-IP
nano .env # EDIT FILE WITH THIS:
    # REACT_APP_ORDERS_URL=http://<ORDERS_IP_ADDRESS>/api/orders
    # REACT_APP_PRODUCTS_URL=http://<PRODUCTS_IP_ADDRESS>/api/products
npm run build

cd ~/monolith-to-microservices/microservices/src/frontend
gcloud builds submit --tag gcr.io/${GOOGLE_CLOUD_PROJECT}/frontend:1.0.0 .

# Task 6: Deploy the Frontend microservice
kubectl create deployment frontend --image=gcr.io/${GOOGLE_CLOUD_PROJECT}/frontend:1.0.0
kubectl expose deployment frontend --type=LoadBalancer --port 80 --target-port 8080
