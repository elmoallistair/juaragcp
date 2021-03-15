export PROJECT_ID=$DEVSHELL_PROJECT_ID

# 1. Create a bucket
gsutil mb gs://$PROJECT_ID

# 2. Create a Pub/Sub topic
gcloud pubsub topics create $PROJECT_ID

# 3. Create the Cloud Function
# Go to Cloud Functions > Create Function
# Trigger: Cloud Storage
# Event type: Finalize/Create
# Entry Point: thumbnail
# Runtime: Node.js
# fill index.js and package.json with given scripts
# replace line 15 in index.js, in this case, fill with your project id
# upload one JPG or PNG image into the bucket

# 4. Remove the previous cloud engineer 
# Go to IAM > find your second username > Click Pencil Icon > Delete