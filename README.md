# Motivation
[Dropbox-Exclude](https://github.com/kavehtehrani/dropbox-exclude), from which this repository is forked, provides a very neat tool to exclude folders from Dropbox syncing. It is a bash shell script and cannot be used on Windows directly. 

Here is a Simple Powershell Script for Windows, using [command suggested by Dropbox](https://help.dropbox.com/sync/ignored-files).

```bash
# Define the Dropbox folder path
$dropboxPath = "path\to\your\dropbox"

# Get all files and directories starting with a dot recursively
# Change the Filter to whatever your like "_*". See PowerShell Documentation for details and more options.
$dotFiles = Get-ChildItem -Path $dropboxPath -Recurse -File -Filter ".*"

# To get directories:
# $dotFiles = Get-ChildItem -Path $dropboxPath -Recurse -Directory -Filter ".*"

# or both files and directories
$dotFiles = Get-ChildItem -Path $dropboxPath -Recurse -Force | Where-Object { $_.Name -like ".*" }

# Using the approach suggested by Dropbox to ingore the file or folder
foreach ($file in $dotFiles) {
    try {
           # Just show the information of the file 
           Write-Host "Ignore $($file.name) by Dropbox: $($file.FullName)"
           Set-Content -Path $($file.FullName) -Stream com.dropbox.ignored -Value 1
    } catch {
        Write-Warning "Failed to process $($file.FullName): $_"
    }
}
```
