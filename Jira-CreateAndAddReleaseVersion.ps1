[CmdletBinding]
param (
    [Parameter(Mandatory=$false)][string]$UserName,
    [Parameter(Mandatory=$false)][string]$Password,
    [Parameter(Mandatory=$true)][int]$ProjectId,
    [Parameter(Mandatory=$true)][string]$ProjectKey,
    [Parameter(Mandatory=$true)][string]$ProjectName,
    [Parameter(Mandatory=$false)][string]$IssueKey = $null
)

function Invoke-RestRequest {
    param (
        [string]$Uri,
        [string]$Method = 'GET',
        [string]$Body = $null,
        [string]$ContentType = "application/json",
        [pscredential]$Credential = $null,
        [bool]$Debug = $false
    )
    $Uri = $Uri -replace ' ', '%20';
    Write-Host "${Method} ${Uri}";
    if ($Credential -eq $null) {
        $Credential = Get-Credential -UserName $env:USERNAME
    }
    $encodedCredentials = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("Basic {0}:{1}" -f $Credential.UserName, $Credential.GetNetworkCredential().Password));
    $headers = @{
        "Authorization" = $encodedCredentials;
    }
    $response = Invoke-RestMethod -Method $Method -Uri $Uri -Headers $headers -ContentType $ContentType -Body $body;
    if ($Debug) {
        Write-Debug "Response: ${response}";
    }
}

function Get-LatestReleaseVersion {
    param (
        [string[]]$Versions,
        [string]$Prefix = '^.*-(\d)', # Matches everything before the last hyphen and number.
        [string]$Suffix = '-.*$', # Matches everything after the last hyphen and number.
        [string]$Pattern = "^.*-\d{4}\.\d\.\d+" # Matches the pattern of a version number.
    )
    try {
        $sortedVersions = $Versions | Where-Object {
            $_ -match $Pattern
        } | Sort-Object {
            [version]($_ -replace $Prefix, '' -replace $Suffix, '')
        } -Descending;
        return $sortedVersions[0];
    }
    catch {
        Write-Host "Error: ${_}";
        $Versions;
        return $null;
    }
}

function Get-JiraLatestVersion {
    param (
        [int]$ProjectId,
        [string]$ProjectName,
        [string]$JiraBaseUrl = "https://jira.atlassian.com",
        [string]$JiraApiUrl = "${JiraBaseUrl}/rest/api/latest/project/${ProjectId}/versions",
        [pscredential]$Credential = $null
    )
    $response = Invoke-RestRequest -Method 'GET' -Uri $JiraApiUrl -Credential $Credential;
    $latestVersion = $response | Where-Object { $_.name -like "${ProjectName}*" } | Select-Object -Last 1;
    Write-Host "Latest version of ${ProjectName} is ${latestVersion.name}.";
    return $latestVersion.name;
}

function Create-JiraReleaseVersion {
    param (
        [int]$ProjectId,
        [string]$ProjectKey,
        [string]$VersionName = "${ProjectKey}${ProjectId}-$(Get-Date -Format 'yyyy.MMdd.HHmm')",
        [string]$VersionDescription = "Release version ${VersionName}.",
        [string]$JiraBaseUrl = "https://jira.atlassian.com",
        [string]$JiraApiUrl = "${JiraBaseUrl}/rest/api/latest/version",
        [pscredential]$Credential = $null
    )
    $body = @{
        "projectId" = $ProjectId;
        "project" = $ProjectKey;
        "name" = $VersionName;
        "description" = $VersionDescription;
        "startDate" = Get-Date -Format "yyyy-MM-dd";
        "releaseDate" = (Get-Date).AddDays(1).ToString("yyyy-MM-dd");
        "archived" = $false;
        "released" = $true;
    } | ConvertTo-Json;
    $response = Invoke-RestRequest -Method 'POST' -Uri $JiraApiUrl -Body $body -Credential $Credential;
    Write-Host "Created version '${VersionName}' (${response.id}) for project ${ProjectKey} (${ProjectId}).";
    return $response;
}

function Add-JiraReleaseVersion {
    param (
        [int]$VersionId,
        [string]$IssueKey,
        [string]$JiraBaseUrl = "https://jira.atlassian.com",
        [string]$JiraApiUrl = "${JiraBaseUrl}/rest/api/latest/issue/${IssueKey}",
        [pscredential]$Credential = $null
    )
    $headers = Get-JsonAuthorizationHeaderBasic -Credential $Credential;
    $body = @{
        "update" = @{
            "fixVersions" = @(
                @{
                    "add" = @{
                        "id" = $VersionId;
                    }
                }
            )
        }
    } | ConvertTo-Json;
    $response = Invoke-RestRequest -Method 'PUT' -Uri $JiraApiUrl -Body $body -Credential $Credential;
    Write-Host "Added version '${VersionId}' to issue ${IssueKey}.";
}

function Get-CredentialInline {
    param (
        [string]$UserName,
        [string]$Password,
        [pscredential]$FallbackCredential = $null
    )
    if (-not [string]::IsNullOrEmpty($UserName) -and -not [string]::IsNullOrEmpty($Password)) {
        return New-Object System.Management.Automation.PSCredential ($UserName, (ConvertTo-SecureString $Password -AsPlainText -Force));
    }
    if (-not [string]::IsNullOrEmpty($UserName)) {
        return Get-Credential -UserName $UserName;
    }
    if ($FallbackCredential -ne $null) {
        return $FallbackCredential;
    }
    return Get-Credential -UserName $env:USERNAME;
}

function Jira-CreateAndAddReleaseVersion {
    param (
        [int]$ProjectId,
        [string]$ProjectKey,
        [string]$ProjectName,
        [string]$IssueKey = $null,
        [string]$UserName = $null,
        [string]$Password = $null,
        [pscredential]$Credential = $null
    )
    $Credential = Get-CredentialInline -UserName $UserName -Password $Password -FallbackCredential $Credential;
    $generatedVersion = Create-JiraReleaseVersion -ProjectId $ProjectId -ProjectKey $ProjectKey -Credential $Credential;
    if (-not [string]::IsNullOrEmpty($IssueKey)) {
        Add-JiraReleaseVersion -VersionId $generatedVersion.id -IssueKey $IssueKey -Credential $Credential;
    }
    return $generatedVersion;
}

return Jira-CreateAndAddReleaseVersion -ProjectId $ProjectId -ProjectKey $ProjectKey -ProjectName $ProjectName -IssueKey $IssueKey -UserName $UserName -Password $Password;

# Usage:
# & "${sourceFolder}/PowerShellHelpers/Jira-CreateAndAddReleaseVersion.ps1" -ProjectId $jiraProjectId -ProjectKey $jiraProjectKey -ProjectName $jiraProjectName -IssueKey $jiraIssueKey -UserName $jiraUserName -Password $jiraPassword;