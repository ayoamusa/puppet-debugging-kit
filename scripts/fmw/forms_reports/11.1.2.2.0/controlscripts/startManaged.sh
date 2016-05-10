#!/usr/bin/env bash

########################################################
#Created by Greg Kenney, USDA Forest Service 12/02/2014#
########################################################

# startManaged.sh (for Red Hat EL 6)

#Script to start all Managed Servers
   echo "Starting WebLogic Managed Servers..."

      #Set the WLS Domain variables
      export MW_HOME=/opt/oracle/fmw/product/11.1.2
      export DOMAIN_NAME=frdomain
      export DOMAIN_HOME=$MW_HOME/user_projects/domains/frdomain
      . $DOMAIN_HOME/bin/setDomainEnv.sh
      export JAVA_HOME=$MW_HOME/jdk
      export PATH=$PATH:$JAVA_HOME/bin
      export WL_HOME=$MW_HOME/wlserver_10.3

#Make sure the Node Manager is running
   nmport=`grep "ListenPort" $WL_HOME/common/nodemanager/nodemanager.properties |cut -d "=" -f2`
   nmnetstat=`netstat -an |grep "LISTEN" |grep -oc ":$nmport"`
   if [ $nmnetstat -lt 1 ] ; then
      echo "The Node Manager must be running to perform startup actions."
      echo "Script aborted."
      exit
   fi

#Make sure the AdminServer is running
   asnetstat=`netstat -an |grep "LISTEN" |grep -oc ":1810"`
   if [ $asnetstat -lt 1 ] ; then
      echo "The AdminServer must be running to perform startup actions."
      echo "Script aborted."
      exit
   fi

#Start WLS Managed Servers
   #launch jython script to start all managed servers
   nohup java weblogic.WLST $MW_HOME/strmanaged.jy >/dev/null 2>&1 &
   #Wait until we see that it is running before moving on
   let duration=0
   let jypid=1
   while [ $jypid -gt "0" ] ; do
      let jypid=`ps -ef |grep -v grep |grep -c "strmanaged.jy"`
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
