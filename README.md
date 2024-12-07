# Motivation

I code a lot in my dropbox folder to keep them synced across my devices (before git commits are viable) and unfortunately dropbox does not include an automatic way to exclude syncs. Each "node_modules" or "debug" folder contains potentially thousands of small files and syncing them is a waste of time and disk space. What's worse, dropbox falters when there are many thousand small files to sync and ends up halting (see [here](https://www.dropboxforum.com/discussions/101001012/syncing-is-stuck-on-my-linux-devices-what-can-i-do/391587)), at least on linux distros I am using.

I wrote this script to help me exclude directories from syncing. I have set up a job in cron to run every 5 minute and exclude pesky large folders that should not be synced in the first place.

Ideally this script should be implemented by dropbox itself as a feature similiar to how a ".gitignore" file works. I opened an issue on dropbox forums and seems like someone already requested this a [full 10 YEARS ago!](https://www.dropboxforum.com/discussions/101001014/add--dropboxignore-to-automatically-ignore-filesfolders-when-syncing-/811894) In the meantime, this is what we got.

# Dropbox Directory Excluder

A bash script to easily exclude directories from Dropbox sync using pattern matching. This tool works with the Dropbox CLI to help you manage which directories should be excluded from syncing.

## Installation

You can install manually, or use the following commands to download and make the script executable:

```bash
curl -o dropbox-exclude.sh https://raw.githubusercontent.com/kavehtehrani/dropbox-exclude/master/dropbox-exclude.sh
chmod +x dropbox-exclude.sh
```

## Prerequisites

- Dropbox desktop client installed
- Dropbox CLI accessible in your path
- Bash shell

Note: I have only tested this on linux. Should work on MacOS as well. Windows, well I don't think you would be reading this if that were the case.

## Usage

```bash
./dropbox-exclude.sh --pattern <glob-pattern> [--recent <minutes> | --ever] [--y]
```

### Options

- `--pattern <pattern>`: (Required) Glob pattern to match directories (e.g., "node\_\*")
- `--recent <minutes>`: Only search directories modified in the last n minutes
- `--ever`: Search all directories (default)
- `--y`: Proceed without confirmation
- `--remove`: Remove matching directories from exclusion list (so that they resync)

### Examples

Exclude all node_modules directories:

```bash
./dropbox-exclude.sh --pattern "node_modules"
```

Exclude recently modified build directories (last hour):

```bash
./dropbox-exclude.sh --pattern "*build*" --recent 60
```

Exclude all dist folders without confirmation:

```bash
./dropbox-exclude.sh --pattern "*dist*" --ever --y
```

Remove all previously excluded node_modules directories from exclusion list:

```bash
./dropbox-exclude.sh --pattern "node_modules" --remove
```

I personally use this script in a cron job to run every 5 minutes as:

```bash
*/5 * * * * ~/Dropbox/.dropbox-ignore.sh --recent 5 --pattern "node_modules" --y
```

## How It Works

1. The script searches your Dropbox directory for folders matching your specified pattern
2. It can either search all directories or only recently modified ones
3. Shows you a preview of directories that will be excluded
4. Asks for confirmation (unless --y flag is used)
5. Uses the `dropbox exclude add` command to exclude each matching directory
6. Finally displays the current exclusion list

## Safety Features

- Requires explicit pattern specification
- Shows preview before executing
- Requires confirmation unless auto-confirm flag is used
- Rerunning the script will not duplicate exclusions

## Note

This script uses the Dropbox CLI's exclude command. Make sure you have the Dropbox command line interface properly installed and working before using this script.

You can always check your current exclusion list by running `dropbox exclude list` in your terminal.

Happy to receive feedback and contributions!
