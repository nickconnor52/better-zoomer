#!/bin/bash

usage() {
    echo "Usage: $0 -u <URL>"
    exit 1
}

# Parse command line options
while getopts ":u:" opt; do
    case $opt in
        u)
            url="$OPTARG"
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            usage
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            usage
            ;;
    esac
done

# Check if URL is provided
if [ -z "$url" ]; then
    echo "URL is required."
    usage
fi


is_integer() {
    if [[ "$1" =~ ^[0-9]+$ ]]; then
      return 0
    else
      return 1
    fi
}

response="$(expect -c "
  spawn dezoomify-rs {$url}
  expect {Which level do you want to download?}
  exit 1
")"

highest_number=0

while read -r line; do
  number=$(echo "$line" | grep -o '^[0-9]\+')
  valid_number= is_integer "$number"

  if [ $is_integer "$number" ]; then
      highest_number="$number"
  fi
done <<< "$response"

if [ $highest_number -eq 0 ]; then
  echo "No valid number found"
  exit 1
fi

/usr/bin/expect -c "
  spawn dezoomify-rs {$url}
  expect -re {Which level do you want to download?}
  send -- "$highest_number\\r"
  expect -re {Image successfully saved to}
  exit 1
"
