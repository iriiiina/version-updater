#!/bin/bash

########################################################################################
### This is script for updating one module on Tomcat 8 server                        ###
### It doesn't require modifications and can be used out-of-the-box                  ###
###                                                                                  ###
### Author: Irina Ivanova, iriiiina@gmail.com                                        ###
### Last modified: 12.02.2016, v6.2                                                  ###
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
  lock="UPDATING_$user-$module-$version.loc"
  isParallelDeployment $4;

  notify;
  printCyan "Please insert password for JIRA account $user:";
  read -s password

  testJiraAuthentication;

elif [[ $isAuthenticationRequired == "N" ]]; then
  lock="UPDATING-$module-$version.loc"
  isParallelDeployment $3;
fi

touch $lock

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

  if [ $type != "" ]; then
    printGray "\n\t**********$module-$version**********";

    downloadFile;
  else
    removeLock;
    exit
  fi

  if [[ $type == "ehealth" ]]; then
    for index in ${!ehealthTomcatManagers[@]}
    do
      tomcatManager=${ehealthTomcatManagers[$index]}
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

  elif [[ $type == "his" ]]; then
    for index in ${!hisTomcatManagers[@]}
    do
      tomcatManager=${hisTomcatManagers[$index]}
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
  else
    printError "can't find Tomcat Managers for module type $type";
    log "ERROR: can't find Tomcat Managers for module type $type";
  fi

  if [ $type != "" ]; then
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
