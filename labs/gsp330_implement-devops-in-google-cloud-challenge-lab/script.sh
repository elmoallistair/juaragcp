# Implement DevOps in Google Cloud: Challenge Lab 
# https://www.qwiklabs.com/focuses/13287?parent=catalog

# Open Cloud shell, run: 
gcloud config set compute/zone us-east1-b
git clone https://source.developers.google.com/p/$DEVSHELL_PROJECT_ID/r/sample-app
gcloud container clusters get-credentials jenkins-cd
kubectl create clusterrolebinding cluster-admin-binding --clusterrole=cluster-admin --user=$(gcloud config get-value account)
helm repo add stable https://charts.helm.sh/stable
helm repo update
helm install cd stable/jenkins
export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/component=jenkins-master" -l "app.kubernetes.io/instance=cd" -o jsonpath="{.items[0].metadata.name}")
kubectl port-forward $POD_NAME 8080:8080 >> /dev/null &
printf $(kubectl get secret cd-jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode);echo
# Note: copy the output (Jenkins password)
- Preview on Port 8000, Sign in jenkins
    - username: admin
    - password: see at your cloud shell output

# Back to Cloud shell, run:
cd sample-app
kubectl create ns production
kubectl apply -f k8s/production -n production
kubectl apply -f k8s/canary -n production
kubectl apply -f k8s/services -n production
kubectl get svc
kubectl get service gceme-frontend -n production
git init
git config credential.helper gcloud.sh
git remote add origin https://source.developers.google.com/p/$DEVSHELL_PROJECT_ID/r/sample-app
git config --global user.email "student-00-b41cda9e7603@qwiklabs.net"
git config --global user.name "[YOUR_USERNAME]"
git add .
git commit -m "initial commit"
git push origin master

# Back to Jenkins Dashboard > Manage Jenkins (left pane) > manage Credentials
#     - Look at "Stores scoped", click Jenkins
#     - Click Global credentials (unrestricted)
#     - Click Add Credentials
#         - Kind: Google Service Account from metadata
#         - Project Name: <your_project_id>
#         - Click OK
#
# Back to Jenkins Dashboard > New Item (left pane)
#    Enter an item name: sample-app
#    Click Multibranch Pipeline
#    OK
#    *in sample-app config*
#        - Branch Sources: Git
#            - Project Repository: https://source.developers.google.com/p/[PROJECT_ID]/r/sample-app
#            - Credentials: qwiklabs service account
#        - Scan Multibranch Pipeline Triggers, check "Periodically if not otherwise run"
#            - Interval: 1 minute
#        - SAVE # building will take long time
#        # Note: Repeat if you see error msg while scanning Multibranch Pipeline Log
#        - CHECK YOUR FIRST CHECKPOINT
#

# Back to Cloud Shell
git checkout -b new-feature
edit main.go
# change the version number to "2.0.0". 
# example: version string = "2.0.0" (in line 46)
edit html.go
# change both lines that contains the word blue to orange
# example: <div class="card orange"> (in line 37 and 81)

# Back to Cloud Shell
git add Jenkinsfile html.go main.go
git commit -m "Version 2.0.0"
git push origin new-feature
# Check your sample-app branches from jenkins dashboard (new-feature branch)

# Back to Cloud Shell 
curl http://localhost:8001/api/v1/namespaces/new-feature/services/gceme-frontend:80/proxy/version
kubectl get service gceme-frontend -n production  
git checkout -b canary
git push origin canary
git checkout master
git push origin master
# Check your sample-app branches from jenkins dashboard (canary branch)

# Back to Cloud Shell 
export FRONTEND_SERVICE_IP=$(kubectl get -o \
jsonpath="{.status.loadBalancer.ingress[0].ip}" --namespace=production services gceme-frontend)
while true; do curl http://$FRONTEND_SERVICE_IP/version; sleep 1; done
# after the you see output 2.0.0, run:
kubectl get service gceme-frontend -n production
# CHECK YOUR #2 #3 AND #4 CHECKPOINT (may be a delay)

###############################################################################################

# Note if task 4 not yet marked, try run:
git merge canary
git push origin master
# may take a long delay before check progress