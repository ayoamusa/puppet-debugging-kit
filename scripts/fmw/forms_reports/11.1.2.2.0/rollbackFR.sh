#!/usr/bin/env bash

########################################################
#Created by Greg Kenney, USDA Forest Service 12/02/2014#
########################################################

###################
# Script Name    ##
# rollbackFR.sh  ##
###################

# (for Red Hat EL 6)

#############################################
####    Fusion Middleware/WebLogic 11g   ####
#### Forms,Reports,HTTPServer,FMWControl ####
####         Rollback script             ####
#############################################

#capture current time and date
NOW=$(date +"%m%d%y%H%M%S")

#define log file name
LOGFILE=rollbackFR\_$NOW.log

{

#set base dir level
ORACLE_BASE=/opt/oracle

#procedure to set some static variables
SET_VAR ()
{
#set session variables
   ORACLE_BASE=/opt/oracle
   MW_HOME=/opt/oracle/fmw/product/11.1.2 ; export MW_HOME
   JAVA_HOME=/opt/oracle/fmw/product/11.1.2/jdk ; export JAVA_HOME
   ORACLE_HOME=/opt/oracle/fmw/product/11.1.2/oracle_fr ; export ORACLE_HOME
   ORACLE_INSTANCE=/opt/oracle/fmw/product/11.1.2/instances/frinst_1 ; export ORACLE_INSTANCE
   DOMAIN_NAME=frdomain
   DOMAIN_HOME=/opt/oracle/fmw/product/11.1.2/user_projects/domains/frdomain
   PATH=/opt/oracle/fmw/product/11.1.2/jdk:$PATH:/opt/oracle/fmw/product/11.1.2/oracle_fr/bin:/opt/oracle/fmw/product/11.1.2/oracle_fr ; export PATH
}

#procedure to remove middleware home
RMV_MW ()
{
   #obtain user confirmation to proceed
   #wait for YyNn input only
   while [ "$proceed" != "Y" -a "$proceed" != "y" -a "$proceed" != "N" -a "$proceed" != "n" ] ; do
      echo 
      read -p "All files in $ORACLE_BASE/fmw will be erased. Continue (y/n)? " proceed;
   done
   if [ "$proceed" == "N" -o "$proceed" == "n" ] ; then
      echo 
      echo "Rollback aborted by user."
      exit
   #user input Yy so proceed with rollback operation
   elif [ "$proceed" == "Y" -o "$proceed" == "y" ] ; then
      echo
      echo "Initiating Middleware removal..."
      echo
      echo "Stopping all running Midtier processes..."
      #stop all FMW/WLS running processes
      pidrun=`ps -ef |grep "$MW_HOME" |grep -v "grep" |awk '{print $2}'`
      if [ ! -z "$pidrun" ] ; then
         for p in $pidrun
         do
            kill -9 "$p" > /dev/null 2> /dev/null || :
         done
      fi
      echo "done."
      #remove RC entry
      RMV_RC
      #cleanup root files and pids from oracle instance
      RMV_INST
      #remove entire MW_HOME
      echo
      echo "Removing Middleware directory..."
      rm -rf $ORACLE_BASE/fmw/product
      echo "done."
      #remove oraInventory
      echo
      echo "Removing oraInventory..."
      rm -rf $ORACLE_BASE/fmw/oraInventory
      echo "done."
   fi
}

#procedure for removing files/pids owned by root
RMV_INST ()
{
   echo
   echo "Cleaning up remaining instance files and pids..."
   if [ -d "$ORACLE_HOME" ] ; then
      echo "#!/usr/bin/env bash" >$ORACLE_HOME/root.sh
      #delete ohs pids running as root
      pidrun=`ps -ef |grep "$MW_HOME" |grep -v "grep" |awk '{print $2}'`
      if [ ! -z "$pidrun" ] ; then
         for p in $pidrun
         do
            echo "kill -9 $p > /dev/null 2> /dev/null || :" >>$ORACLE_HOME/root.sh
         done
      fi
      if [ -d "$ORACLE_INSTANCE" ] ; then
         #delete instance files
         echo "rm -rf $ORACLE_INSTANCE" >>$ORACLE_HOME/root.sh
      fi
      #make executable
      chmod u+x $ORACLE_HOME/root.sh
      #run as root
      sudo $ORACLE_HOME/root.sh
   fi
   echo "done."
}

#procedure for removing startup/shutdown script (auto start on boot)      
RMV_RC ()
{
   if [ -f "$MW_HOME/updateRC.sh" ] ; then
      if [ -f "/etc/init.d/FSWeblogic" ] ; then
         #execute removal script with sudo
         sudo $MW_HOME/updateRC.sh remove
      fi
   fi
}

##############################
####BEGIN PROCEDURES##########
##############################
echo
echo "Executing script for WebLogic Midtier removal..."
if [ -d "$ORACLE_BASE/fmw/product" ] ; then
   SET_VAR
   RMV_MW
else
   echo
   echo "WebLogic Midtier is not installed."
fi
##############################
####END PROCEDURES############
##############################
echo
echo "Script completed."

#output to the log
} 2>&1 | tee /tmp/$LOGFILE
echo
echo "Log file for this script is /tmp/$LOGFILE"
exit
