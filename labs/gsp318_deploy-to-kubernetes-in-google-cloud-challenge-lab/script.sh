# Deploy to Kubernetes in Google Cloud: Challenge Lab
# https://www.cloudskillsboost.google/focuses/10457?parent=catalog

# Task 1. Create a Docker image and store the Dockerfile
    # Open Cloud shell, run:
    source <(gsutil cat gs://cloud-training/gsp318/marking/setup_marking_v2.sh)
    gcloud source repos clone valkyrie-app
    cd valkyrie-app
    cat > Dockerfile <<EOF
        FROM golang:1.10
        WORKDIR /go/src/app
        COPY source .
        RUN go install -v
        ENTRYPOINT ["app","-single=true","-port=8080"]
EOF
    docker build -t valkyrie-dev:v0.0.3 .
    bash ~/marking/step1_v2.sh

# Task 2. Test the created Docker image
    # Open Cloud shell, run:
    docker run -p 8080:8080 valkyrie-dev:v0.0.3 &
    bash ~/marking/step2_v2.sh

# Task 3. Push the Docker image to the Artifact Registry
    - Navigation Menu > Artifact Registry > Repositories > Create Repository: 
        - Name: valkyrie-docker-repo
        - Format: Docker
        - Region: us-central1
        - Create
    # Open Cloud shell, run:
    gcloud auth configure-docker us-central1-docker.pkg.dev
    export PROJECT_ID=$(gcloud config get-value project)
    docker build -t us-central1-docker.pkg.dev/$PROJECT_ID/valkyrie-docker-repo/valkyrie-dev:v0.0.3 .
    docker push us-central1-docker.pkg.dev/$PROJECT_ID/valkyrie-docker-repo/valkyrie-dev:v0.0.3

# Task 4. Create and expose a deployment in Kubernetes
    # Open Cloud shell, run:
    sed -i s#IMAGE_HERE#us-central1-docker.pkg.dev/$PROJECT_ID/valkyrie-docker-repo/valkyrie-dev:v0.0.3#g k8s/deployment.yaml
    gcloud container clusters get-credentials valkyrie-dev --zone us-east1-d
    kubectl create -f k8s/deployment.yaml
    kubectl create -f k8s/service.yaml
