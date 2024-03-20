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

$download_prompt

# CLOSE
# # Function to print script usage

# # Function to check if a variable is an integer
# is_integer() {
#     if [[ "$1" =~ ^[0-9]+$ ]]; then
#       return 0
#     else
#       return 1
#     fi
# }

# echo "Calling dezoomify-rs with URL: $url"
# # options=$(dezoomify-rs $url)

# highest_number=0

# while IFS= read -r line; do
#   echo "Line: $line"
#   number=$(echo "$line" | grep -o '^[0-9]\+')
#   valid_number= is_integer "$number"

#   if [ $is_integer "$number" ]; then
#       highest_number="$number"
#   fi
# done <<< "$(dezoomify-rs $url)"



# last_option() {
#   highest_number=0

#   while read -r line; do
#     number=$(echo "$line" | grep -o '^[0-9]\+')
#     valid_number= is_integer "$number"

#     if [ $is_integer "$number" ]; then
#         highest_number="$number"
#     fi
#   done <<< "$1"

#   return $highest_number
# }

# # Print the highest number
# echo "The highest number is: $(last_option "$options")"
