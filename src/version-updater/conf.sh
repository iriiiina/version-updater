#!/bin/bash

######################################################################################################
### This is configuration file for Version-Updater                                                 ###
### Here you can define environment specific variables and configure functionality of the script   ###
###                                                                                                ###
### Version-Updater is script for updating ehealth modules on different servers                    ###
### Currently Tomcat 8 is supported                                                                ###
###                                                                                                ###
### Author: Irina Ivanova, iriiiina@gmail.com                                                      ###
### Last modified: 12.02.2016, v6.2                                                                ###
### Version-updater manual:                                                                        ###
###     https://iriiiina.gitbooks.io/version-updater-manual/content/                               ###
######################################################################################################




### Environment specific local variables. They are all required, so leave them blank if you don't need to use them
### Possible variables:
###    app=""            # required; application name, like "test"
###    tomcatManager=""  # required; Tomcat manager URL with user and password, like "http://tomcat:tomcat@app.example.com:8080/manager/text"
###    proxy=""          # required; proxy server for external connections, like "-x cache.example.com:1234"
app=""
tomcatManager=""
proxy=""

### General variables, that may stay the same in differernt environments, but if needed may be changed
### Possible variables:
###    log=""              # required; file path, where script logs should be saved, like "version-updater/update.log"
###    warLocation=""      # required; URL, where EU modules are published, like "http://path-to-war-files.com"
###    batch=""            # required; file path, where modules and versions for batch update are listed, like "version-updater/batch-modules.txt"
log="version-updater/update.log"
warLocation="http://path-to-war-files.com"
batch="version-updater/batch-modules.txt"

### Variables to configure JIRA authentication and issue update functionality. If you use script on yout local machine you may want to disable authentication.
### Possible variables:
###    isAuthenticationRequired=""      # required Y or N value, if isJiraIssueUpdateRequired="Y", then this should be always Y; if value is Y, then JIRA authentication is required to run the script
###       isJiraIssueUpdateRequired=""  # required Y or N value; if value is Y, then script updates JIRA issues
###          summaryTitle=""            # required only if isJiraIssueUpdateRequired="Y", otherwise not in use; JIRA issue summary pattern, like "test***"
###          rest=""                    # required only if isJiraIssueUpdateRequired="Y", otherwise not in use; file path, where REST service temporary content will be held, like "version-updater/jira-rest.txt"
###          issues=""                  # required only if isJiraIssueUpdateRequired="Y", otherwise not in use; file path, where are listed JIRA issue code-module mappings, like "version-updater/jira-issues.txt"
###          jira=""                    # required only if isJiraIssueUpdateRequired="Y", otherwise not in use; URL of REST service for JIRA issue update, like "https://jira.example.com/rest/api/2/issue"
###       jiraAuth=""                   # required only if isAuthenticationRequired="Y", otherwise not in use; URL of JIRA for authentication check, like "https://jira.example.com"
isAuthenticationRequired="N"
isJiraIssueUpdateRequired="N"
summaryTitle=""
rest="version-updater/jira-rest.txt"
issues="version-updater/jira-issues.txt"
jira="https://jira.example.com/rest/api/2/issue"
jiraAuth="https://jira.example.com"

### Configure Tomcat restart functionality.
### Possible variables:
###    isRestartRequired=""  # required Y or N value; if value is Y, then script does Tomcat restart before update (with user's permission)
###       tomcatBin=""       # required only if isRestartRequired="Y", otherwise not in use; file path to the Tomcat's bin directory, like "tomcat8070/bin"
isRestartRequired="N"
tomcatBin="tomcat/bin"

### Configure logs deletion functionality.
### Possible variables:
###    isLogDeletionRequired=""  # required Y or N value; if value is Y, then script deletes log files with module's name befire update
###       appLogs=""             # required only if isLogDeletionRequired="Y", otherwise not in use; file path, where application logs are stored, like "logs/*"
###       tomcatLogs=""          # required only if isLogDeletionRequired="Y", otherwise not in use; file path, where Tomcat logs are stored, like "tomcat8070/logs/*"
isLogDeletionRequired="N"
appLogs="logs/*"
tomcatLogs="tomcat/logs/*"

### Configure temporary files deletion functionality.
### Possible variables:
###    isTempFilesDeletionRequired=""   # required Y or N value; if value is Y, then script deletes temporary files
###        tempFiles=""                 # required only if isTempFilesDeletionRequired="Y", otherwise not in use; file path, where temporary files are sored, like "tomcat8070/temp"
isTempFilesDeletionRequired="N"
tempFiles="tomcat/temp"

### Configure version comparison to warn users if they deploy older version than currently runs
### Possible variables:
###     isVersionCheckRequired=""    # required Y or N value; if value is Y, then script compares already deployed version with new one
isVersionCheckRequired="Y"

### Configure multi-server functionality. Usually this functionality is used only in production environments.
### Possible variables:
###    isMultiServer=""          # required Y or N value; if environment has one than more server or cluster, this values should be Y
###       firstTomcatManagers    # required only if isMultiServer="Y", otherwise not in use; array for listing all Tomcat manager's URLs (with username and password) for first cluster
###       secondTomcatManagers   # required only if isMultiServer="Y", otherwise not in use; array for listing all Tomcat manager's URLs (with username and password) for second cluster
###       modules                # required only if isMultiServer="Y", otherwise not in use; array for mapping modules and cluster names
###
### Example:
### isMultiServer="N"
###
### declare -A firstTomcatManagers
### firstTomcatManagers["@prdapp01:8080"]="http://username:password@prdapp01:8080/manager/text"
### firstTomcatManagers["@prdapp02:8080"]="http://username:password@prdapp02:8080/manager/text"
### 
### declare -A secondTomcatManagers
### secondTomcatManagers["@prdapp01:8090"]="http://username:password@prdapp01:8090/manager/text"
### secondTomcatManagers["@prdapp02:8090"]="http://username:password@prdapp02:8090/manager/text"
###  
### declare -A modules
### modules["admin"]="first"
### modules["authentication"]="first"
### modules["billing"]="second"
isMultiServer="N"
