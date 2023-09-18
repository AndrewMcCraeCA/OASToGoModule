#!/bin/bash

# Check if three arguments are provided
if [ $# -ne 3 ]; then
  echo "Error: Three arguments are required!"
  echo "Usage: $0 <openAPI_file_path> <github_username> <module_name>"
  exit 1
fi


# the arguments to the script
openAPI_file_path=$1 #Path to openapi file
github_username=$2 #Your github username
module_name=$3 #New go module name

if [[ ! "$module_name" =~ ^[a-z]+$ ]]; then
    echo "Error: The module name $module_name entered was invalid."
    echo "go module names are supposed to be lowercase."
    exit 1
fi
# Echo the value of the variables
echo "Path to openapi file : $openAPI_file_path"
echo "Your github username: $github_username"
echo "New go module name: $module_name"

echo "Generating the new client module..."

#  openapi-generator-cli generate - Generate code with the specified generator.
# -g <generator name>, --generator-name <generator name> \ generator to use (see list command for list)
# --git-repo-id <git repo id> \ Git repo ID, e.g. openapi-generator.
# --git-user-id <git user id> \Git user ID, e.g. openapitools.
# -i <spec file>, --input-spec <spec file> \ location of the OpenAPI spec, as URL or file (required if not loaded via config using -c)
# -o <output directory>, --output <output directory> \ where to write the generated files (current dir by default)
# --package-name <package name> \ package for generated classes (where supported)

openapi-generator generate \
  -g go \
  --git-repo-id $module_name \
  --git-user-id $github_username -i $openAPI_file_path \
  -o $module_name \
  --package-name $module_name

echo "..."
echo "Created new Go module: github.com/$github_username/$module_name in folder $PWD/$module_name"
