#!/usr/bin/env bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NOCOLOR='\033[0m'

# -m -- alias
# -t -- token
# -c -- cores
# -i -- ignore cores
# -a -- avx2
# -v -- version
# -h -- help
options=":m:t:c:i:av:h"

# Functions

get_miner_name() {
    local miner_name=$alias

    echo "$miner_name"
}

get_distributor_id() {
    local disctributor_id="ubuntu"
    #local disctributor_id=$(lsb_release -ds | grep -o "^\w*\b" | tr "[:upper:]" "[:lower:]")
    echo "$disctributor_id"
}

# Return the maximum number of cores
get_max_cores() {
  echo $(nproc --ignore=$1)
}

help() {
  echo "
-m            alias
-t            Token
-c (optional) Number of cores in use. Used in place of the -i flag
-i (optional) Ignored number of cores out of the maximum possible on the machine. Used in place of the -c flag
-a (optional) Use avx2. If the flag is not specified, it will use avx512
-v (optional) If you need a specific version, you can specify it. For example 1.3.9"

}

validate_options() {
  if [ -z "$token" ]; then
    echo -e "${RED}The token has not been set. Use the -t flag to set the token${NOCOLOR}"
    exit
  fi
}

validate_version() {
  if [ -n "$version" ]; then
    if [[ $(validate_url "https://dl.qubic.li/downloads/qli-Client-$version-Linux-x64.tar.gz") -eq false ]]; then
      echo -e "${RED}Could not find a miner with the version: $version${NOCOLOR}"
      exit
    fi
  fi
  
  echo "1"
}

function validate_url(){
  if [[ `wget -S --spider $1  2>&1 | grep 'HTTP/1.1 200 OK'` ]]; then echo "1"; else echo "0"; fi
}

display_miner_info() {
  echo -e "${GREEN}Miner name: ${miner_name}${NOCOLOR}"
  echo -e "${GREEN}Token: $token${NOCOLOR}"
  echo -e "${GREEN}Cores: $cores${NOCOLOR}"
  echo -e "${GREEN}Avx2: $use_avx2${NOCOLOR}"
  if [ -n "$version" ]; then
    echo -e "${GREEN}Version: $version${NOCOLOR}"
  else
    echo -e "${GREEN}Version: latest${NOCOLOR}"
  fi
}

#Arguments

ignore_cores=0
use_avx2=0

# If no arguments are passed, then print help and close the script
if [ $# -lt 1 ]
then
  help
  exit
fi

while getopts $options option;  do
  case $option in
    # alias
    m)
      alias=$OPTARG
      ;;
    # Core
    c)
      cores=$OPTARG
      ;;
    # Toke
    t)
      token=$OPTARG
      ;;
    # Ignore cores
    i)
      ignore_cores=$OPTARG
      ;;
    # Avx2
    a)
      use_avx2=1
      ;;
    # Version
    v)
      version=$OPTARG
      ;;
    # Help
    h)
      help
      exit;;
    # Bad option
    \?)
      help 
      exit;;
  esac
done

validate_options
validate_version

if [ -z "$cores" ]; then
  cores=$(get_max_cores $ignore_cores)
fi

miner_name=$(get_miner_name $cores)

display_miner_info

# Variables

branch="main"
scripts_folder_name="scripts"
package_installer_file_postfix="-package-installer.sh"
package_installer_raw_file_url="https://raw.githubusercontent.com/Qubic-World/qubicli-miner-installer/$branch/$scripts_folder_name/$(get_distributor_id)$package_installer_file_postfix"

executableName=qli-Client
settingsFile="appsettings.json"

# Installing the required packages depending on the Distributor ID

status=$(validate_url $package_installer_raw_file_url)

if [ "$status" -eq 0 ]; then
  echo -e "${RED}Could not find package installer for Distibutor Id: $(get_distributor_id) at link: $package_installer_raw_file_url${NOCOLOR}"
  exit
fi

echo -e "${GREEN}Installing the required packages${NOCOLOR}"
curl $package_installer_raw_file_url | bash

# Install client
package=qli-Client-$version-Linux-x64.tar.gz
# remove lock files
rm ./*.lock
# remove existing solutions
rm ./*.e*
# remove existing runners/flags
[ -f "qli-runner" ] && rm qli-runner
[ -f "qli-processor" ] && rm qli-processor
# remove installation file
[ -f "$package" ] && rm $package
# download client
wget -4 -O $package https://dl.qubic.li/downloads/$package
tar -xzvf $package
rm $package
rm $settingsFile
# config file
if [ ${#token} -ge 61 ]; then
  echo "{\"Settings\":{\"baseUrl\": \"https://mine.qubic.li/\",\"amountOfThreads\": $cores,\"alias\": \"$alias\",\"accessToken\": \"$token\", \"autoupdateEnabled\": false}}" > $settingsFile;
else
  echo "{\"Settings\":{\"baseUrl\": \"https://mine.qubic.li/\",\"amountOfThreads\": $cores,\"alias\": \"$alias\",\"accessToken\": null,\"payoutId\": \"$token\", \"autoupdateEnabled\": false}}" > $path/$settingsFile;
fi

# run client
./qli-Client
