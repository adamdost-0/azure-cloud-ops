<#
.SYNOPSIS
    A quick & dirty script to execute a bicep build & Checkmarx scan


.PARAMETER filePath
    The filePath Paramter is used to define what FOLDER you are looking to have the scanner mount into the container for scanning

.PARAMETER bicepFileName
    The name of the bicep file that will be converted to ARM for KICS to scan it with 
    

.EXAMPLE
    Example syntax for running the script or function
    PS C:\> .\powershell\Scan-Bicep.ps1 -filePath C:\Users\adost\OneDrive\Desktop\cloudOps\azure-cloud-ops\bicep\domainController -bicepFileName dc.bicep

.NOTES
    Filename: Scan-Iac.ps1
    Author: Adam Dost
    Modified date: 2022-03-20
    Version 1.0 - Initial public release
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [String]
    $filePath,
    [Parameter(Mandatory=$true)]
    [string]
    $bicepFileName
)

## Convert Bicep to ARM
bicep build ${FilePath}/${bicepFileName} --outfile main.json
## Run the KICS Scan and create a results folder to dump all possible report formats
docker run -v ${FilePath}:/path checkmarx/kics:debian kics scan `
        --ci `
        -p "/path" `
        -o "/path/results" `
        -t "AzureResourceManager" `
        --report-formats all `
        --cloud-provider azure 