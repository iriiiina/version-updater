#!/bin/bash

###########################################################################
### This is file with Tomcat 8 specific global functions                ###
### You may want to make some changes here – see comments for details   ###
###                                                                     ###
### Author: Irina Ivanova, iriiiina@gmail.com                           ###
### Last modified: 13.07.2016, v6.4                                     ###
### Version-updater manual:                                             ###
###    https://iriiiina.gitbooks.io/version-updater-manual/content/     ###
###########################################################################

function shutdown() {
  printInfo "Shutting server down";
  ./$tomcatBin/shutdown.sh | wc -l
  sleep 10

  down=$(curl "$tomcatManager/list" | grep "503 Service Temporarily Unavailable")

  if [[ "$down" == "" ]]; then
    printError "can't shutdown Tomcat server";
    log "ERROR: can't shitdown Tomcat server";
    removeLock;
    exit
  else
    printOk "Tomcat server is down";
    log "OK: Tomcat server is down";
  fi
}

function startup() {
  printInfo "Starting server up";
  ./$tomcatBin/startup.sh | wc -l
  sleep 10

  up=$(curl "$tomcatManager/list" | grep "^/:running:")

  if [[ "$up" == "" ]]; then
    printError "can't startup Tomcat server";
    log "ERROR: can't startup Tomcat server";
    removeLock;
    exit
  else
    printOk "Tomcat server is up";
    log "OK: Tomcat server is up";
  fi
}

function getCurrentVersion() {
  printInfo "Getting current version of $moduleName$tomcatManagerName";

  # You may want to change regular expression here, according to your versioning pattern
  currentVersion=$(curl "$tomcatManager/list" | grep "^/$moduleName:" | grep -o --regexp='[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*')

  if [[ "$currentVersion" == "" ]]; then
    printWarning "can't find current version of $moduleName$tomcatManagerName";
  else
    printOk "current version of $moduleName$tomcatManagerName is $currentVersion";
  fi
}

function checkNumberOfDeploys() {
  printInfo "Checking number of deploys of $moduleName$tomcatManagerName";
  numberOfDeploys=$(curl "$tomcatManager/list" | grep "^/$moduleName:" | wc -l)

  if [[ $numberOfDeploys == 1 ]]; then
    printOk "at the moment only 1 version of $moduleName$tomcatManagerName is deployed";
  elif [[ $numberOfDeploys == 0 ]]; then
    printWarning "can't find any deployed version of $moduleName$tomcatManagerName";
  else
    printWarning "there is more than 1 versions of $moduleName$tomcatManagerName is deployed";
  fi
}

function deployModuleFromBatch() {
  echo -e "\n----------batch-update: $fileName----------" >> $log

  isParallelDeployment $parallel;

  getCurrentVersion;

  if [[ $isVersionCheckRequired == "Y" ]]; then
    compareVersions;
  fi

  printInfo "Downloading $fileName file";

  wget $link

  if test -e "$fileName"; then
    printOk "file $fileName is downloaded";
    log "OK: $fileName is downloaded";

    checkNumberOfDeploys;

    if [[ $parallel == "N" ]]; then
      undeploy;
    fi

    deploy;

    removeDownloadedFile;

    checkIsRunning;

    if [[ $isJiraIssueUpdateRequired == "Y" ]] && [[ $canUpdateJira -eq 0 ]]; then
        updateIssueSummary;
    fi

    printCyan "********************Update of $fileName is completed********************";

  else
    printError "can't download the $fileName file from $link";
    log "ERROR: $fileName is not downloaded from $link";
    downloadErrors+=($module-$version)
    printCyan "********************Update of $fileName is completed********************";
  fi
}

