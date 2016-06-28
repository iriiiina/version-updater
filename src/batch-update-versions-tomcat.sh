#!/bin/bash

##############################################################################
### This is script for updating many modules at a time on Tomcat 8 server  ###
### It doesn't require modifications and can be used out-of-the-box        ###
###                                                                        ###
### Author: Irina Ivanova, iriiiina@gmail.com                              ###
### Last modified: 28.06.2016, v6.3                                        ###
### Version-updater manual:                                                ###
###    https://iriiiina.gitbooks.io/version-updater-manual/content/        ###
##############################################################################

# Import of global variables and functions
. version-updater/conf.sh
. version-updater/functions.sh
. version-updater/functions-tomcat.sh
. version-updater/functions-local.sh

verifyConfFile;
verifyLock;
verifyBatchArguments $#;

if [[ $isAuthenticationRequired == "Y" ]]; then
  user=$1
  lock="UPDATING_BATCH_MODULES_$user-$(date +"%d.%m.%Y-%H:%M:%S").loc"
  touch $lock
  isParallelDeployment $2

  notify;
  printInfo "Please insert password for JIRA account $user:";
  read -s password

  testJiraAuthentication;
else
  lock="UPDATING_BATCH_MODULES-$(date +"%d.%m.%Y-%H:%M:%S").loc"
  touch $lock
  isParallelDeployment $1
fi

echo -e "\n"
printGray "*********************************************";
printGray "********************START********************";
printGray "*********************************************";

runBatchUpdate;

printStatistics;

removeLock;
