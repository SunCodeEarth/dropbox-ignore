#!/bin/bash

# Set Dropbox directory
DROPBOX_DIR="$HOME/Dropbox"
SEARCH_MODE="ever"
MINUTES=0
AUTO_CONFIRM=false
REMOVE_MODE=false
PATTERN="*"  # Default pattern

# Function to show usage
show_usage() {
    echo "Usage: $0 --pattern <glob-pattern> [--recent <minutes> | --ever | --remove] [--y]"
    echo "  --pattern <pattern> : Glob pattern to match directories (e.g. \"node_*\")"
    echo "  --recent <minutes>  : Only search directories modified in the last n minutes"
    echo "  --ever             : Search all directories (default)"
    echo "  --remove           : Remove directories from the exclusion list that match the pattern"
    echo "  --y                : Proceed without confirmation"
    echo "Example: $0 --pattern \"*sync*\" --remove --y"
    exit 1
}

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --pattern)
            PATTERN="$2"
            shift 2
            ;;
        --recent)
            if ! [[ $2 =~ ^[0-9]+$ ]]; then
                echo "Error: Minutes must be a number"
                show_usage
            fi
            SEARCH_MODE="recent"
            MINUTES="$2"
            shift 2
            ;;
        --ever)
            SEARCH_MODE="ever"
            shift
            ;;
        --remove)
            REMOVE_MODE=true
            shift
            ;;
        --y)
            AUTO_CONFIRM=true
            shift
            ;;
        *)
            echo "Unknown parameter: $1"
            show_usage
            ;;
    esac
done

# Check if pattern is provided
if [ "$PATTERN" = "*" ]; then
    echo "Error: Pattern must be specified using --pattern"
    show_usage
fi

# Get the current exclusion list from Dropbox
CURRENT_EXCLUSIONS=$(dropbox exclude list)
echo -e "\nCurrent exclusions:\n$CURRENT_EXCLUSIONS"

if [ "$REMOVE_MODE" = true ]; then
    # Filter directories matching the pattern from the exclusion list
    MATCHED_EXCLUSIONS=$(echo "$CURRENT_EXCLUSIONS" | grep -E "$PATTERN")

    if [ -z "$MATCHED_EXCLUSIONS" ]; then
        echo -e "\nNo matching exclusions found for pattern '$PATTERN'."
        exit 0
    fi

    echo -e "\nThe following directories will be removed from the exclusion list:"
    echo "$MATCHED_EXCLUSIONS"

    # Count the number of directories to be removed
    DIR_COUNT=$(echo "$MATCHED_EXCLUSIONS" | grep -v '^$' | wc -l)

    # Ask for confirmation
    PROCEED=false
    if [ "$AUTO_CONFIRM" = true ]; then
        PROCEED=true
        echo "Proceeding automatically due to --y flag"
    else
        read -p "Do you want to proceed with removing these directories? (y/n) " -n 1 -r
        echo    # Move to a new line
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            PROCEED=true
        fi
    fi

    if [ "$PROCEED" = true ]; then
        # Remove matched directories
        echo "$MATCHED_EXCLUSIONS" | while read -r dir; do
            echo "Removing exclusion: $dir"
            dropbox exclude remove "$dir"
        done

        echo -e "\nRemoval complete. Updated exclusion list:"
        dropbox exclude list
    else
        echo "Operation cancelled."
    fi
    exit 0
fi

# Continue with the regular exclusion workflow if not in remove mode
echo "Searching for directories matching '$PATTERN' in $DROPBOX_DIR..."
if [ "$SEARCH_MODE" = "recent" ]; then
    echo "Looking for directories modified in the last $MINUTES minutes"
fi

# Construct the find command based on mode
if [ "$SEARCH_MODE" = "recent" ]; then
    FIND_CMD="find \"$DROPBOX_DIR\" -type d -mmin -${MINUTES} -name \"$PATTERN\" -print"
else
    FIND_CMD="find \"$DROPBOX_DIR\" -type d -name \"$PATTERN\" -print"
fi

# Store the results of the find command
FOUND_DIRS=$(eval $FIND_CMD | sort)  # Sort to ensure parent directories appear before subdirectories

# Filter directories to avoid redundant exclusions
FILTERED_DIRS=""
while read -r dir; do
    # Skip if parent directory is already in the exclusion list
    IS_ALREADY_EXCLUDED=false
    current_dir="$dir"
    while [ "$current_dir" != "$DROPBOX_DIR" ]; do
        if echo "$CURRENT_EXCLUSIONS" | grep -qx "$current_dir" || echo "$FILTERED_DIRS" | grep -qx "$current_dir"; then
            IS_ALREADY_EXCLUDED=true
            break
        fi
        current_dir=$(dirname "$current_dir")
    done

    # Add to the filtered list if not excluded
    if [ "$IS_ALREADY_EXCLUDED" = false ]; then
        FILTERED_DIRS+="$dir"$'\n'
    fi
done <<< "$FOUND_DIRS"

# Remove trailing newlines
FILTERED_DIRS=$(echo "$FILTERED_DIRS" | grep -v '^$')

# Display directories to be excluded
echo -e "\nThe following directories will be excluded:"
echo "$FILTERED_DIRS"

# Count the number of directories
DIR_COUNT=$(echo "$FILTERED_DIRS" | grep -v '^$' | wc -l)

if [ "$DIR_COUNT" -eq 0 ]; then
    echo -e "\nNo matching directories found to exclude."
    exit 0
fi

# Handle confirmation
echo -e "\nFound $DIR_COUNT directory(ies) to exclude."
PROCEED=false

if [ "$AUTO_CONFIRM" = true ]; then
    PROCEED=true
    echo "Proceeding automatically due to --y flag"
else
    read -p "Do you want to proceed with excluding these directories? (y/n) " -n 1 -r
    echo    # Move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        PROCEED=true
    fi
fi

if [ "$PROCEED" = true ]; then
    # Actually exclude the directories
    echo "$FILTERED_DIRS" | while read -r dir; do
        echo "Excluding: $dir"
        dropbox exclude add "$dir"
    done

    echo -e "\nExclusion complete. Current exclusion list:"
    dropbox exclude list
else
    echo "Operation cancelled."
fi
