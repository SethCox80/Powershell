function Test-ValidFileName
{
    param([string]$FileName)

    $IndexOfInvalidChar = $FileName.IndexOfAny([System.IO.Path]::GetInvalidFileNameChars())

    # IndexOfAny() returns the value -1 to indicate no such character was found
    return $IndexOfInvalidChar -eq -1
}

$filename = Read-Host "Enter a folder name to create"
if(Test-ValidFileName $filename)
    {
        Write-Host "$filename is valid"
        mkdir -Path .\$filename
    }
    else
    {
        Write-Host "$filename contains invalid characters"
    }
