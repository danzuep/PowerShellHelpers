# General Software
winget install Notepad++.Notepad++
winget install 7zip.7zip
winget install Google.Chrome
winget install Mozilla.Firefox
winget install Microsoft.PowerShell

# Development Tools
winget install OpenSSH
winget install Git.Git
winget install PuTTY.PuTTY
winget install Python.Python.3.9
winget install MongoDB.Compass.Full
winget install Docker.DockerDesktop
#Add-LocalGroupMember -Group docker-users -member ((Get-WMIObject -class Win32_ComputerSystem | Select-Object -ExpandProperty username))
Add-LocalGroupMember -Group docker-users -member ([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)
winget install Insomnia.Insomnia
winget install Microsoft.VisualStudioCode
winget install -e --id Microsoft.AzureDataStudio

# ~15GB means download and install takes a very long time. https://docs.microsoft.com/en-us/visualstudio/install/workload-component-id-vs-professional?view=vs-2022
winget install Microsoft.VisualStudio.2022.Professional --silent --override "--wait --quiet --add Microsoft.VisualStudio.Workload.NetWeb --add Microsoft.VisualStudio.Workload.ManagedDesktop --includeRecommended --includeOptional"

#dotnet tool install --global GitVersion.Tool --version 5.*;
$env:PATH += ";$($env:UserProfile)\appdata\local\programs\Git\bin";
New-Item -Path 'C:\Source' -ItemType Directory;
git clone https://github.com/Company/Project.git C:\Source\Project;

#Get-ChildItem -include bin,obj,.git,.vs,packages -recu -Force | remove-item -force -recurse
#%userprofile%\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadline\ConsoleHost_history.txt