function deployBatchModulesProd() {
  echo -e "\n----------batch-update: $module-$version----------" >> $log

  isParallelDeployment $parallel;

  printInfo "Downloading file $fileName";

  wget $link

  if test -e "$fileName"; then
    printOk "file $fileName is downloaded";
    log "OK: $fileName is downloaded";

    # If name of $firstTomcatManagers and $secondTomcatManagers were renamed, you need to also rename them here
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

      if [[ $isJiraIssueUpdateRequired == "Y" ]] && [[ $canUpdateJira -eq 0 ]]; then
        updateIssueSummary;
      fi

      removeExistingFileWithSameName;

      printCyan "********************Update of $module-$version is completed********************";

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

      if [[ $isJiraIssueUpdateRequired == "Y" ]] && [[ $canUpdateJira -eq 0 ]]; then
        updateIssueSummary;
      fi

      removeExistingFileWithSameName;

      printCyan "********************Update of $module-$version is completed********************";

    # You may want to add more elif conditions here, if you have more that 2 Tomcat clusters

    else
      printError "can't find Tomcat Managers for cluster name $clusterName";
      log "ERROR: can't find Tomcat Managers for cluster name $clusterName";
    fi

  else
    printError "can't download the $fileName file from $link";
    log "ERROR: $fileName is not downloaded from $link";
    downloadErrors+=("$module-$version")
    printCyan "********************Update of $mdodule-$version is completed********************";
  fi
}

function undeploy() {
  if [[ $numberOfDeploys == 1 ]]; then
    printInfo "Undeploying old version $moduleName-$currentVersion$tomcatManagerName";

    undeploy=$(curl "$tomcatManager/undeploy?path=/$moduleName&version=$currentVersion")

    if echo "$undeploy" | grep -q "OK - Undeployed application at context path"; then
      printOk "old version $moduleName-$currentVersion$tomcatManagerName is undeployed";
      log "OK: $moduleName-$currentVersion$tomcatManagerName is undeployed";
      isUndeployed=1
    else
      echo $undeploy
      printError "can't undeploy old version $moduleName-$currentVersion$tomcatManagerName";
      log "ERROR: old version $moduleName-$currentVersion$tomcatManagerName is not undeployed";
      isUndeployed=0
      undeployWarnings+=("$module-$currentVersion$tomcatManagerName")
    fi
  else
    undeployWarnings+=("$module$tomcatManagerName")
  fi
}

function deploy() {
  printInfo "Deploying new version $moduleName-$version$tomcatManagerName";
  deploy=$(curl --upload-file "$fileName" "$tomcatManager/deploy?path=/$moduleName&version=$version&update=true")

  if echo "$deploy" | grep -q "OK - Deployed application at context path"; then
    printOk "$moduleName-$version$tomcatManagerName is deployed";
    log "OK: $moduleName-$version$tomcatManagerName is deployed";
    successDeploys+=("$module-$version$tomcatManagerName")

  else
    echo $deploy
    printError "can't deploy $moduleName-$version$tomcatManagerName. See logs for details";
    log "ERROR: $moduleName-$version$tomcatManagerName is not deployed";
    deployErrors+=("$module-$version$tomcatManagerName")
  fi
}

function checkIsRunning() {
  printInfo "Checking whether $moduleName-$version$tomcatManagerName is running";

  isRunning=$(curl "$tomcatManager/list")

  if echo "$isRunning" | grep -q "$moduleName:running" && echo "$isRunning" | grep -q "$moduleName##$version"; then
    printOk "$moduleName-$version$tomcatManagerName is running";
    log "OK: $moduleName-$version$tomcatManagerName is running";
  else
    printError "$moduleName-$version$tomcatManagerName is not running";
    log "ERROR: $moduleName-$version$tomcatManagerName is not running";
    runErrors+=("$module-$version$tomcatManagerName")
    canUpdateJira=1
  fi
}

function deployOtherVersion() {
  if echo "$isRunning" | grep -q "$moduleName:running" && echo "$isRunning" | grep -q "$moduleName##$version"; then
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
      if [[ $isAuthenticationRequired == "Y" ]]; then
        ./update-version-tomcat.sh $module $answer $user
      elif [[ $isAuthenticationRequired == "N" ]]; then
        ./update-version-tomcat.sh $module $answer
      fi
    fi
  fi
}
