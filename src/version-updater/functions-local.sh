#!/bin/bash

#########################################################################################
### This is file with environment specific functions                                  ###
### It requires modifications and should be filled according to environment           ###
### File can be downloaded from HG repo:                                              ###
###    http://ehealth.webmedia.ee/scripts/version-updater/functions-local.sh          ###
###                                                                                   ###
### Author: Irina.Ivanova@nortal.com                                                  ###
### Last modified: 12.02.2016, v6.2                                                   ###
### Version-updater manual:                                                           ###
###    https://confluence.nortal.com/display/support/Version-updater+Script+Manual    ###
#########################################################################################


### This function is used only in one module update update-version-tomcat.sh
### Inside of this function following variables should be defined:
###    summary=""      # required only if $isJiraIssueUpdateRequired is Y; defines summary pattern of the issue, like "$summaryTitle$version"
###    link=""         # required; defines URL, where war file can be downloaded from, like "$warLocation/$module/wars/$module$extension-$version.war"
###    fileName=""     # required; defined name of the downloaded war file, like "$module$extension-$version.war"
###    moduleName=""   # required; defines path of the deployed application, like "ehealth-$module"
###
### NB! different modules are located in different URL-s and have different path pattern, so you propably need to write couple of if-statments
function setVariables() {

  if [[ $isJiraIssueUpdateRequired == "Y" ]]; then
    summary=""
  fi

  while read -r row; do
      case "$row" in \#*) continue ;; esac

      if [[ $module = $row ]]; then
        link=""
        fileName="$module$extension-$version.war"
        break
      else
        link=""
        fileName="$module-$version.war"
      fi
    done < $extendedModules

  moduleName=$module

}

### This function is used only in batch update batch-versions-update-tomcat.sh
### Inside of this function (and inside of while-loop that reads rows from $batch file) following variables should be defined:
### module=""       # required; defines the part of the row in $batch file that means module name, like $( echo "$line" |cut -d " " -f1 )
### version=""      # required; defined the part of the row in $batch file that means version number, like $( echo "$line" | cut -d " " -f2 )
### summary=""      # required only if $isJiraIssueUpdateRequired is Y; defines summary pattern of the issue, like "$summaryTitle$version"
### link=""         # required; defines URL, where war file can be downloaded from, like "$warLocation/$module/wars/$module$extension-$version.war"
### fileName=""     # required; defined name of the downloaded war file, like "$module$extension-$version.war"
### moduleName=""   # required; defines path of the deployed application, like "ehealth-$module"
###
### NB! different modules are located in different URL-s and have different path pattern, so you propably need to write couple of if-statments (inside the while-loop and before removeExistingFileWithSameName() )
function runBatchUpdate() {

  while read -r line; do

    case "$line" in \#*) continue ;; esac

    module=$( echo "$line" |cut -d " " -f1 )
    version=$( echo "$line" | cut -d " " -f2 )

    if [[ $isJiraIssueUpdateRequired == "Y" ]]; then
      summary="$summaryTitle$version"
    fi

    # Following function should be called only in multiple-server production environment
    # findClusterName;

    printInfo "\n********************Updating $line********************";

    while read -r row; do
      case "$row" in \#*) continue ;; esac

      if [[ $module = $row ]]; then
        link="$warLocation/$module/wars/$module$extension-$version.war"
        fileName="$module$extension-$version.war"
        break
      else
        link="$warLocation/$module/wars/$module-$version.war"
        fileName="$module-$version.war"
      fi
    done < $extendedModules

    moduleName="$module"

    removeExistingFileWithSameName;

    # One of the following functions can be called at a time:
    #     deployModuleFromBatch is for one-server test environments
    #     deployBatchModulesProd is for multiple-server production environments
    # deployBatchModulesProd;
    deployModuleFromBatch;

  done < $batch

}
