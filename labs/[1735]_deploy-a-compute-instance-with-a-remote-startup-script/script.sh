# Deploy a Compute Instance with a Remote Startup Script
# https://google.qwiklabs.com/focuses/1735?parent=catalog

# Task 1: Confirm that a Google Cloud Storage bucket exists that contains a file
gsutil mb gs://$DEVSHELL_PROJECT_ID
gsutil cp gs://sureskills-ql/challenge-labs/ch01-startup-script/install-web.sh gs://$DEVSHELL_PROJECT_ID

# Task 2: Confirm that a compute instance has been created that has a remote startup script called install-web.sh configured
gcloud compute instances create example-instance --zone=us-central1-a --tags=http-server --metadata startup-script-url=gs://$DEVSHELL_PROJECT_ID/install-web.sh

# Task 3: Confirm that a HTTP access firewall rule exists with tag that applies to that virtual machine
gcloud compute firewall-rules create allow-http --target-tags http-server --source-ranges 0.0.0.0/0 --allow tcp:80

# Task 4: Connect to the server ip-address using HTTP and get a non-error response
# After firewall creation (Task 3) just wait and then check the score
