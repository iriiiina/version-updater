#!/bin/bash

###########################################################################
### This is file with global functions fro version-updater              ###
### You may want to change some functions – see details in comments     ###
###                                                                     ###
### Author: Irina Ivanova, iriiiina@gmail.com                           ###
### Last modified: 28.06.2016, v6.3                                     ###
### Version-updater manual:                                             ###
###     https://iriiiina.gitbooks.io/version-updater-manual/content/    ###
###########################################################################

# Colors for output
NONE='\e[0m'
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
CYAN='\e[36m'
GRAY='\e[100m'

function printError() {
  echo -e "\n\t${RED}ERROR: $1${NONE}"
}

function printRed() {
  echo -e "${RED}$1${NONE}"
}

function printWarning() {
  echo -e "\t${YELLOW}WARNING: $1${NONE}"
}

function printOk() {
  echo -e "\t${GREEN}OK: $1${NONE}"
}

function printInfo() {
  echo -e "\n\t${CYAN}$1...${NONE}"
}

function printCyan() {
  echo -e "${CYAN}$1${NONE}"
}

function printGray() {
  echo -e "${GRAY}$1${NONE}"
}

function log() {
  now=$(date +"%d.%m.%Y %H:%M:%S")

  if [[ $isAuthenticationRequired == "Y" ]]; then
    echo -e "$now $user $1" >> $log
  elif [[ $isAuthenticationRequired == "N" ]]; then
    echo -e "$now $1" >> $log
  fi
}

function verifyLock() {
  if test -e "UPDATING_"*; then
    printError "somebody is updating: $(ls UPDATING_*)";
    printRed "\n\n";
    notify;
    exit
  fi
}

function verifyConfFile() {

  checkErrorCount=0;

  if [[ $isAuthenticationRequired != "N" ]] && [[ $isAuthenticationRequired != "Y" ]] && [[ $isAuthenticationRequired != "" ]]; then
    printError "error in set variables.sh configurations: isAuthenticationRequired value can be only N, Y or NULL";
    checkErrorCount=1
  fi

  if [[ $isJiraIssueUpdateRequired != "N" ]] && [[ $isJiraIssueUpdateRequired != "Y" ]] && [[ $isJiraIssueUpdateRequired != "" ]]; then
    printError "error in set variables.sh configurations: isJiraIssueUpdateRequired value can be only N, Y or NULL";
    checkErrorCount=1
  fi

  if [[ $isRestartRequired != "N" ]] && [[ $isRestartRequired != "Y" ]] && [[ $isRestartRequired != "" ]]; then
    printError "error in set variables.sh configurations: isRestartRequired value can be only N, Y or NULL";
    checkErrorCount=1
  fi

  if [[ $isLogDeletionRequired != "N" ]] && [[ $isLogDeletionRequired != "Y" ]] && [[ $isLogDeletionRequired != "" ]]; then
    printError "error in set variables.sh configurations: isLogDeletionRequired value can be only N, Y or NULL";
    checkErrorCount=1
  fi

  if [[ $isTempFilesDeletionRequired != "N" ]] && [[ $isTempFilesDeletionRequired != "Y" ]] && [[ $isTempFilesDeletionRequired != "" ]]; then
    printError "error in set variables.sh configurations: isTempFilesDeletionRequired value can be only N, Y or NULL";
    checkErrorCount=1
  fi

  if [[ $isMultiServer != "Y" ]] && [[ $isMultiServer != "N" ]] && [[ $isMultiServer != "" ]]; then
    printError "error in conf.sh configurations: isMultiServer value can be only N, Y or NULL";
    checkErrorCount=1
  fi

  if [[ $isAuthenticationRequired == "N" ]] && [[ $isJiraIssueUpdateRequired == "Y" ]]; then
    printError "error in conf.sh configurations: isJiraIssueUpdateRequired can't be Y if isAuthenticationRequired is N";
    checkErrorCount=1
  fi

  if [[ $isJiraIssueUpdateRequired == "Y" ]] && ([[ $rest == "" ]] || [[ $issues == "" ]] || [[ $jira == "" ]] || [[ $jiraAuth == "" ]]); then
    printError "error in conf.sh configurations: rest, issues, jira or jiraAuth variables can't be NULL if isJiraIssueUpdateRequired is Y";
    checkErrorCount=1
  fi

  if [[ $isAuthenticationRequired == "Y" ]] && [[ $jiraAuth == "" ]]; then
    printError "error in conf.sh configurations: jiraAuth can't be NULL if isAuthenticationRequired is Y";
    checkErrorCount=1
  fi

  if [[ $isRestartRequired == "Y" ]] && [[ $tomcatBin == "" ]]; then
    printError "error in conf.sh configurations: tomcatBin can't be NULL if isRestartRequired is Y";
    checkErrorCount=1
  fi

  if [[ $isLogDeletionRequired == "Y" ]] && ([[ $appLogs == "" ]] || [[ $tomcatLogs == "" ]]); then
    printError "error in conf.sh configurations: appLogs or tomcatLogs can't be NULL if isLogDeletionRequired is Y";
    checkErrorCount=1
  fi

  if [[ $isTempFilesDeletionRequired == "Y" ]] && [[ $tempFiles == "" ]]; then
    printError "error in conf.sh configurations: tempFiles can't be NULL if isTempFilesDeletionRequired is Y";
    checkErrorCount=1
  fi

  if [[ $isVersionCheckRequired != "Y" ]] && [[ $isVersionCheckRequired != "N" ]] && [[ $isVersionCheckRequired != "" ]]; then
    printError "error in conf.sh configurations: isVersionCheckRequired value can be only N, Y ot NULL";
    checkErrorCount=1
  fi

  if [[ $checkErrorCount -gt 0 ]]; then
    notify;
    exit
  fi
}

