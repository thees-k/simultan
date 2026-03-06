#!/usr/bin/env bash

#
# Script to execute a command simultaneously on all files of a specific type,
# optionally searching up to a certain directory depth.
#
# Usage:
#   simultan.sh [ -d <maxdepth> ] <suffix> <command> [args...]
#
# Example:
#   simultan.sh wav lame --silent --preset insane
#   ("wav" is the suffix, "lame" is the command and "--silent --preset insane" its arguments)
#
#  .. with searching up to 3 directories deep:
#   simultan.sh -d 3 wav lame --silent --preset insane
#

script_name=$(basename "$0")

# Default maxdepth
maxdepth=1

# Parse optional -d flag
while getopts ":d:" opt; do
  case $opt in
    d)
      maxdepth="$OPTARG"
      # Validate maxdepth is numeric
      [[ "$maxdepth" =~ ^[0-9]+$ ]] || { echo "Error: -d must be a numeric value"; exit 1; }
      [ "$maxdepth" -lt 1 ] && { echo "Error: -d must be greater than 0"; exit 1; }
     ;;
    :)
      echo "Error: Option -$OPTARG requires an argument." >&2
      exit 1

      ;;
    \?)
      echo "Usage: $script_name [ -d <maxdepth> ] <suffix> <command> [args...]"
      exit 1
      ;;
  esac
done

# Shift off the options and the option arguments processed by getopts
shift $((OPTIND - 1))

# We need at least 2 arguments left: <suffix> <command>
[ "$#" -lt 2 ] && { echo "Usage: $script_name [ -d <maxdepth> ] <suffix> <command> [args...]"; exit 1; }

# 1) Suffix (strip a leading dot or "*." if present)
suffix="${1#*.}"
shift

# Check for non-empty suffix
[ -z "$suffix" ] && { echo "Error: Suffix cannot be empty"; exit 1; }

# 2) The command to run
cmd="$1"
shift

# Check for non-empty cmd
[ -z "$cmd" ] && { echo "Error: Command cannot be empty"; exit 1; }

# Check if command is available
! command -v "$cmd" &>/dev/null && { echo "Command $cmd could not be located." ; exit 1; }

# Check whether there are any files at all matching this suffix up to the chosen depth
count="$(find . -maxdepth "$maxdepth" -type f -iname "*.$suffix" | wc -l)"
[ "$count" -eq 0 ] && { echo "No .$suffix files found in directory depth $maxdepth."; exit 1; }

# Determine the number of jobs
if command -v nproc >/dev/null 2>&1; then
  JOBS="$(nproc)" # nproc returns the number of processing units available, the number of logical cpus
elif command -v getconf >/dev/null 2>&1; then
  JOBS="$(getconf _NPROCESSORS_ONLN)"
elif [[ "$(uname -s)" == "Darwin" ]]; then
  JOBS="$(sysctl -n hw.ncpu)" # MacOS alternative
else
  JOBS=1
fi

if ! [[ "$JOBS" =~ ^[0-9]+$ ]] || [[ "$JOBS" -lt 1 ]]; then # if JOBS is not positive integer, set it to 1  
  JOBS=1
fi

# Execute command in parallel for each file
find . -maxdepth "$maxdepth" -type f -iname "*.$suffix" -print0 | xargs -0 -n 1 -P "$JOBS" -- "$cmd" "$@"

