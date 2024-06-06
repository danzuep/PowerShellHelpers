## PCSetup 

### Install Visual Studio 2022 Professional with WinGet

(~15GB means download and install takes a very long time. https://docs.microsoft.com/en-us/visualstudio/install/workload-component-id-vs-professional?view=vs-2022)
`winget install Microsoft.VisualStudio.2022.Professional --silent --override "--wait --quiet --add Microsoft.VisualStudio.Workload.NetWeb --add Microsoft.VisualStudio.Workload.ManagedDesktop --includeRecommended --includeOptional"`

### Install Visual Studio 2022 Professional from local file

```ps
# Set the path to the Visual Studio installer file
$installerPath = "C:\Path\To\vs_professional.exe"

# Check if the installer file exists
if (Test-Path $installerPath) {
    # Build the command line arguments
    $arguments = "/silent /norestart /wait /quiet /add Microsoft.VisualStudio.Workload.NetWeb /add Microsoft.VisualStudio.Workload.ManagedDesktop /includeRecommended /includeOptional"

    # Start the installation process
    Start-Process -FilePath $installerPath -ArgumentList $arguments -Wait

    Write-Host "Visual Studio 2022 Professional installation completed."
}
else {
    Write-Host "Visual Studio installer file not found at $installerPath"
}
```
