---
title: "Leverage PaaS to make your IaaS easier"
categories:
  - azure
tags:
  - syadmin
---

## Everything now has an API

When you begin deploying resources into the cloud those resources now have programmable interface that you can begin to manipulate at scale. We begin looking at our infrastructure as a manipulatable object and not some monolothic device that requires some KVM to manage it. We're now able to "zoom-out" and look at how we're managing our resources and interact with them at scale.

## Manage VM's with Azure PaaS resources

The most common roadblock in Cloud migrations comes from this question

> What's the point in moving VM's from On-Prem to Azure if I'm still stuck with managing VM's?

And that's where we start down the discovery path of how things are being done today and they can be improved in the future. Especially when we talk about operations and how can we not only develop our architecture but secure it and operate it in a way that allows us to focus on other problems. Here are going the Azure Platform benefits you can get when migrating a VM to Azure

* Credential Management through Azure **Key Vault**
* Continous Monitoring and alerting with Azure **Monitor** and **Security Center**
* Configuration Management with Azure **Desired State Configuration**
* Insights into your patch status with Azure **Update Management**
* Automated Backup and COOP with Azure **Recovery Vault**

And more! There's more to a VM migration in Azure than just running in our data center and all of the services above require no additional procured license to operate making the migration from 0-100 much better. With each new VM appearing in Azure they now become an object that is up for manipulation that an organization can define at scale. No more relying on certain hardware to run X workload we're now able to take a step back and look at our entire IaaS infrastructure at scale and automate the mundane tasks to the Azure platform to manage. 

## Technology cannot fix culture 

The Azure platform exists to help empower the enterprise to re-think how they handle operations from a day-to-day perspective and a 1 year plan perspective. The most common question that will get asked is 

> With the Cloud can we do more with less?

And the answer is yes. The Cloud can help enable an enterprise to re-assign their staff to other tasks and move off from managing just basic operations and begin focusing on specialized projects. **However** if the culture in the operations side carries the bad practices that were prevalent On-Prem then no amount of technical modernization will be fixed when coming to the Cloud. I **highly** encourage all who are reading this blog to visit the [Cloud Adoption Framework](aka.ms/caf) and begin to re-think what the System Administrator can and can't do as part of their roles and responsibilities. 