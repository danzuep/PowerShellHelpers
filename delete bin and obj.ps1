$foldersToDelete = @('*/bin/', '*/obj/', '*/.vs', './*/packages/')
Write-Output "Deleting folders: " | %{$_ + $foldersToDelete}
Remove-Item $foldersToDelete -Recurse -Force -ErrorAction SilentlyContinue
pause

# Get-ChildItem -Path '.' -Recurse -Directory -Include bin, obj | Remove-Item -Recurse -Force