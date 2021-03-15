# Task 1. Create our cluster and deploy our app
ZONE=us-central1-b

gcloud container clusters create onlineboutique-cluster --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --machine-type=n1-standard-2 --num-nodes=2

kubectl create namespace dev

kubectl create namespace prod

git clone https://github.com/GoogleCloudPlatform/microservices-demo.git &&
cd microservices-demo && kubectl apply -f ./release/kubernetes-manifests.yaml --namespace dev

kubectl get svc -w --namespace dev

-In the GCP Console go to Navigation Menu >Kubernets Engine> Service and Ingress >click endpoints frontend-external 
- or In the Cloud Shell Copy and Paste the code
kubectl get svc -w --namespace dev

#Task 2. Migrate to an Optimized Nodepool
gcloud container node-pools create optimized-pool --cluster=onlineboutique-cluster --machine-type=custom-2-3584 --num-nodes=2 --zone=$ZONE

for node in $(kubectl get nodes -l cloud.google.com/gke-nodepool=default-pool -o=name); do  kubectl cordon "$node"; done

for node in $(kubectl get nodes -l cloud.google.com/gke-nodepool=default-pool -o=name); do kubectl drain --force --ignore-daemonsets --delete-local-data --grace-period=10 "$node"; done

kubectl get pods -o=wide --namespace=dev

gcloud container node-pools delete default-pool --cluster onlineboutique-cluster --zone $ZONE

# Task 3. Apply a Frontend Update
kubectl create poddisruptionbudget onlineboutique-frontend-pdb --selector app=frontend --min-available 1 --namespace dev

- Edit your frontend deployment and change its image to the updated one.
KUBE_EDITOR="nano" kubectl edit deployment/frontend --namespace dev

- Find the image under spec replace.
image: gcr.io/qwiklabs-resources/onlineboutique-frontend:v2.1


kubectl autoscale deployment frontend --cpu-percent=50 --min=1 --max=13 --namespace dev

kubectl get hpa --namespace dev

# Task 4. Autoscale from Estimated Traffic
gcloud beta container clusters update onlineboutique-cluster --enable-autoscaling --min-nodes 1 --max-nodes 6 --zone $ZONE

https://mayankchourasia2.medium.com/optimize-costs-for-google-kubernetes-engine-challenge-lab-d336225922fb
