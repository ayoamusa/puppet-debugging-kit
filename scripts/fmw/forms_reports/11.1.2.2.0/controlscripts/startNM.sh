#!/usr/bin/env bash

########################################################
#Created by Greg Kenney, USDA Forest Service 12/02/2014#
########################################################

# startNM.sh (for Red Hat EL 6)

#Script to start NodeManager 

#Start NodeManager
   echo "Starting NodeManager...."
      #Set the WLS Domain variables
      export MW_HOME=/opt/oracle/fmw/product/11.1.2
      export DOMAIN_NAME=frdomain
      export DOMAIN_HOME=$MW_HOME/user_projects/domains/frdomain
      . $DOMAIN_HOME/bin/setDomainEnv.sh
      export JAVA_HOME=$MW_HOME/jdk
      export PATH=$PATH:$JAVA_HOME/bin
      export WL_HOME=$MW_HOME/wlserver_10.3
#Check to see if it is already running before attempting to start it
   nmport=`grep "ListenPort" $WL_HOME/common/nodemanager/nodemanager.properties |cut -d "=" -f2`
   nmnetstat=`netstat -an |grep "LISTEN" |grep -oc ":$nmport"`
   if [ $nmnetstat -gt 0 ] ; then
      echo "Already running."
   else
      #start NodeManager
      nohup $WL_HOME/server/bin/startNodeManager.sh >/dev/null 2>&1 &
      #Wait until we see that it is running before moving on
      let duration=0
      while [ $nmnetstat -lt 1 ] ; do
         nmnetstat=`netstat -an |grep "LISTEN" |grep -oc ":$nmport"`
         echo -n "."
         sleep 1
         let duration=$duration+1
         #adjust the value below for timeout duration (secs)
         if [ $duration -eq "300" ] ; then
            echo
            echo "Script timed out after $duration seconds."
            exit 1
         fi
      done
      echo Done.
   fi
