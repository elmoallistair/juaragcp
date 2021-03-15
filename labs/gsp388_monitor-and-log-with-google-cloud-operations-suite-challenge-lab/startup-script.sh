#!/bin/bash
sudo curl -O https://storage.googleapis.com/golang/go1.10.2.linux-amd64.tar.gz
sudo tar -xvf go1.10.2.linux-amd64.tar.gz
sudo mv go /usr/local
curl -sSO https://dl.google.com/cloudagents/add-monitoring-agent-repo.sh 
curl -sSO https://dl.google.com/cloudagents/add-logging-agent-repo.sh 
sudo bash add-monitoring-agent-repo.sh 
sudo bash add-logging-agent-repo.sh 

sudo apt-get -y update
sudo apt-get -y install git
sudo apt-get install -y stackdriver-agent
sudo service stackdriver-agent start

mkdir /work
mkdir /work/go
cd /work/go
export GOPATH=/work/go
export PATH=$PATH:/usr/local/go/bin
go get go.opencensus.io
go get contrib.go.opencensus.io/exporter/stackdriver
export MY_PROJECT_ID=[REPLACE-WITH-PROJECT_ID]
export MY_GCE_INSTANCE_ID=[REPLACE-WITH-INSTANCE-ID]
export MY_GCE_INSTANCE_ZONE=[REPLACE-WITH-INSTANCE-ZONE]
gsutil cp gs://cloud-training/gsp338/video_queue/main.go /work/go/main.go
go run /work/go/main.go
