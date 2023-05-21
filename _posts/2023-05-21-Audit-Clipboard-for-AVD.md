---
title: "Audit Clipboard configuration for AVD"
categories:
  - azure
tags:
  - security
---

As you begin enabling teams to roll out custom host pools for consumption, the discussion of "Clipboard" access becomes a key topic to ensure data does not leave the enterprise environment. To enable the development of customized host pools at scale, use the following Azure Policy to help audit and enforce different AVD configurations so that everyone follows an enterprise baselin


````json
{
    "policyRule": {
        "if": {
            "allOf": [
                {
                    "field": "type",
                    "equals": "Microsoft.DesktopVirtualization/hostPools"
                },
                {
                    "field": "Microsoft.DesktopVirtualization/hostPools/customRdpProperty",
                    "contains": "redirectclipboard:i:1"
                }
            ]
        },
        "then": {
            "effect": "audit"
        }
    }
}
````


The area of focus is the content contained in the "customRdpProperty" field. What this Azure policy will do is audit every host pool's RDP configuration string and check if the clipboard has been disabled or not. If the host pool has the clipboard disabled, it will return a "success"; otherwise, it will return as not compliant.

You can assign exceptions to host pools that require it to be enabled by changing the value to ````"redirectclipboard:i:0"````.

You can also leverage this Azure Policy to enforce different Host Pool property settings depending on your enterprise's requirements. What the "contains" policy does is perform a string check on the property to ensure that the value is present.

[Here](https://learn.microsoft.com/en-us/azure/virtual-desktop/rdp-properties) is the full list of custom RDP properties that can be set on Azure Virtual Desktop. Have fun publishing new host pools!