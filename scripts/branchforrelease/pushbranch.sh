#!/bin/bash

RCol='\x1B[0m'; Red='\x1B[0;31m'; Gre='\x1B[0;32m'; Yel='\x1B[0;33m'; Blu='\x1B[0;34m';


usage() {
	echo "Usage: pushbranch.sh <branch-name>"
}

if [  $# -le 0 ] 
then
	usage
	exit 1
fi
declare -a allrepos=("openmrs-module-bahmniapps" "jss-config" "openerp-atomfeed-service" "OpenElis"
 "bahmni-core" "bahmni-java-utils" "openerp-modules" "openerp-functional-tests" "openmrs-distro-bahmni"
 "bahmni-environment" "emr-functional-tests" "default-config" "bahmni-reports" "possible-config" "search-config")

cd ~/allrepos

for repo in "${allrepos[@]}"
do
   cd $repo
   echo -e "${Gre}Pushing branch $1 for $repo ${RCol}"
   git push origin "release-$1"
   cd ..
done
