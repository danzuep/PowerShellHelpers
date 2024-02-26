# Use PowerShell To Retrieve the Latest Package Url From GitHub Releases.
# https://copdips.com/2019/12/Using-Powershell-to-retrieve-latest-package-url-from-github-releases.html
# Usage: `. [System.IO.Path]::Combine($Env:KUBERNETES_LOCAL, "scripts", "Get-LatestGitHubVersion.ps1"); $certManagerUrl = Get-LatestGitHubReleaseUrl "jetstack/cert-manager";`
Function Get-LatestGitHubVersion([string]$accountRepository)
{
    $url = Get-GitHubProjectUrl $accountRepository;
    if ($accountRepository.EndsWith("/releases")) {
        $url += "/latest"
    }
    elseif (!$accountRepository.EndsWith("/releases/latest")) {
        $url += "/releases/latest"
    }
    $request = [System.Net.WebRequest]::Create($url)
    $response = $request.GetResponse()
    $realTagUrl = $response.ResponseUri.OriginalString
    $version = $realTagUrl.split('/')[-1]
    Write-Host "Latest version from '${url}' is '${version}'."
    return $version
}

Function Get-GitHubProjectUrl([string]$accountRepository)
{
    if ($accountRepository.StartsWith("https://github.com/")) {
        $gitHubUrl = $accountRepository
    } elseif (!$accountRepository.Contains("/")) {
        $gitHubUrl = "https://github.com/${accountRepository}/${accountRepository}"
    } else {
        $gitHubUrl = "https://github.com/${accountRepository}"
    }
    return $gitHubUrl
}

Function Get-LatestGitHubReleaseUrl([string]$accountRepository)
{
    $gitHubUrl = Get-GitHubProjectUrl $accountRepository;
    $gitHubVersion = Get-LatestGitHubVersion $gitHubUrl;
    $url = "${gitHubUrl}/releases/download/${gitHubVersion}";
    return $url
}