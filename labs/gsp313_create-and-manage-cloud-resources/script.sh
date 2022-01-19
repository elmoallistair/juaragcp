# Create and Manage Cloud Resources: Challenge Lab
# https://www.qwiklabs.com/focuses/10258

# 1. Create a project jumphost instance (zone: us-east1-b)
gcloud compute instances create nucleus-jumphost-850 \
        --zone="us-east1-b" \
        --machine-type="f1-micro" \
        --boot-disk-size=10GB
# if failed to check, go create it manually

# 2. Create a Kubernetes service cluster
gcloud config set compute/zone us-east1-b
gcloud container clusters create nucleus-jumphost-webserver1
gcloud container clusters get-credentials nucleus-jumphost-webserver1
kubectl create deployment hello-app --image=gcr.io/google-samples/hello-app:2.0
kubectl expose deployment hello-app --type=LoadBalancer --port 8083
kubectl get service

# 3. Create the web server frontend 
## 3.1 Create Instance Template
cat << EOF > startup.sh
#! /bin/bash
apt-get update
apt-get install -y nginx
service nginx start
sed -i -- 's/nginx/Google Cloud Platform - '"\$HOSTNAME"'/' /var/www/html/index.nginx-debian.html
EOF
gcloud compute instance-templates create nginx-template \
--metadata-from-file startup-script=startup.sh

## 3.2 Create Target Pool
gcloud compute target-pools create nginx-pool
# NOTE: Create it us-east1 region

## 3.3 Create managed instance group
gcloud compute instance-groups managed create nginx-group \
    --base-instance-name nginx \
    --size 2 \
    --template nginx-template \
    --target-pool nginx-pool

## 3.4 Create firewall rule
gcloud compute firewall-rules create accept-tcp-rule-525 --allow tcp:80
gcloud compute forwarding-rules create nginx-lb \
    --region us-east1 \
    --ports=80 \
    --target-pool nginx-pool

## 3.5 Create health check
gcloud compute http-health-checks create http-basic-check
gcloud compute instance-groups managed set-named-ports nginx-group \
    --named-ports http:80

## 3.6 Create backend service
gcloud compute backend-services create nginx-backend \
    --protocol HTTP --http-health-checks http-basic-check --global
gcloud compute backend-services add-backend nginx-backend \
    --instance-group nginx-group \
    --instance-group-zone us-east1-b \
    --global

## 3.7 Create url map
gcloud compute url-maps create web-map \
    --default-service nginx-backend
gcloud compute target-http-proxies create http-lb-proxy \
    --url-map web-map

## 3.8 Create forwarding rule
gcloud compute forwarding-rules create http-content-rule \
    --global \
    --target-http-proxy http-lb-proxy \
    --ports 80
    
## 3.9 Testing traffic sent to your instances
## Network services > Load balancing
## Click web-map
## Click the name of the backend
## Open new tab
## Paste http://IP_ADDRESS/ in the URL bar (replace IP_ADDRESS with the load balancer's IP address)