function verifyArguments() {
  if [[ $isAuthenticationRequired == "Y" ]]; then
    if [ $1 -lt 3 ] || [ $1 -gt 4 ]; then
      printRed "\nUsage: $0 MODULE_NAME MODULE_VERSION JIRA_USERNAME [p]";
      printRed "Example: $0 admin 1.1.1.1 irina";
      printRed "Example for parallel update: $0 admin 1.1.1.1 irina p\n";
      notify;
      exit
    fi
  elif [[ $isAuthenticationRequired == "N" ]]; then
    if [ $1 -lt 2 ] || [ $1 -gt 3 ]; then
      printRed "\nUsage: $0 MODULE_NAME MODULE_VERSION [p]";
      printRed "Example: $0 admin 1.1.1.1";
      printRed "Example for parallel update: $0 admin 1.1.1.1 p\n";
      notify;
      exit
    fi
  fi
}

function verifyBatchArguments() {
  if [[ $isAuthenticationRequired == "Y" ]]; then
    if [[ $1 -gt 2 ]] || [[ $1 -lt 1 ]]; then
      printRed "\nUsage: $0 JIRA_USERNAME [p]";
      printRed "Example: $0 irina";
      printRed "Example for silebt update: $0 irina p\n";
      notify;
      exit
    fi
  elif [[ $isAuthenticationRequired == "N" ]]; then
    if [[ $1 -gt 2 ]]; then
      printRed "\nUsage: $0 [p]";
      printRed "Example: $0";
      printRed "Example for parallel update: $0 p\n";
      notify;
      exit
    fi
  fi
}

function removeLock() {
  printInfo "Removing lock file";

  if test -e $lock; then
    rm $lock
    printOk "lock file $lock is removed";
  fi

  notify;
}

function notify() {
  printf '\a' # notification or "bell" in terminal
}

function isParallelDeployment() {
  if [[ $1 == "p" ]]; then
    parallel="Y"
    printWarning "update ${RED}is ${YELLOW}parallel!${NONE}\n";
    log "INFO: update is parallel";
  else
    parallel="N"
    printWarning "update is ${RED}not ${YELLOW}parallel!${NONE}\n";
    log "INFO: update is not parallel";
  fi
}

function deleteLogs() {
  printInfo "Deleting old logs";
  find $appLogs -mtime +7 -exec rm {} \;
  log "OK: application logs $appLogs are deleted";
  find $tomcatLogs -mtime +7 -exec rm {} \;
  log "OK: Tomcat logs $tomcatLogs are deleted";
  printOk "logs older than 7 days are deleted";
}

