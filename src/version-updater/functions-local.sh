#!/bin/bash

################################################################################
### This is file with environment specific functions                         ###
### It requires modifications and should be filled according to environment  ###
###                                                                          ###
### Author: Irina Ivanova, iriiiina@gmail.com                                ###
### Last modified: 12.02.2016, v6.2                                          ###
### Version-updater manual:                                                  ###
###    https://iriiiina.gitbooks.io/version-updater-manual/content/          ###
################################################################################


### This function is used only in one module update update-version-tomcat.sh
### Inside of this function following variables should be defined:
###    summary=""      # required only if $isJiraIssueUpdateRequired="Y"; defines summary pattern of the issue, like "$summaryTitle$version"
###    link=""         # required; defines URL, where war file can be downloaded from, like "$warLocation/$module/wars/$module$extension-$version.war"
###    fileName=""     # required; defined name of the downloaded war file, like "$module$extension-$version.war"
###    moduleName=""   # required; defines path of the deployed application, like "$module"
function setVariables() {

  if [[ $isJiraIssueUpdateRequired == "Y" ]]; then
    summary=""
  fi

  link=""
  fileName="$module$extension-$version.war"
  moduleName=$module

}

### This function is used only in batch update batch-versions-update-tomcat.sh
### Inside of this function (and inside of while-loop that reads rows from $batch file) following variables should be defined:
### module=""       # required; defines the part of the row in $batch file that means module name, like $( echo "$line" |cut -d " " -f1 )
### version=""      # required; defined the part of the row in $batch file that means version number, like $( echo "$line" | cut -d " " -f2 )
### summary=""      # required only if $isJiraIssueUpdateRequired="Y"; defines summary pattern of the issue, like "$summaryTitle$version"
### link=""         # required; defines URL, where war file can be downloaded from, like "$warLocation/$module/wars/$module$extension-$version.war"
### fileName=""     # required; defined name of the downloaded war file, like "$module$extension-$version.war"
### moduleName=""   # required; defines path of the deployed application, like "$module"
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

    link="$warLocation/$module/wars/$module$extension-$version.war"
    fileName="$module$extension-$version.war"
    moduleName="$module"

    removeExistingFileWithSameName;

    # One of the following functions can be called at a time:
    #     deployModuleFromBatch is for one-server test environments
    #     deployBatchModulesProd is for multiple-server production environments
    # deployBatchModulesProd;
    deployModuleFromBatch;

  done < $batch

}
