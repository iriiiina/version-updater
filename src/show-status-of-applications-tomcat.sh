#!/bin/bash

############################################################################
### This is script for listing deployed applications on Tomcat 8 server  ###
### It doesn't require modifications and can be used out-of-the-box      ###
###                                                                      ###
### Author: Irina Ivanova, iriiiina@gmail.com                            ###
### Last modified: 4.02.2016, v2.0                                       ###
### Version-updater manual:                                              ###
###    https://iriiiina.gitbooks.io/version-updater-manual/content/      ###
############################################################################

# Import global viariables and functions
. version-updater/conf.sh
. version-updater/functions.sh

curl -silent $tomcatManager/list | sort | grep ^/ | awk '{ gsub("running", "\033[32m&\033[0m");
                                                           gsub("stopped", "\033[31m&\033[0m");
                                                           gsub("\\:[0-9]+", "\033[34m&\033[0m");
                                                           gsub("^/.+:", "\033[36m&\033[0m");
                                                           gsub("[0-9]+.[0-9]+.[0-9]+.[0-9]+$", "\033[33m&\033[0m");
                                                           print }'

notify;
