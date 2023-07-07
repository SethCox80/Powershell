Get-Process |
Where-Object status -eq "Running" |
ConvertTo-Html |
Out-File C:\Temp\stats.htm 