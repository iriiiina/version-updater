#!/bin/bash

#####################################################################################################
### This is script for getting modules' versions from stable environment for batch update         ###
### List of modules, $host and $env should be modified according to the environment               ###
### File can be downloaded from HG repo:                                                          ###
###    http://ehealth.webmedia.ee/scripts/version-updater/get-stable-versions.sh                  ###
###                                                                                               ###
### Author: Irina.Ivanova@nortal.com                                                              ###
### Last modified: 4.02.2016, v1.0                                                                ###
### Version-updater manual: https://confluence.nortal.com/display/support/Version-updater+Script  ###
#####################################################################################################

# Colors for output
NONE='\e[0m'
RED='\e[31m'
GREEN='\e[32m'
CYAN='\e[36m'

# File used by version-updater for batch update (global variable $batch in conf.sh)
file="batch-modules.txt"

# NB! order in the modules array is important - it defines in which order modules will be propagated
# Right order can be found in version tracker: http://ehealthtest.webmedia.int:7070/versiontracker/
modules=(
	'authentication'
	'authorization'
	'system'
	'person'
	'admin'
	'integration'
	'integration-lt'
	'docman'
	'billing'
	'diet'
	'reception'
	'schedule'
	'treatment'
	'diagnostics'
	'register'
	'ui'
	'clinician-portal'
	)

# Host of the stable environment, where from you want to download versions
# Example: "http://ehealthtest.webmedia.int:7070"
host=""

# Environment name, which is usually prefix for the modules
# Example: "predemo"
env=""


function printError() {
  echo -e "${RED}ERROR: $1${NONE}"
}

function printRed() {
  echo -e "${RED}$1${NONE}"
}

function printOk() {
  echo -e "${GREEN}OK: $1${NONE}"
}

function printInfo() {
  echo -e "${CYAN}$1...${NONE}"
}

function emptyFile() {
  printInfo "Removing old content from $file";
  echo "" > $file
  printOk "old content from $file is removed";
}

function findVersion() {
  for module in ${modules[@]}; do
    printInfo "Finding version of $module";
    if [[ $module == "clinician-portal" ]]; then
      url="$host/$env/sysInfo"
      version=$(curl -k $url | grep -A 3 '<td class="info">module.version</td>' | grep -o --regexp='[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*')
    elif [[ $module == "ui" ]]; then
      url="$host/$env-$module/sysInfo.json"
      version=$(curl -k $url | grep -o --regexp='[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*')
    else
      url="$host/$env-$module/sysInfo"
      version=$(curl -k $url | grep -A 3 '<td class="info">module.version</td>' | grep -o --regexp='[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*')
    fi

  addLine;
  done
}

function addLine() {
  if [[ $version == "" ]]; then
      printError "can't find version for $module: $url";
      errors+=($module)
    else
      printOk "version for $module is found: $version";
      echo "$module $version" >> $file
    fi
}

function removeBlankLine() {
  sed -i '1d' ./$file
}

function printErrors() {
  if [[ ${#errors[*]} -gt 0 ]]; then
    echo -e "\n\n"
    printRed "CAN'T FIND VERSIONS FOR ${#errors[*]} MODULES";
    for item in ${errors[*]}
    do
      echo -e "\t\t\t${RED}$item${NONE}"
    done
  else
    echo -e "\n\n"
    printOk "versions for all modules are found and saved in $file\n\n";
  fi
}

emptyFile;
findVersion;
removeBlankLine;
printErrors;
