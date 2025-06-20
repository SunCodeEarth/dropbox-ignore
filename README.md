# Powershell Script for Dropbox-Ingore

[dropbox-exclude](https://github.com/kavehtehrani/dropbox-exclude), from which this repository is forked, provides a very neat tool to exclude folders from Dropbox syncing. It is a bash shell script and cannot be used on Windows directly. 

Here is a simple Powershell script for Windows, using [command suggested by Dropbox](https://help.dropbox.com/sync/ignored-files). Unlike `selective sync`, ignored files will stay on the local computers and will not be synced either direction. 

```bash
# Define the Dropbox folder path
$dropboxPath = "path\to\your\dropbox"


# Get all files and directories starting with a dot recursively
# Change the Filter to whatever your like "_*". See PowerShell Documentation for details and more options.

# to get files
#$dotFiles = Get-ChildItem -Path $dropboxPath -Recurse -File -Filter ".*"

# To get directories:
#$dotFiles = Get-ChildItem -Path $dropboxPath -Recurse -Directory -Filter ".Rproj*"

# or both files and directories
$dotFiles = Get-ChildItem -Path $dropboxPath -Recurse -Force -ErrorAction SilentlyContinue | Where-Object { $_.Name -like ".Rproj*" }

# both files and directories that start with . or _
#$dotFiles = Get-ChildItem -Path $dropboxPath -Recurse -Force -ErrorAction SilentlyContinue | Where-Object { $_.Name -like ".*" -or $_.Name -like "_*" }

if ($dotFiles.Count -gt 0) {
    foreach ($file in $dotFiles) {
        try {
            Write-Host "To Ignore $($file.name) by Dropbox: '$($file.FullName)'"
            Set-Content -Path $($file.FullName) -Stream com.dropbox.ignored -Value 1
        } catch {
            Write-Warning "Failed to process $($file.FullName): $_"
        }
    }
}
```
