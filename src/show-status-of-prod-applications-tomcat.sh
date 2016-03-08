#!/bin/bash

########################################################################################################################
### This is script for listing deployed applications on multiple-server and multiple-cluster environment (Tomcat 8)  ###
### You may want to add some changes here, all possible modifications are mentioned in the comments                  ###
###                                                                                                                  ###
### Author: Irina Ivanova, iriiiina@gmail.com                                                                        ###
### Last modified: 4.02.2016, v2.0                                                                                   ###
### Version-updater manual:                                                                                          ###
###    https://iriiiina.gitbooks.io/version-updater-manual/content/                                                  ###
########################################################################################################################

# Import of global variables and functions
# Variables and functions that are taken from these global files - if needed you can define them here
#    ${GRAY}
#    ${NONE}
#    $firstTomcatManagers
#    $secondTomcatManagers
#    notify()
. version-updater/conf.sh
. version-updater/functions.sh

function printTitle() {
  echo -e "${GRAY}$1${NONE}"
}

# You can rename $firstTomcatManagers and $secondTomcatManagers arrays – in that case you should also rename their declarations
for index in ${!firstTomcatManagers[@]}
do
  echo -e "\n\n"
  printTitle "*********FIRST $index*********";

  # You can modife regular expressions here according to your needs
  curl -silent ${firstTomcatManagers[$index]}/list | sort | grep ^/ | awk '{ gsub("running", "\033[32m&\033[0m");
  																																					 gsub("stopped", "\033[31m&\033[0m");
  																																					 gsub("\\:[0-9]+", "\033[34m&\033[0m");
  																																					 gsub("^/.+:", "\033[36m&\033[0m");
  																																					 gsub("[0-9]+.[0-9]+.[0-9]+.[0-9]+$", "\033[33m&\033[0m");
  																																					 print }'

done

for index in ${!secondTomcatManagers[@]}
do
  echo -e "\n\n"
  printTitle "*********SECOND $index*********";

  curl -silent ${secondTomcatManagers[$index]}/list | sort | grep ^/ | awk '{ gsub("running", "\033[32m&\033[0m");
  																																						gsub("stopped", "\033[31m&\033[0m");
  																																						gsub("\\:[0-9]+", "\033[34m&\033[0m");
  																																						gsub("^/.+:", "\033[36m&\033[0m");
  																																						gsub("[0-9]+.[0-9]+.[0-9]+.[0-9]+$", "\033[33m&\033[0m");
  																																						print }'
done

# You can add other for-loops here according to the number of your Tomcat servers

notify;
