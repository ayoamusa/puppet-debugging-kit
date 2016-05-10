#!/usr/bin/env bash

########################################################
#Created by Greg Kenney, USDA Forest Service 12/02/2014#
########################################################

# startAdmin.sh (for Red Hat EL 6)

#Script to start WLS AdminServer

#Start the AdminServer
   echo "Starting the AdminServer...."
#Check to see if it is already running before attempting to start it
   asnetstat=`netstat -an |grep "LISTEN" |grep -oc ":1810"`
   if [ $asnetstat -gt 0 ] ; then
      echo "Already running."
   else
      #Set the WLS Domain variables
      export MW_HOME=/opt/oracle/fmw/product/11.1.2
      export DOMAIN_NAME=frdomain
      export DOMAIN_HOME=$MW_HOME/user_projects/domains/frdomain
      . $DOMAIN_HOME/bin/setDomainEnv.sh
      export JAVA_HOME=$MW_HOME/jdk
      export PATH=$PATH:$JAVA_HOME/bin
      #start the adminserver
      nohup $DOMAIN_HOME/bin/startWebLogic.sh >/dev/null 2>&1 & 
      #Wait until we see that it is running before moving on
      let duration=0
      while [ $asnetstat -lt 1 ] ; do
         asnetstat=`netstat -an |grep "LISTEN" |grep -oc ":1810"`
         echo -n "."
         sleep 1
         let duration=$duration+1
         #adjust the value below for timeout duration (secs)
         if [ $duration -eq "600" ] ; then
            echo
            echo "Script timed out after $duration seconds."
            exit 1
         fi
      done
      echo Done.
   fi
