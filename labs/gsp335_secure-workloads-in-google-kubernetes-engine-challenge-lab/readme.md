# [Secure Workloads in Google Kubernetes Engine: Challenge Lab](https://www.qwiklabs.com/focuses/13389?parent=catalog)

## Topics tested:

* Enable TLS access using nginx-ingress and cert-manager.io
* Secure traffic with a network policy
* Enable Binary Authorization to ensure only approved images are deployed
* Ensure that pods do not allow escalations to root


## Challenge Scenario

As a newly trained Kubernetes engineer in Jooli Inc. you have been asked to demonstrate to the security team features to protect Kubernetes workloads.

You are expected to have the skills and knowledge for these tasks so don’t expect step-by-step guides.

Some Jooli Inc. standards you should follow:

* Create all resources in the us-east1 region and us-east1-b zone, unless otherwise directed.

* Use the project VPCs.

* Naming is normally team-resource, e.g. an instance could be named kraken-webserver1.

* Allocate cost effective resource sizes. Projects are monitored and excessive resource use will result in the containing project's termination (and possibly yours), so beware. This is the guidance the monitoring team is willing to share: unless directed, use n1-standard-1.

