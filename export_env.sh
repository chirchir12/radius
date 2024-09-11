#!/bin/bash

# Read the .env file and export each variable
while IFS='=' read -r key value
do
  # Trim leading and trailing whitespace
  key=$(echo $key | xargs)
  value=$(echo $value | xargs)
  
  # Export the variable if it's not empty
  if [ ! -z "$key" ]; then
    export "$key=$value"
  fi
done < .env
