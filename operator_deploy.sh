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

checkNamespace() {


	printInfo "Please enter the namespace where Redis Enterprise Cluster will be deployed"
	read NAMESPACE

	oc get namespace "${NAMESPACE}" > /dev/null 2>&1
	OUT=$?

   	    if [ ${OUT} -ne 0 ]; then
	      printError "Namespace '${NAMESPACE}' not found. Please enter proper Namespace."
	      exit 1
            else
	      printInfo "This Namespace exists, so the Redis Operator will be deployed in here"
	    fi
}	


replaceValues() {
	
	GIT_DIR=$(pwd)
	
	printInfo "Installer is updating values.yaml file with the proper information"
	
	sed -i -e "s/\(namespace: \)\(.*\)/\1"${NAMESPACE}"/g" ${GIT_DIR}/redis_operator/values.yaml  # this regex replaces the namespace in values.yaml file, after "namespace: " it inserts actual user entered namespace 
	sleep 2
}


deployOperatorHelm() {
	
	printInfo "The installer will deploy Redis Enterprise Operator resources with the Helm chart"
	
	helm upgrade --install redisoperator ${GIT_DIR}/redis_operator/
}

approveInstallPlan() { 

	printInfo "Redis Enterprise Operator subscription was created. Would you like to approve the Install Plan so it can provision all required resources? Please answer \"yes\" or \"no\""
	read USER_ANSWER

	if [ "${USER_ANSWER}" == "yes" ]; then
		
	    INSTALL_PLAN=$(oc get installplan -n "${NAMESPACE}" | awk '{print $1}' | tail -n1)
	   
            printInfo "Install Plan exists and will be approved now."
            oc patch installplan "${INSTALL_PLAN}" -p '{"spec":{"approved":true}}' --type=merge
	
	else
	    printError "Your answered \"no\", then approve the plan later when you have evaluated resources."
	    exit 1
	fi
}

finalStep() {
	printInfo "The installer has completed Redis Enterprise Operator deployment"
	exit 1
}

checkNamespace
replaceValues
deployOperatorHelm
approveInstallPlan
finalStep
