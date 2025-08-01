# Powershell Script for Dropbox-Ingore

[dropbox-exclude](https://github.com/kavehtehrani/dropbox-exclude), from which this repository is forked, provides a very neat tool to exclude folders from Dropbox syncing. It is a bash shell script and cannot be used on Windows directly. 

Here is a simple Powershell script for Windows, using [command suggested by Dropbox](https://help.dropbox.com/sync/ignored-files). Unlike `selective sync`, ignored files will stay on the local computers and will not be synced either direction. By contrast, files excluded by `selective sync` will be online only and the local files will disappear.

```bash
# Define the Dropbox folder path
$dropboxPath = "path\to\your\dropbox"


# Get all files and directories starting with a dot recursively
# Change the Filter to whatever your like.
# See PowerShell Documentation for details and more options.

# to get all files in the $dropboxPath
#$dotFiles = Get-ChildItem -Path $dropboxPath -Recurse -File -Filter ".*"

# To get directories staring with .Rproj:
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

A more powerful and universal tool based on Python is [dot-dropbox-ignore](https://github.com/iansedano/dot-dropbox-ignore).

Soon, hopefullu, we will not need these hacks as Dropbox is officially [testing a solution for ignore](https://www.dropboxforum.com/discussions/101007CC1/cut-the-clutter-test-ignore-files-feature-sign-up-to-become-a-beta-tester/840056). 
