# [Scale Out and Update a Containerized Application on a Kubernetes Cluster](https://www.qwiklabs.com/focuses/1739?parent=catalog)

## Topics tested

* Update a docker application and push a new version to a container repository.
* Deploy the updated application version to a Kubernetes cluster.
* Scale out the application so that it is running 2 replicas.

## Challenge scenario

You are taking over ownership of a test environment and have been given an updated version of a containerized test application to deploy. Your systems' architecture team has started adopting a containerized microservice architecture. You are responsible for managing the containerized test web applications. You will first deploy the initial version of a test application, called echo-app to a Kubernetes cluster called echo-cluster in a deployment called echo-web.

Before you get started, open the navigation menu and select Storage. The last steps in the Deployment Manager script used to set up your environment creates a bucket.

Refresh the Storage browser until you see your bucket. You can move on once your Console resembles the following:

![buckets.png](https://cdn.qwiklabs.com/6LFiu9lfhzr7qtTo4e1BifM0q0cRiNDzEHnvYmfvrjc%3D)

Check to make sure your GKE cluster has been created before continuing. Open the navigation menu and select Kuberntes Engine > Clusters.

Continue when you see a green checkmark next to echo-cluster:

![cluster-complete.png](https://cdn.qwiklabs.com/QouWWaKBDJ2Dug%2B1QP3Zw4jqG5NTXpXmRhrfTXvdF08%3D)

To deploy your first version of the application, run the following commands in Cloud Shell to get up and running:

`gcloud container clusters get-credentials echo-cluster --zone=us-central1-a`

`kubectl create deployment echo-web --image=gcr.io/qwiklabs-resources/echo-app:v1`

`kubectl expose deployment echo-web --type=LoadBalancer --port 80 --target-port 8000`
