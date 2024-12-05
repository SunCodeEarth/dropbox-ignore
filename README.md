# Dropbox Directory Excluder

A bash script to easily exclude directories from Dropbox sync using pattern matching. This tool works with the Dropbox CLI to help you manage which directories should be excluded from syncing.

## Prerequisites

- Dropbox desktop client installed
- Dropbox CLI accessible in your path
- Bash shell

## Usage

```bash
./dropbox-exclude.sh --pattern <glob-pattern> [--recent <minutes> | --ever] [--y]
```

### Options

- `--pattern <pattern>`: (Required) Glob pattern to match directories (e.g., "node\_\*")
- `--recent <minutes>`: Only search directories modified in the last n minutes
- `--ever`: Search all directories (default)
- `--y`: Proceed without confirmation

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
- Lists all excluded directories after completion

## Note

This script uses the Dropbox CLI's exclude command. Make sure you have the Dropbox command line interface properly installed and working before using this script.
