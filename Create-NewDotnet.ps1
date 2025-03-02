[CmdletBinding()]
param (
    [Parameter(Mandatory=$false)]
    [string]$ProjectName = 'Benchmark',

    [Parameter(Mandatory=$false)]
    # [ValidateSet("console", "classlib", "web", "mvc", "api", "xunit", "nunit", "benchmark")]
    # dotnet new list | Select-Object -Property *
    [string]$ProjectType = 'benchmark',

    [Parameter(Mandatory=$false)]
    [string]$Folder = 'source',

    [Parameter(Mandatory=$false)]
    [string[]]$Packages
)

if ($ProjectType -eq 'benchmark' -and -not (dotnet new list 'benchmark' | Select-Object -First 1)) {
    dotnet new install 'BenchmarkDotNet.Templates'
}

if (($ProjectType -eq 'xunit' -or $ProjectType -eq 'nunit') -and (-not $ProjectName.EndsWith('.Tests'))) {
    $ProjectName = "${ProjectName}.Tests"
}

try {
    if (-not [string]::IsNullOrEmpty($ProjectName)) {
        # Checks to avoid adding a folder of the same name
        $currentDirectory = (Get-Item -Path '.')
        $folderExists = Get-ChildItem -Filter $Folder | Select-Object -First 1
        if (-not $folderExists -and $currentDirectory.Name -ne $Folder) {
            New-Item -ItemType Directory -Path $Folder -Force
            Set-Location -Path $Folder
        }

        Write-Output (dotnet new $ProjectType -o $ProjectName)

        # Check if a solution file exists, if not create one
        $solutionFile = Get-ChildItem -Path .. -Recurse -Filter *.sln | Select-Object -First 1
        if (-not $solutionFile) {
            dotnet new sln -n $ProjectName
            $solutionFile = "$ProjectName.sln"
        }

        # Add the new project to the solution
        $projectFilePath = Join-Path -Path $ProjectName -ChildPath "$ProjectName.csproj"
        dotnet sln $solutionFile.FullName add $projectFilePath

        if ($ProjectName.EndsWith('.Tests')) {
            $actualProjectName = $ProjectName.TrimEnd('.Tests')
            # Add a reference to the main project if one is found
            $mainProjectFile = Get-ChildItem -Recurse -Filter "*${actualProjectName}.csproj"
            if (($mainProjectFile | Select-Object -First 1)) {
                Set-Location -Path $actualProjectName
                $testProjectFilePath = "../${ProjectName}/${ProjectName}.csproj"
                dotnet add reference $testProjectFilePath
                Set-Location -Path ..
            }
        }
    } else {
        Write-Output (dotnet new $ProjectType)
    }
    
    if (-not $Packages -eq $null) {
        foreach ($package in $Packages) {
            Write-Output (dotnet add package $package)
        }
    }

    # Output message
    Write-Output "$ProjectName $ProjectType project created successfully."
} catch {
    Write-Error "Failed to create new .NET project: $_"
}