# [Deploy a Compute Instance with a Remote Startup Script](https://www.qwiklabs.com/focuses/1735?parent=catalog)

## Topics tested

* Create a storage bucket for startup scripts.
* Create a virtual machine that runs a startup script from Cloud Storage.
* Configure HTTP access for the virtual machine.
* Deploy an application on an instance.


## Challenge scenario

You have been given the responsibility of managing the configuration of your organization's Google Cloud virtual machines. You have decided to make some changes to the framework used for managing the deployment and configuration machines - you want to make it easier to modify the startup scripts used to initialize a number of the compute instances. Instead of storing startup scripts directly in the instances' metadata, you have decided to store the scripts in a Cloud Storage bucket and then configure the virtual machines to point to the relevant script file in the bucket.

A basic bash script that installs the Apache web server software called install-web.sh has been provided for you as a sample startup script. You can download this from the Student Resources links on the left side of the page.