---
title: "Containerization on Azure"
categories:
  - Kubernetes
  - Azure
  = Containers
tags:
  - kubernetes
---


Azure Kubernetes Service (AKS) is Microsoft's cloud service offering that helps bring the power of Kubernetes to Azure. But it's not your only option when looking to run containers on Azure today in a PaaS setting. Here are your three choices for running containers on Azure today!

1. Azure Container Instance
2. Azure WebApp for Containers
3. Azure Kubernetes Service


All 3 services *can* run in a private configuration where it only holds a RFC1918 IP address. From there your requirements will define which path is best for you. With Azure container instances you're looking at pushing a container from a registry into the service and can expose various ports when starting with container instances in Azure. Keep in mind that port **mapping** is not supported in Azure Container Instances today so ensure your container group does not have overlapping ports on something like 80, 443 or 8080!

Azure WebApp for containers introduces more features such as custom domain verification and TLS/SSL Bindings that can be done to secure your container instance. You're only going to have port 80/443 to work with but this would be a great solution if you have a containerized front end that serves itself over port 443. Access restrictions also allow you to control what IP ranges can get into your application as well! For enterprise environment's you can limit access to your application from a single Gateway IP address that your enterprise owns to add a layer of security.

Lastly AKS is Microsoft's newest offering for running containerized workloads in Azure. Microsoft provides an API endpoint for administrators to communicate securely to the kubernetes api to issue commands and deployments such as helm charts. This is where you would point kubectl commands to as well. AKS has 2 different configurations for exposing it's Kubernetes API Url which are public and private mode. You can control which public IP addresses can hit the public AKS URL but if that is a risk you are not comfortable with taking then running in private cluster mode will be your secure path forward. By limiting the API url to a RFC1918 IP address that allows communication between your administration and service on the Azure backend. 

Hopefully this helped you understand your various options in Azure for containerization!