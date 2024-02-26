# $webClient = new-object System.Net.WebClient
# $webClient.DownloadFile("https://example.com/get-file/file.csv","C:\Temp\file.csv")

Function Get-Folder($initialDirectory="")
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")|Out-Null

    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $foldername.Description = "Select a folder"
    $foldername.rootfolder = "MyComputer"
    $foldername.SelectedPath = $initialDirectory

    if($foldername.ShowDialog() -eq "OK")
    {
        $folder += $foldername.SelectedPath
    }
    return $folder
}

# Add timestamp to fileName for a given filePath
Function AddTimestampToFilePath([string]$filePath="C:\Temp\file.csv")
{
    $directory = [System.IO.Path]::GetDirectoryName($filePath);
    $strippedFileName = [System.IO.Path]::GetFileNameWithoutExtension($filePath);
    $extension = [System.IO.Path]::GetExtension($filePath);
    $timestamp = Get-Date -format 'yyyy-MM-dd';
    $newFileName = $strippedFileName + "_" + $timestamp + $extension;
    $newFilePath = [System.IO.Path]::Combine($directory, $newFileName);
    
    Write-Host "Original file name: $filePath";
    Write-Host "File name with timestamp: $newFilePath";

    Move-Item -LiteralPath $filePath -Destination $newFilePath;
}

$folder = "C:\Temp\Rename\";
#$folderPath = Get-Folder($folder);
$files = Get-ChildItem -Path $folder;
foreach ($file in $files)
{
    $filePath = [System.IO.Path]::Combine($folder, $file);
    AddTimestampToFilePath($filePath);
}