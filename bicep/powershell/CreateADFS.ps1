param(
  [Parameter(Mandatory=$false)]
  [string]$DomainName = "fogone.xyz",

  [Parameter(Mandatory=$false)]
  [string]$UserName = "ccefogoneadmin"
)

# NOTE:
# - Never hardcode passwords/secrets in scripts committed to git.
# - Provide credentials via prompt, Key Vault, or an automation secret store.

$securePassword = Read-Host -Prompt "Enter password for $UserName" -AsSecureString

$fqdn = [System.Net.Dns]::GetHostByName(($env:computerName)) | FL HostName | Out-String | %{ "{0}" -f $_.Split(':')[1].Trim() }
$filename = "C:\$fqdn.pfx"

$credential = New-Object `
  -TypeName System.Management.Automation.PSCredential `
  -ArgumentList $UserName, $securePassword

Write-Host "Installing nuget package provider"
Install-PackageProvider nuget -force

Write-Host "Installing PSPKI module"
Install-Module -Name PSPKI -Force

Write-Host "Importing PSPKI into current environment"
Import-Module -Name PSPKI

Write-Host "Generating Certificate"
$selfSignedCert = New-SelfSignedCertificateEx `
  -Subject "CN=$fqdn" `
  -ProviderName "Microsoft Enhanced RSA and AES Cryptographic Provider" `
  -KeyLength 2048 -FriendlyName 'OAFED SelfSigned' -SignatureAlgorithm sha256 `
  -EKU "Server Authentication", "Client authentication" `
  -KeyUsage "KeyEncipherment, DigitalSignature" `
  -Exportable -StoreLocation "LocalMachine"
$certThumbprint = $selfSignedCert.Thumbprint

Write-Host "Installing ADFS"
Install-WindowsFeature -IncludeManagementTools -Name ADFS-Federation

Write-Host "Configuring ADFS"
Import-Module ADFS
Install-AdfsFarm -CertificateThumbprint $certThumbprint -FederationServiceName $fqdn -ServiceAccountCredential $credential
