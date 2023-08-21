Clear-Host
$deletedSomething = $false
exit
Get-ChildItem "C:\Users\$env:UserName\Downloads" | 
ForEach-Object {
    $fileAgeDays = ((Get-Date) - $_.LastWriteTime).TotalDays
    $fileName = $_.BaseName + $_.Extension;

    if ( $fileAgeDays -ge 7 ) {
        Remove-Item $_.FullName
        if ( $? ) {
            if ( !$deletedSomething ) {
                $deletedSomething = $true
            }
            Write-Host "Successfully deleted $fileName..."
        } else {
            Write-Host "ERROR deleting $fileName..."
        }
    }
}

if ( !$deletedSomething ) {
    Write-Host "Nothing was deleted..."
}
