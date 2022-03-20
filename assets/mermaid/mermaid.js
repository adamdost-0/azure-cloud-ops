````mermaid-js
graph LR
    root[src] --> a[bicep]
    a --> 1[bicepModules]
    a --> 2[solutions] 
    subgraph 2g[Bicep Solutions Folder]
    2 --> 3[Solution.bicep] --> 4[Code-Scan] --> 5[results.json]
    end

    subgraph 1g[All Bicep modules]
    1 --> 11[acrModule] --> 11a[acr.bicep]
    11 --> 11b[Code-Scan] --> 11c[results.json]
    1 --> 12[vmModule] --> 12a[vm.bicep]
    12 --> 12b[Code-Scan]  --> 12c[results.json]
    end
    

````