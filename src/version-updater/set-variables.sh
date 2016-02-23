#!/bin/bash

# Local variables, that should be different in every environment
 
app=""
extension=""
tomcatManager=""
proxy=""

# Configure JIRA authentication and issue update functionality
isAuthenticationRequired="" # if isJiraIssueUpdateRequired is Y, then this should be always Y
isJiraIssueUpdateRequired=""
summaryTitle=""
rest=""
issues=""
jira=""
jiraAuth=""

# Configure Tomcat restart functionality
isRestartRequired=""
tomcatBin=""

# Configure logs deletion functionality
isLogDeletionRequired=""
appLogs=""
tomcatLogs=""

# Configure temporary files deletion functionality
isTempFilesDeletionRequired=""
tempFiles=""

# Configure multi-server functionality
isMultiServer=""
declare -A ehealthTomcatManagers
ehealthTomcatManagers[""]=""
ehealthTomcatManagers[""]=""
 
declare -A hisTomcatManagers
hisTomcatManagers[""]=""
hisTomcatManagers[""]=""
 
declare -A modules
modules["admin"]="ehealth"
modules["authentication"]="ehealth"
modules["authorization"]="ehealth"
modules["billing"]="ehealth"
modules["clinicial-portal"]="ehealth"
modules["diet"]="ehealth"
modules["docman"]="ehealth"
modules["integration"]="ehealth"
modules["integration-lt"]="ehealth"
modules["person"]="ehealth"
modules["prevention"]="ehealth"
modules["register"]="ehealth"
modules["report-engine"]="ehealth"
modules["schedule"]="ehealth"
modules["system"]="ehealth"
modules["treatment"]="ehealth"
modules["ui"]="ehealth"
modules["zk"]="ehealth"
modules["diagnostics"]="his"
modules["reception"]="his"
modules["treatment"]="his"
 
# General variables, that may stay the same in different environment, but if needed may be changed
 
extendedModules=""
log=""
warLocation=""
warLocationCom=""
batch=""
