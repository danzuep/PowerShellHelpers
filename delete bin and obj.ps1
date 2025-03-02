$foldersToDelete = @('bin', 'obj', '.vs', 'packages')
$foldersToDelete | ForEach-Object {
    Write-Output "Searching for '$_' folders..."
    Get-ChildItem -Path '.' -Recurse -Directory -Filter $_ -Force | ForEach-Object {
        Write-Output "Deleting folder: $($_.FullName)"
        Remove-Item -Path $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
    }
}
pause

# @('bin','obj') | %{ gci -r -di -fi $_ | rm -r -fo }
# @('bin','obj') | ForEach-Object { Remove-Item $_ -Recurse -Force -ErrorAction SilentlyContinue }
# @('bin','obj') | ForEach-Object { Get-ChildItem -Recurse -Directory -Filter $_ -Force | ForEach-Object { Write-Host "Deleting folder: $($_.FullName)"; Remove-Item $($_.FullName) -Recurse -Force -ErrorAction SilentlyContinue } }; dotnet nuget locals all --clear