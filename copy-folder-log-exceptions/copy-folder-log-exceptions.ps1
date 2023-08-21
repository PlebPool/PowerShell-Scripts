param(
    [string]$source,
    [string]$dest
)

$files = Get-ChildItem $source -Recurse
$srcItem = Get-Item $source
$dstItem = (Get-Item $dest).FullName + $srcItem.BaseName + "\"

$totalFilesCount = $files.Count
$i = 0

foreach ($file in $files) {
    $i++
    $percentComplete = ($i / $totalFilesCount) * 100
    Write-Progress -Activity "Copying files..." -Status "Copying file $i of $totalFilesCount" -PercentComplete $percentComplete

    $currentDest = $file.FullName.Replace($srcItem, $dstItem)

    try 
    {
        Copy-Item $file.FullName $currentDest -ErrorAction Continue -ErrorVariable errors -Verbose
    } 
    catch 
    {
        if ( $error ) {
            $error[0] | Out-File "$dest\ErrorLog.txt" -Append
        }
    }
}

