Function Get-FolderList {
    Get-ChildItem -Path ./ -recurse | Where-Object {$_.PSIsContainer -eq $false} | Select-Object Name, FullName, Length | Export-Csv -NoTypeInformation -Path ./Export-CSV.csv
}

Function BulkRename {
    Import-Csv -Path ./Export-CSV.csv | ForEach-Object {Rename-Item -Path $_.FullName -NewName $_.NewName}
}

Get-FolderList
