#!/bin/bash

printInfo() {
  green=`tput setaf 2`
  reset=`tput sgr0`
  echo "${green}[INFO]: ${1} ${reset}"
}

printWarning() {
  yellow=`tput setaf 3`
  reset=`tput sgr0`
  echo "${yellow}[WARNING]: ${1} ${reset}"
}

printError() {
  red=`tput setaf 1`
  reset=`tput sgr0`
  echo "${red}[ERROR]: ${1} ${reset}"
}


createNamespace() {

        
        printInfo "Please enter the namespace where Redis Enterprise Cluster will be deployed"
        
        read NAMESPACE
        
        oc new-project "${NAMESPACE}"
	
	sleep 2
}


applySCC() {
        
        GIT_DIR=$(pwd)
        
        printInfo "The installer is applying required scc for the deployment of Redis Enterprise Cluster"
        
        oc apply -f "${GIT_DIR}"/openshift/scc.yaml
	
	sleep 2
}


givePermissions() {

        printInfo "The installer is applying permissions to the scc in the newly created namespace"

        oc adm policy add-scc-to-group redis-enterprise-scc system:serviceaccounts:"${NAMESPACE}"
	
	sleep 2
}


finish () {
	
	printInfo "The installer finished provisioning required settings for Redis Enterprise Cluster deployment"
	exit 1
}

createNamespace
applySCC
givePermissions
finish
