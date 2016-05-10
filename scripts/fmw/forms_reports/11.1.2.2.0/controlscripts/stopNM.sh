#!/usr/bin/env bash

########################################################
#Created by Greg Kenney, USDA Forest Service 12/02/2014#
########################################################

# stopNM.sh (for Red Hat EL 6)

#Script to shutdown Node Manager
   MW_HOME=/opt/oracle/fmw/product/11.1.2
   WL_HOME=$MW_HOME/wlserver_10.3
   echo "Shutting down Node Manager..."

#Make sure the Node Manager is running
   nmport=`grep "ListenPort" $WL_HOME/common/nodemanager/nodemanager.properties |cut -d "=" -f2`
   nmnetstat=`netstat -an |grep "LISTEN" |grep -oc ":$nmport"`
   if [ $nmnetstat -lt 1 ] ; then
      echo "Already down."
      exit
   fi

#Shutdown Node Manager
   pidrun=`lsof -i :$nmport |awk '{print $2}' |grep -v "PID"`
   if [ -z "$pidrun" ] ; then
      echo "Already down."
   else
      kill -9 "$pidrun" > /dev/null 2> /dev/null || :
      echo "Done."
   fi
