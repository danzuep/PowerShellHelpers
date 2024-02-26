# git clone https://github.com/Company/Project.git C:\Source\Project;
# Get-ChildItem -include bin,obj,.git,.vs,packages -recu -Force | remove-item -force -recurse
# %userprofile%\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadline\ConsoleHost_history.txt
# ```bash find . -type f | wc -l # number of files ```

# https://github.com/dotnet/blazor-samples/tree/main/8.0/BlazorSample_BlazorWebApp/Components

$org = "dotnet"
$repo = "blazor-samples"
$gitRepo = "https://github.com/${org}/${repo}/"
$gitBranch = "main"
$sparseFolder = "8.0"
$local = "C:\Source\GitHub\"

cd $local

# git clone --no-checkout $gitRepo
# cd $repo
# git sparse-checkout init --cone
# git sparse-checkout set $sparseFolder
# # git checkout $gitBranch

git clone --filter=blob:none --no-checkout $gitRepo
cd $repo
git sparse-checkout set --cone
git checkout $gitBranch
git sparse-checkout set $sparseFolder
