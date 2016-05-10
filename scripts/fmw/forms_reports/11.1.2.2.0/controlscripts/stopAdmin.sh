#!/usr/bin/env bash

########################################################
#Created by Greg Kenney, USDA Forest Service 12/02/2014#
########################################################

# stopAdmin.sh (for Red Hat EL 6)

#Script to shutdown the AdminServer

   echo "Shutting down the AdminServer..."

#Make sure the AdminServer is running
   asnetstat=`netstat -an |grep "LISTEN" |grep -oc ":1810"`
   if [ $asnetstat -lt 1 ] ; then
      echo "Already down."
   else
      #Set the WLS Domain variables
      export MW_HOME=/opt/oracle/fmw/product/11.1.2
      export DOMAIN_NAME=frdomain
      export DOMAIN_HOME=$MW_HOME/user_projects/domains/frdomain
      . $DOMAIN_HOME/bin/setDomainEnv.sh
      export JAVA_HOME=$MW_HOME/jdk
      export PATH=$PATH:$JAVA_HOME/bin 
      #stop the adminserver
      nohup $DOMAIN_HOME/bin/stopWebLogic.sh >/dev/null 2>&1 &
      #Wait until we see that it is stopped before moving on
      let duration=0
      while [ $asnetstat -gt 0 ] ; do
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
      echo "Done."
   fi
