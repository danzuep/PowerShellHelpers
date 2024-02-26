$foldersToDelete = @('*/bin/', '*/obj/', '*/.vs', './*/packages/')
Write-Output "Deleting folders: " | %{$_ + $foldersToDelete}
Remove-Item $foldersToDelete -Recurse -Force -ErrorAction SilentlyContinue
pause