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
# Variables and functions that are taken from these global files - if needed you can define them here
#    $tomcatManager
#    notify()
. version-updater/conf.sh
. version-updater/functions.sh

# You can modife regular expressions here according to your needs
curl -silent $tomcatManager/list | sort | grep ^/ | awk '{ gsub("running", "\033[32m&\033[0m");
                                                           gsub("stopped", "\033[31m&\033[0m");
                                                           gsub("\\:[0-9]+", "\033[34m&\033[0m");
                                                           gsub("^/.+:", "\033[36m&\033[0m");
                                                           gsub("[0-9]+.[0-9]+.[0-9]+.[0-9]+$", "\033[33m&\033[0m");
                                                           print }'

notify;