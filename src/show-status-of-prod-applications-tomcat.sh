#!/bin/bash

########################################################################################################################
### This is script for listing deployed applications on multiple-server and multiple-cluster environment (Tomcat 8)  ###
### It doesn't require modifications and can be used out-of-the-box                                                  ###
###                                                                                                                  ###
### Author: Irina Ivanova, iriiiina@gmail.com                                                                        ###
### Last modified: 4.02.2016, v2.0                                                                                   ###
### Version-updater manual:                                                                                          ###
###    https://iriiiina.gitbooks.io/version-updater-manual/content/                                                  ###
########################################################################################################################

# Import of global variables and functions
. version-updater/conf.sh
. version-updater/functions.sh

function printTitle() {
  echo -e "${GRAY}$1${NONE}"
}

for index in ${!ehealthTomcatManagers[@]}
do
  echo -e "\n\n"
  printTitle "*********EHEALTH $index*********";

  curl -silent ${ehealthTomcatManagers[$index]}/list | sort | grep ^/ | awk '{ gsub("running", "\033[32m&\033[0m"); gsub("stopped", "\033[31m&\033[0m"); gsub("\\:[0-9]+", "\033[34m&\033[0m"); gsub("^/.+:", "\033[36m&\033[0m"); gsub("[0-9]+.[0-9]+.[0-9]+.[0-9]+$", "\033[33m&\033[0m"); print }'

done

for index in ${!hisTomcatManagers[@]}
do
  echo -e "\n\n"
  printTitle "*********HIS $index*********";

  curl -silent ${hisTomcatManagers[$index]}/list | sort | grep ^/ | awk '{ gsub("running", "\033[32m&\033[0m"); gsub("stopped", "\033[31m&\033[0m"); gsub("\\:[0-9]+", "\033[34m&\033[0m"); gsub("^/.+:", "\033[36m&\033[0m"); gsub("[0-9]+.[0-9]+.[0-9]+.[0-9]+$", "\033[33m&\033[0m"); print }'
done

notify;
