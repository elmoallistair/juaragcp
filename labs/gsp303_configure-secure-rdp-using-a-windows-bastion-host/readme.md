# [Configure Secure RDP using a Windows Bastion Host](https://www.qwiklabs.com/focuses/1737?parent=catalog)

## Topics tested

* Create a new VPC to host secure production Windows services.
* Create a Windows host connected to a subnet in the new VPC with an internal only network interface.
* Create a Windows bastion host (jump box) in with an externally accessible network interface.
* Configure firewalls rules to enable management of the secure Windows host from the Internet using the bastion host as a jump box.

## Challenge scenario

Your company has decided to deploy new application services in the cloud and your assignment is developing a secure framework for managing the Windows services that will be deployed. You will need to create a new VPC network environment for the secure production Windows servers.

Production servers must initially be completely isolated from external networks and cannot be directly accessible from, or be able to connect directly to, the internet. In order to configure and manage your first server in this environment, you will also need to deploy a bastion host, or jump box, that can be accessed from the internet using the Microsoft Remote Desktop Protocol (RDP). The bastion host should only be accessible via RDP from the internet, and should only be able to communicate with the other compute instances inside the VPC network using RDP.

Your company also has a monitoring system running from the default VPC network, so all compute instances must have a second network interface with an internal only connection to the default VPC network.
