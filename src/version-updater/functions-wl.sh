#!/bin/bash

#################################################################################
### This is file with WebLogic 12c specific global functions                  ###
### It doesn't require modifications and should be used out-of-the-box        ###
### File can be downloaded from HG repo:                                      ###
###    http://ehealth.webmedia.ee/scripts/version-updater/functions-wl.sh     ###
###                                                                           ###
### Author: Irina.Ivanova@nortal.com                                          ###
### Last modified: 4.02.2016, v4.0                                            ###
### Version-updater manual:                                                   ###
###    https://confluence.nortal.com/display/support/Version-updater+Script   ###
#################################################################################

function getCurrentVersion() {
  printInfo "Getting current version of $moduleName";

  currentVersion=$($wlst -loadProperties $WLenvironmentProperties $deployUndeployScript $moduleName "list" | grep "^$moduleName#" | grep -o --regexp='[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*')

  if [[ $currentVersion == "" ]]; then
    printWarning "can't find current version of $moduleName";
  else
    printOk "current version of $moduleName is $currentVersion";
  fi
}

function checkNumberOfDeploys() {
  printInfo "Checking number of deploys of $moduleName";
  numberOfDeploys=$($wlst -loadProperties $WLenvironmentProperties $deployUndeployScript $moduleName "list" | grep "^$moduleName#" | wc -l)

  if [[ $numberOfDeploys == 1 ]]; then
    printOk "at the moment only 1 version of $moduleName is deployed";
  elif [[ $numberOfDeploys == 0 ]]; then
    printWarning "can't find any deployed version of $moduleName";
  else
    printWarning "there is more than 1 versions of $moduleName are deployed, can't decide which one to undeploy";
  fi
}

function downloadBatchFile() {
  getCurrentVersion;

  if [[ $isVersionCheckRequired == "Y" ]]; then
    compareVersions;
  fi

  printInfo "Downloading $fileName file";

  wget $link

  if test -e "$fileName"; then
    printOk "file $fileName is downloaded";
	log "OK: $fileName is downloaded";
    precompileBatch;
    printCyan "********************Update of $fileName is completed********************";

  else
    printError "can't download the $fileName file from $link";
	log "ERROR: $fileName is not downloaded from $link";
    downloadErrors+=($module-$version)
    printCyan "********************Update of $fileName is completed********************";
  fi
}

function precompile() {
  if [[ $module = "tyk" ]] || [[ $module = "itk" ]]; then
    printWarning "TYK or ITK module doesn't need to be precompiled";
  else
    export WL_HOME=/home/wls/bea/wlserver_12.1

    printInfo "Precompiling $fileName";
    java -Xmx512M -cp com.springsource.org.apache.taglibs.standard-1.1.2.v20110517.jar:$WL_HOME/server/lib/weblogic.jar weblogic.appc $fileName
    exitCode=$?

    if [ $exitCode -ne 0 ]; then
      printError "can't pecompile $fileName";
      log "ERROR: $fileName is not precompiled";
      rm $fileName
      removeLock;
      exit 1
    else
      printOk "$fileName is precompiled";
      log "OK: $fileName is precompiled";
    fi
  fi
}

function precompileBatch() {
  if [[ $module = "tyk" ]] || [[ $module = "itk" ]]; then
    printWarning "TYK or ITK module doesn't need to be precompiled";
  else
    export WL_HOME=/home/wls/bea/wlserver_12.1

    printInfo "Precompiling $fileName";
    java -Xmx512M -cp com.springsource.org.apache.taglibs.standard-1.1.2.v20110517.jar:$WL_HOME/server/lib/weblogic.jar weblogic.appc $fileName
    exitCode=$?
  fi

  if [ $exitCode -ne 0 ]; then
    printError "can't precompile $fileName";
    log "ERROR: $fileName is not precompiled";
    exitCode=0
    precompileErrors+=($module-$version)
    rm $fileName
  else
    if [[ $module = "tyk" ]] || [[ $module = "itk" ]]; then
      echo ""
    else
      printOk "$fileName is precompiled";
      log "OK: $fileName is precompiled";
    fi

    renameFile;
    undeploy;
    deploy;

  fi
}

function renameFile() {
  printInfo "Renaming downloaded file";

  mv $fileName "$moduleName.war"
  printOk "$fileName file is renamed to $moduleName.war";
}

function undeploy() {
  printInfo "Undeploying old version $moduleName-$currentVersion";

  undeploy=$($wlst -loadProperties $WLenvironmentProperties $deployUndeployScript $moduleName "undeploy")

  if echo "$undeploy" | grep -q "OK: old version of"; then
    printOk "old version $moduleName-$currentVersion is undeployed";
	log "OK: $moduleName-$currentVersion is undeployed";
  else
    printRed "$undeploy";
	log "ERROR: $moduleName-$currentVersion is not undeployed";
    undeployWarnings+=($module-$version)
  fi
}

function deploy() {
  printInfo "Deploying new version $moduleName-$version";

  deploy=$($wlst -loadProperties $WLenvironmentProperties $deployUndeployScript $moduleName "deploy")

  if echo "$deploy" | grep -q "OK: new version of"; then
    printOk "$moduleName-$version is deployed";
    log "OK: $moduleName-$version is deployed";
    successDeploys+=($module-$version)
    isRunning=true

    updateIssueSummary;
  else
    printRed "$deploy";
    log "ERROR: $moduleName-$version is not deployed";
    deployErrors+=($module-$version)
    isRunning=false
  fi
}

function deployOtherVersion() {
  if [[ $isRunning == true ]]; then
    removeLock;
    exit
  else
    removeLock;

    printCyan "\n\nIf you want to deploy other version, please insert it's number.";
    printCyan "Number of last working version is $currentVersion";
    printCyan "Print n to exit from the script.";
	notify;
    read answer

    if [[ $answer == "n" ]]; then
      exit
    else
      ./update-$app-version.sh $module $answer $user
    fi
  fi
}