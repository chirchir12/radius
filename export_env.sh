#!/bin/bash

# Read the .env file and export each variable
while IFS='=' read -r key value
do
  # Trim leading and trailing whitespace
  key=$(echo $key | xargs)
  value=$(echo $value | xargs)
  
  # Ignore comments and export non-empty variables
  if [[ ! "$key" =~ ^#.* ]] && [ ! -z "$key" ]; then
    export "$key=$value"
    echo "Exported: $key=$value"
  fi
done < .env

