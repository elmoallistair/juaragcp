# [Perform Foundational Infrastructure Tasks in Google Cloud: Challenge Lab ](https://www.qwiklabs.com/focuses/10379?parent=catalog)

## Your challenge

You are now asked to help a newly formed development team with some of their initial work on a new project around storing and organizing photographs, called memories. You have been asked to assist the memories team with initial configuration for their application development environment; you receive the following request to complete the following tasks:

* Create a bucket for storing the photographs.
* Create a Pub/Sub topic that will be used by a Cloud Function you create.
* Create a Cloud Function.
* Remove the previous cloud engineer’s access from the memories project.

Some Jooli Inc. standards you should follow:

* Create all resources in the **us-east1** region and **us-east1-b** zone, unless otherwise directed.
* Use the project VPCs.
* Naming is normally team-resource, e.g. an instance could be named **kraken-webserver1**
* Allocate cost effective resource sizes. Projects are monitored and excessive resource use will result in the containing project's termination (and possibly yours), so beware. This is the guidance the monitoring team is willing to share; unless directed, use **f1-micro** for small Linux VMs and **n1-standard-1** for Windows or other applications such as Kubernetes nodes.
