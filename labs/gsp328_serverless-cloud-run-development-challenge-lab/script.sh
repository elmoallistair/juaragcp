# Task 1. Enable a Public Service
cd ~/pet-theory/lab07/unit-api-billing
gcloud builds submit \
  --tag gcr.io/$GOOGLE_CLOUD_PROJECT/billing-staging-api:0.1

gcloud run deploy public-billing-service \
    --image gcr.io/$GOOGLE_CLOUD_PROJECT/billing-staging-api:0.1 \
    --allow-unauthenticated

gcloud run deploy public-billing-service \
    --image gcr.io/$GOOGLE_CLOUD_PROJECT/billing-staging-api:0.1 \
    --allow-unauthenticated

# Task 2. Deploy a Frontend Service
cd ~/pet-theory/lab07/staging-frontend-billing
gcloud builds submit \
  --tag gcr.io/$GOOGLE_CLOUD_PROJECT/frontend-staging:0.1

gcloud run deploy frontend-staging-service \
    --image gcr.io/$GOOGLE_CLOUD_PROJECT/frontend-staging:0.1 \
    --allow-unauthenticated

gcloud run deploy frontend-staging-service \
    --image gcr.io/$GOOGLE_CLOUD_PROJECT/frontend-staging:0.1 \
    --allow-unauthenticated

# Task 3. Deploy a Private Service
cd ~/pet-theory/lab07/staging-api-billing
gcloud beta run services delete public-billing-service

gcloud builds submit \
  --tag gcr.io/$GOOGLE_CLOUD_PROJECT/billing-staging-api:0.2

gcloud run deploy private-billing-service \
    --image gcr.io/$GOOGLE_CLOUD_PROJECT/billing-staging-api:0.2 \
    --no-allow-unauthenticated

gcloud run deploy private-billing-service \
    --image gcr.io/$GOOGLE_CLOUD_PROJECT/billing-staging-api:0.2 \
    --no-allow-unauthenticated

BILLING_SERVICE=private-billing-service
BILLING_URL=$(gcloud run services describe $BILLING_SERVICE \
  --format "value(status.URL)")

curl -X get -H "Authorization: Bearer $(gcloud auth print-identity-token)" $BILLING_URL

# Task 4. Create a Billing Service Account
gcloud iam service-accounts create billing-service-sa --display-name "Billing Service Cloud Run"

# Task 5. Deploy the Billing Service
cd ~/pet-theory/lab07/prod-api-billing
gcloud builds submit \
  --tag gcr.io/$GOOGLE_CLOUD_PROJECT/billing-prod-api:0.1

gcloud run deploy billing-prod-service \
    --image gcr.io/$GOOGLE_CLOUD_PROJECT/billing-prod-api:0.1 \
    --no-allow-unauthenticated

gcloud run deploy billing-prod-service \
    --image gcr.io/$GOOGLE_CLOUD_PROJECT/billing-prod-api:0.1 \
    --no-allow-unauthenticated

gcloud run services add-iam-policy-binding billing-prod-service \
  --member=serviceAccount:billing-service-sa@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com \
  --role=roles/run.invoker

PROD_BILLING_SERVICE=private-billing-service

PROD_BILLING_URL=$(gcloud run services \
    describe $PROD_BILLING_SERVICE \
    --format "value(status.URL)")

curl -X get -H "Authorization: Bearer \
    $(gcloud auth print-identity-token)" \
    $PROD_BILLING_URL

# Task 6. Frontend Service Account
gcloud iam service-accounts create frontend-service-sa --display-name "Billing Service Cloud Run Invoker"

# Task 7. Redeploy the Frontend Service
cd ~/pet-theory/lab07/prod-frontend-billing
gcloud builds submit \
  --tag gcr.io/$GOOGLE_CLOUD_PROJECT/frontend-prod:0.1

gcloud run deploy frontend-prod-service \
    --image gcr.io/$GOOGLE_CLOUD_PROJECT/frontend-prod:0.1 \
    --allow-unauthenticated

gcloud run deploy frontend-prod-service \
    --image gcr.io/$GOOGLE_CLOUD_PROJECT/frontend-prod:0.1 \
    --allow-unauthenticated

gcloud run services add-iam-policy-binding frontend-prod-service \
  --member=serviceAccount:frontend-service-sa@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com \
  --role=roles/run.invoker
