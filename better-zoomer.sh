#!/bin/bash

usage() {
    echo "Usage: $0 -u <URL>, -f <RELATIVE_CSV_LOCATION>"
    echo "  -u: URL of the image to download"
    echo "  -f: relative location of the CSV file containing URLs to be downloaded, one URL per line"
    exit 1
}

while getopts 'u:f:' flag; do
  case "${flag}" in
    u) url="${OPTARG}" ;;
    f) file="${OPTARG}" ;;
    *) print_usage
       exit 1 ;;
  esac
done


# # Check if URL is provided
if [ -z "$url" ] && [ -z "$file" ]; then
    echo "URL or File location is required."
    usage
fi


is_integer() {
    if [[ "$1" =~ ^[0-9]+$ ]]; then
      return 0
    else
      return 1
    fi
}

download_image_by_url() {
  url="$1"

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

  return 0
}

urls=()

if [ -n "$url" ]; then
  urls+=("$url")
elif [ -n "$file" ]; then
  while read -r line; do
    urls+=("$line")
  done < "$file"
fi

for line in "${urls[@]}"; do
  download_image_by_url "$line"
done