function deleteTempFiles() {
  printInfo "Deleting temporary files from $tempFiles/*$moduleName*";
  rm -rf $tempFiles/*$moduleName*
  log "OK: temporary files $tempFiles are deleted";
  printOk "temporary files $tempFiles/*$moduleName* are deleted";
}

# You may need to modify this function according to your versioning pattern
# Currently function works with pattern 1.1.1.1
function compareVersions() {
  currentStage=$(echo $currentVersion | grep -o --regexp='^[0-9]*')
  stage=$(echo $version | grep -o --regexp='^[0-9]*')

  currentMilestone=$(echo $currentVersion | grep -o --regexp='^[0-9]*\.[0-9]*' | grep -o --regexp='[0-9]*$')
  milestone=$(echo $version | grep -o --regexp='^[0-9]*\.[0-9]*' | grep -o --regexp='[0-9]*$')

  currentSubmilestone=$(echo $currentVersion | grep -o --regexp='\.[0-9]*\.[0-9]*' | grep -o --regexp='[0-9]*$')
  submilestone=$(echo $version | grep -o --regexp='\.[0-9]*\.[0-9]*' | grep -o --regexp='[0-9]*$')

  currentVersionNumber=$(echo $currentVersion | grep -o --regexp='[0-9]*$')
  versionNumber=$(echo $version | grep -o --regexp='[0-9]*$')

  printInfo "Comparing version with deployed one";

  if [[ $stage -gt $currentStage ]] || [[ $milestone -gt $currentMilestone ]] || [[ $submilestone -gt $currentSubmilestone ]]; then
    printWarning "cycle of inserted version $version is grater than in deployed version $currentVersion$tomcatManagerName";
    versionWarnings+=("$module: old cycle $currentVersion is older than new cycle $version$tomcatManagerName")
  elif [[ $stage -lt $currentStage ]] || [[ $milestone -lt $currentMilestone ]] || [[ $submilestone -lt $currentSubmilestone ]]; then
    printWarning "cycle of inserted version $version is lower than in deployed version $currentVersion$tomcatManagerName";
    versionWarnings+=("$module: old cycle $currentVersion is newer than new cycle $version$tomcatManagerName")
  elif [[ $versionNumber -lt $currentVersionNumber ]]; then
    printWarning "inserted version $version is lower than deployed version $currentVersion$tomcatManagerName";
    versionWarnings+=("$module: old version $currentVersion is newer than new version $version$tomcatManagerName")
  else
    printOk "inserted version $version is grater or equal to deployed version $currentVersion$tomcatManagerName";
  fi
}

function removeExistingFileWithSameName() {
  if test -e "$fileName"; then
    printInfo "Removing existing $fileName file";

    rm $fileName

    if ! test -e "$fileName"; then
      printOk "existing file is removed";
    else
      printError "can't remove existing file";
      exit
    fi
  fi
}

function downloadFile() {
  printInfo "Downloading $fileName file";
  wget $link

  if test -e $fileName; then
    printOk "file $fileName is downloaded";
    log "OK: $fileName is downloaded";
  else
    printError "can't download the $fileName file from $link";
    log "ERROR: $fileName is not downloaded from $link";
    removeLock;
    exit
  fi
}

function removeDownloadedFile() {
  printInfo "Removing downloaded file";
  rm $fileName

  if ! test -e "$fileName"; then
    printOk "downloaded file is removed";
  else
    printError "can't remove file $fileName";
  fi
}

function testJiraAuthentication() {
  printInfo "Testing JIRA authentication";

  authenticate=$(curl -D- -u $user:$password -H "Content-Type: application/json" $jiraAuth $proxy)

  if echo "$authenticate" | grep -q "AUTHENTICATED_FAILED"; then
    printError "authentication failed: 401 unauthorized. Probably username or password is incorrect";
    removeLock;
    exit;
  elif echo "$authenticate" | grep -q "AUTHENTICATION_DENIED"; then
    printError "authentication denied: 403 forbidden. Probably password was inserted incorrectly 3 times and now you should relogin yourself in browser with captcha control";
    removeLock;
    exit;
  elif echo "$authenticate" | grep -q "302 Found"; then
    printOk "login into JIRA succeeded";
  else
    printRed "$authenticate";
    removeLock;
    exit;
  fi
}

function findIssue() {
  printInfo "Finding JIRA issue key in jira-issues.txt";

  while read -r key; do

    case "$line" in \#*) continue ;; esac

    issueModule=$( echo "$key" | cut -d ":" -f1 )
    issueKey=$( echo "$key" | cut -d ":" -f2 )

    if [ $issueModule = $module ]; then
      issue=$issueKey
    return
    else
      issue=""
    fi

  done < $issues

  if [[ $issue == "" ]]; then
    printError "can't find JIRA issue key for $module in jira-issues.txt";
  else
    printOk "JIRA issue key for $moduleName is found: $issue";
  fi
}

function clearJiraRest() {
  printInfo "Deleting generated REST content";

  echo -n "" > $rest

  printOk "generated REST content is deleted";
}

function generateJiraRest() {
  printInfo "Generating REST content";

  echo -n "" > $rest

  echo "{
             \"fields\": {
               \"summary\": \"$summary\"
             }
           }" >> $rest

  printOk "REST content is generated";
}

function updateIssueSummary() {
  printInfo "Updating JIRA issue summary";

  findIssue;

  if [[ $issue = "" ]]; then
    jiraErrors+=($module-$version)
    log "ERROR: JIRA issue is not found";
  else

    generateJiraRest;

    update=$(curl -D- -u $user:$password -X PUT --data @$rest -H "Content-Type: application/json" $jira/$issue $proxy)

    if echo "$update" | grep -q "No Content"; then
      printOk "JIRA issue $issue summary is updated to $summary";
      log "OK: JIRA issue $issue summary is updated to $summary";
    else
      printRed "$update";
      jiraErrors+=($module-$version)
      log "JIRA ERROR: issue $issue summary is not updated";
    fi

    clearJiraRest;

  fi
}

function findClusterName() {

  printInfo "Finding cluster name of module $module";

  for index in ${!modules[@]}
  do
    if [[ $module = $index ]]; then
      clusterName=${modules[$index]}
      printOk "cluster name of module $module is $clusterName";
      break
    else
      clusterName=""
    fi
  done

  if [[ $clusterName = "" ]]; then
    clusterErrors+=("$module-$version$tomcatManagerName")
    printError "can't figure out the cluster name for $module module";
    log "ERROR: can't figure out the cluster name for $module module";
  fi
}

function printBatchErrors() {
  label=$1
  errors=( $2 )

  if [ ${#errors[*]} -gt 0 ]; then
    echo -e "\t\t$label ERRORS: ${RED}${#errors[*]}${NONE}"
    for item in ${errors[*]}
    do
      echo -e "\t\t\t${RED}$item${NONE}"
    done
  else
    echo -e "\t\t$label ERRORS: ${#errors[*]}"
  fi
}

function printBatchWarnings() {
  label=$1
  warnings=( $2 )

  if [ ${#warnings[*]} -gt 0 ]; then
    echo -e "\t\t$label WARNINGS: ${YELLOW}${#warnings[*]}${NONE}"
    for item in ${warnings[*]}
    do
      echo -e "\t\t\t${YELLOW}$item${NONE}"
    done
  else
    echo -e "\t\t$label WARNINGS: ${#warnings[*]}"
  fi
}

function printVersionWarnings() {

  if [ ${#versionWarnings[*]} -gt 0 ]; then
    echo -e "\t\tVERSION WARNINGS: ${YELLOW}${#versionWarnings[*]}${NONE}"
    for ((i = 0; i < ${#versionWarnings[@]}; i++)); do
      echo -e "\t\t\t${YELLOW}${versionWarnings[$i]}${NONE}"
    done
  else
    echo -e "\t\tVERSION WARNINGS: ${#versionWarnings[*]}"
  fi
}

function printDeployedModules() {
  if [ ${#successDeploys[*]} -gt 0 ]; then
    echo -e "\n\n\t\tDEPLOYED MODULES: ${GREEN}${#successDeploys[*]}${NONE}"
    for item in ${successDeploys[*]}
    do
      echo -e "\t\t\t${GREEN}$item${NONE}"
    done
  else
    echo -e "\n\t\tDEPLOYED MODULES: ${#successDeploys[*]}"
  fi
}

function printStatistics() {
  echo -e "\n\n"
  printGray "**************************************************";
  printGray "********************STATISTICS********************";

  if [[ $isMultiServer == "Y" ]]; then
    printBatchErrors "CLUSTER" "$(echo ${clusterErrors[@]})";
  fi

  printBatchErrors "DOWNLOAD" "$(echo ${downloadErrors[@]})";
  printBatchWarnings "UNDEPLOY" "$(echo ${undeployWarnings[@]})";
  printBatchErrors "DEPLOY" "$(echo ${deployErrors[@]})";
  printBatchErrors "RUN" "$(echo ${runErrors[@]})";

  if [[ $isJiraIssueUpdateRequired == "Y" ]]; then
    printBatchErrors "JIRA" "$(echo ${jiraErrors[@]})";
  fi

  if [[ $isVersionCheckRequired == "Y" ]]; then
    printVersionWarnings;
  fi

  printDeployedModules;

  printGray "**************************************************";
  echo -e "\n\n"
}
