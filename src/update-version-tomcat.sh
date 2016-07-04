#!/bin/bash

########################################################################################
### This is script for updating one module on Tomcat 8 server                        ###
### It may require modifications – see comments for details                          ###
###                                                                                  ###
### Author: Irina Ivanova, iriiiina@gmail.com                                        ###
### Last modified: 04.07.2016, v6.3                                                  ###
### Version-updater manual:                                                          ###
###    https://iriiiina.gitbooks.io/version-updater-manual/content/                  ###
########################################################################################

# Import of global variables and functions
. version-updater/conf.sh
. version-updater/functions.sh
. version-updater/functions-tomcat.sh
. version-updater/functions-local.sh

# User arguments
module=$1
version=$2

verifyConfFile;
verifyLock;
verifyArguments $#;

echo -e "\n----------one module update: $module-$version----------" >> $log

if [[ $isAuthenticationRequired == "Y" ]]; then
  user=$3
  lock="UPDATING_$user-$module-$version-$(date +"%d.%m.%Y-%H:%M:%S").loc"
  touch $lock
  isParallelDeployment $4;

  notify;
  printCyan "Please insert password for JIRA account $user:";
  read -s password

  testJiraAuthentication;

elif [[ $isAuthenticationRequired == "N" ]]; then
  lock="UPDATING_$module-$version-$(date +"%d.%m.%Y-%H:%M:%S").loc"
  touch $lock
  isParallelDeployment $3;
fi

setVariables;

if [[ $isLogDeletionRequired == "Y" ]] && [[ $parallel == "N" ]]; then
  deleteLogs;
fi

if [[ $isTempFilesDeletionRequired == "Y" ]] && [[ $parallel == "N" ]]; then
  deleteTempFiles;
fi

if [[ $isRestartRequired == "Y" ]]; then
  notify;
  printCyan "Do you want to do the restart first? (Y, y, YES, yes)";
  read restart

  if [[ $restart == "Y" ]] || [[ $restart == "y" ]] || [[ $restart == "yes" ]] || [[ $restart == "YES" ]]; then
    restart;
  fi
fi

if [[ $isMultiServer == "Y" ]]; then
  removeExistingFileWithSameName;

  if [ $clusterName != "" ]; then
    printGray "\n\t**********$module-$version**********";

    downloadFile;
  else
    removeLock;
    exit
  fi

  # If variables $firstTomcatManagers and $secondTomcatManagers were renamed, you should also rename them here
  if [[ $clusterName == "first" ]]; then
    for index in ${!firstTomcatManagers[@]}
    do
      tomcatManager=${firstTomcatManagers[$index]}
      tomcatManagerName=$index

      printGray "\n\t*****UPDATE $module-$version$tomcatManagerName*****";

      getCurrentVersion;

      if [[ $isVersionCheckRequired == "Y" ]]; then
        compareVersions;
      fi

      checkNumberOfDeploys;

      if [[ $parallel == "N" ]]; then
        undeploy;
      fi

      deploy;

      checkIsRunning;
    done

  elif [[ $clusterName == "second" ]]; then
    for index in ${!secondTomcatManagers[@]}
    do
      tomcatManager=${secondTomcatManagers[$index]}
      tomcatManagerName=$index

      printGray "\n\t*****UPDATE $module-$version$tomcatManagerName*****";

      getCurrentVersion;

      if [[ $isVersionCheckRequired == "Y" ]]; then
        compareVersions;
      fi

      checkNumberOfDeploys;

      if [[ $parallel == "N" ]]; then
        undeploy;
      fi

      deploy;

      checkIsRunning;
    done

  # You may want to add more elif conditions here if you have more than 2 Tomcat servers

  else
    printError "can't find Tomcat Managers for module type $clusterName";
    log "ERROR: can't find Tomcat Managers for module type $clusterName";
  fi

  if [ $clusterName != "" ]; then
    if [[ $isJiraIssueUpdateRequired == "Y" ]] && [ ${#runErrors[*]} -eq 0 ]; then
      updateIssueSummary;
    fi

    removeDownloadedFile;

    printStatistics;
  fi
elif [[ $isMultiServer == "N" ]]; then
  printCyan "\n\t**********$fileName**********";

  getCurrentVersion;

  if [[ $isVersionCheckRequired == "Y" ]]; then
    compareVersions;
  fi

  removeExistingFileWithSameName;

  downloadFile;

  checkNumberOfDeploys;

  if [[ $parallel == 'N' ]]; then
    undeploy;
  fi

  deploy;

  checkIsRunning;

  if [[ $isJiraIssueUpdateRequired == "Y" ]] && [[ ${#runErrors[*]} == 0 ]]; then
    updateIssueSummary;
  fi

  removeDownloadedFile;

  deployOtherVersion;
fi

removeLock;
