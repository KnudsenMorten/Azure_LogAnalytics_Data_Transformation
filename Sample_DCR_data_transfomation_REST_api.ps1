#Requires -Version 5.0
<#
    .SYNOPSIS
    This script will export existing Data Collection Rules (DCR) from existing DCR in Azure Monitor
    This script will also update / upload file with changes (TransformKql added)

    .NOTES
    VERSION: 2212

    .COPYRIGHT
    @mortenknudsendk on Twitter (new followers appreciated)
    Blog: https://mortenknudsen.net
    
    .LICENSE
    Licensed under the MIT license.
    Please credit me if you fint this script useful and do some cool things with it.

    .WARRANTY
    Use at your own risk, no warranty given!
#>

####################################################
# VARIABLES
####################################################

# here you put the ResourceID of the Data Collection Rules (a sample is provided below)
$ResourceId = "/subscriptions/xxxxxx/resourceGroups/rg-logworkspaces/providers/microsoft.insights/dataCollectionRules/dcr-ingest-exclude-security-eventid"
    
# here you put a path and file name where you want to store the temporary file-extract from DCR (a sample is provided below)
$FilePath   = "c:\tmp\dcr-ingest-exclude-security-eventid.txt"


####################################################
# CONNECT TO AZURE
####################################################

Connect-AzAccount

####################################################
# EXPORT EXISTING DCR TO FILE
####################################################

$DCR = Invoke-AzRestMethod -Path ("$ResourceId"+"?api-version=2021-09-01-preview") -Method GET

$DCR.Content | ConvertFrom-Json | ConvertTo-Json -Depth 20 | Out-File -FilePath $FilePath


####################################################
# MODIFY FILE AND ADD TRANSFORMKQL CMDs
####################################################

<#    
    SAMPLES
    "transformKql": "source\n| where (EventID != 8002) and (EventID != 5058) and (EventID != 4662) and (EventID != 4688)",

    "transformKql": "source\n| where EventID != 5145",
    "outputStream": "Microsoft-SecurityEvent"
#>

####################################################
# UPLOAD FILE / UPDATE DCR WITH TRANSFORM
####################################################

$DCRContent = Get-Content $FilePath -Raw 

Invoke-AzRestMethod -Path ("$ResourceId"+"?api-version=2021-09-01-preview") -Method PUT -Payload $DCRContent
