#!/usr/bin/env bash

############################################
##    ===============================     ##
##    Interim Patch for Bug: 18277370     ##
##    ===============================     ##
##                                        ##
##          Date: Feb 22, 2014            ##
##     ---------------------------------  ##
##      Platform Patch for   : Generic    ##
##      Product Patched      : Oracle JDev##
##      Product Version      : 11.1.1.7.0 ##
##                                        ##
##        Bugs fixed by this patch:       ##
## 17236592:IE11 SUPPORT  ADF APPS DON'T  ##
## LOAD WITH IE11                         ##
##                                        ##
## 17672146:IE11- HV DOESN'T GET DISPLAYED## 
## AT RUNTIME                             ##
##                                        ##
## 17723555:IE-11 CODE EDITOR - FIND AND  ##
## REPLACE DIALOG - ALL FEATURES ARE BROKN##
##                                        ##
## 17723794:IE-11 RICH TEXT EDITOR DOESN'T## 
## WORK                                   ##
##                                        ##
## 17776065:WITH FF25, ALL RTL TEXT IS    ##
## MISALIGNED FOR DVT HTML5 COMPONENTS    ##
##                                        ##
## 17814372:IE-11 REMOVED API - BROKE     ##
## INSERT HTML IN RTE                     ##
##                                        ##
## 17814870:UPDATE RELEASE NOTES TO       ##
## INCLUDE IE11                           ##
##                                        ##
## 18176711:EM  MENU COMPONENTS DO NOT    ##
## WORK WITH MOUSE  IN IE 9               ##
############################################

#####################################
##        Script Created By        ##
## Greg Kenney USDA Forest Service ##
##         December 05, 2014        ##
#####################################

# "patch18277370.sh -i" installs the patch
# "patch18277370.sh -r" removes the patch

#script name
nam="Patch18277370: "
name="Patch18277370"

#capture command line parameter
param=$1

#capture current time and date
NOW=$(date +"%m%d%y%H%M%S")

#define log file name
LOGFILE=$name\_$NOW.log

{

###################
##BEGIN FUNCTIONS##
###################

isoracle()
{
# Check for correct user
   # If current user is not oracle, abort now                      
   if [ "$USER" != "oracle" ] ; then
      echo                                                  
      echo $nam"Must be user 'oracle' to run this script."     
      #exit gracefully with exit status 1 (error)
      echo
      exit 1
   fi
}

setvar()
{
# Set environment variables
   #WebLogic base directory
   basehome=/opt/oracle
   #WebLogic middleware home directory
   mwhome="$basehome/fmw/product/11.1.2"
   #session variable for mwhome
   wlshome=$mwhome/wlserver_10.3
   #filename of patch
   patchfile="p18277370_111170_Generic.zip"
   #unique patch number
   patchnum=18277370
   #location of patch zip and script
   media_src=/fslink/sysinfra/oracle/media/fmw/forms_reports/11.1.2.2.0/18277370
   script_src=/fslink/sysinfra/oracle/scripts/fmw/forms_reports/11.1.2.2.0
   oraclehome=$mwhome/oracle_common
   opatchdir=$oraclehome/OPatch
   export ORACLE_HOME=$mwhome/oracle_common
   export PATH=$PATH:$ORACLE_HOME:$ORACLE_HOME/OPatch
}

isweblogic()
{
# Check that WebLogic 11g is installed
   # If WebLogic is not installed, abort now
   if [ ! -d $mwhome ] ; then
      echo $nam
      echo $nam"WebLogic is not installed. Aborted."
      #exit gracefully with exit status 1 (error)
      exit 1
   fi
}

checkpids()
{
# Check for midtier PIDs
   echo
   echo $nam"Checking for running processes..."
   #count pids
   pidcount=`ps -eadf |grep -v grep |grep -c "$basehome/fmw"`
}

stopstack()
{
   #stop the midtier
   echo
   echo $nam"Shutting down the WebLogic Middle Tier..."
   echo
   $mwhome/stopFMW.sh
   echo
   echo $nam"Please wait..."
   #sleep for 10 seconds to wait for pids to end
   sleep 10
   if [ $pidcount -gt 0 ] ; then
      echo
      echo $nam"Cleaning up remaining midtier processes..."
      #capture a count of running midtier pids
      pidcount=`ps -eadf |grep -v grep |grep -c "$basehome/fmw"`
      #capture exact pid numbers
      pidnum=`ps -eadf |grep "$basehome/fmw" |grep -v grep |awk '{print $2}'`
      #forefully kill midtier processes
      kill -9 $pidnum >/dev/null 2>&1
      echo $nam"Done."
   fi
}

startstack()
{
   #Start the weblogic midtier
   echo
   echo $nam"Starting the WebLogic Middle Tier..."
   $mwhome/startFMW.sh
   echo
}

copypackage()
{
#This procedure copies the install package from the source dir
   echo
   echo $nam"Copying install package..."
   #make sure patch file exists first
   if [ -e "$media_src/$patchfile" ] ; then
      #copy command
      cp $media_src/$patchfile $opatchdir
      #set copy flag
      copy="true"
      echo $nam"Done."
   else
      echo
      echo "Unable to locate install package."
      #set copy flag
      copy="false"
   fi
}

unpack()
{
#This procedure unpacks the archive
      echo
      echo $nam"Unpacking..."
   #make sure patch file exists first
   if [ -e "$opatchdir/$patchfile" ] ; then
      #navigate to opatch dir
      cd $opatchdir
      #unzip command
      unzip -o ./$patchfile
      #cleanup patch file
      rm -f $opatchdir/$patchfile
      #set unpack flag
      unpack="true"
      echo $nam"Done."
   else
      echo
      echo "Unable to locate install package in OPatch."
      #set upack flag
      unpack="false"
   fi
}

isinstalled()
{
#This procedure verifies if the patch is installed
   value1=`$opatchdir/opatch lsinventory |grep -c $patchnum`
   if [ "$value1" -gt "0" ] ; then
      #set installed flag
      installed="true"
   else
      #set installed flag
      installed="false"
   fi
}

install()
{
#This procedure installs the new Patch
   echo
   echo $nam"Preparing to install the patch..."
   #confirm patch dir exists
   if [ -d "$opatchdir/$patchnum" ] ; then
      #navigate to patch dir
      cd $opatchdir/$patchnum/oui/$patchnum
      echo
      #opatch install command
      opatch apply -silent
      echo
      echo $nam"Done."
      #set install flag
      ins="true"
   #invoked if unable to locate patch dir
   else
      echo $nam"Unable to locate patch directory."
      #set install flag
      ins="false"
   fi
}

rollback()
{
#This procedure will rollback the patch
   echo
   echo $nam"Preparing to rollback the patch..."
   #confirm patch dir exists
   if [ -d "$opatchdir/$patchnum" ] ; then
      #navigate to patch dir
      cd $opatchdir/$patchnum/oui/$patchnum
      echo
      #rollback command
      opatch rollback -id $patchnum -silent 
      echo
      echo $nam"Done."
      #set rollback flag
      rollback="true"
   #invoked if unable to locate patch dir
   else
      echo $nam"Unable to locate patch directory."
      #set rollback flag
      rollback="false"
   fi
}

main()
{
#This procedure executes based on command line parameter
   echo 
   # if command line includes -i
   if [ "$param" == "-i" ] ; then
      echo $nam"Initiating Patch Update..."
      #confirm user is oracle
      isoracle
      #set variables
      setvar
      #confirm weblogic installed
      isweblogic
      #check if patch is already installed
      isinstalled
      if [ "$installed" == "true" ] ; then
         echo
         echo $nam"Patch is already installed."
         exit 1
      fi
      #copy the install package
      copypackage
      #abort if copy operation fails
      if [ "$copy" == "false" ] ; then
         exit 1
      fi
      #unpack the install package
      unpack
      #abort if unpack operation fails
      if [ "$unpack" == "false" ] ; then
         exit 1
      fi
      #check for running midtier pids
      checkpids
      #shutdown midtier if it is running
      if [ "$pidcount" -gt "0" ] ; then
         #stop midtier
         stopstack
      fi
      #install the patch
      install
      #abort if install fails to run
      if [ "$ins" == "false" ] ; then
         #restart midtier
         startstack
         exit 1
      fi
      #restart midtier
      startstack
      #confirm that the patch is installed via opatch
      isinstalled
      #if opatch does not show the patch installed, abort
      if [ "$installed" == "false" ] ; then
         exit 1
      fi
      #announce patch completion
      echo
      echo $nam"Completed."
   #if command line includes -r
   elif [ "$param" == "-r" ] ; then
      echo $nam"Initiating Patch Rollback..."
      #confirm user is oracle
      isoracle
      #set variables
      setvar
      #confirm weblogic installed
      isweblogic
      #check if it is already installed
      isinstalled
      if [ "$installed" == "false" ] ; then
         echo
         echo $nam"Patch is not installed."
         exit 1
      fi
      #check for running midtier pids
      checkpids
      #shutdown midtier if it is running
      if [ "$pidcount" -gt "0" ] ; then
         #stop midtier
         stopstack
      fi
      #rollback the patch
      rollback
      #abort if rollback fails to run
      if [ "$rollback" == "false" ] ; then
         #restart midtier
         startstack
         exit 1
      fi
      #restart midtier
      startstack
      #check if patch is still installed via opatch
      isinstalled
      #if patch is still installed then rollback failed
      if [ "$installed" == "true" ] ; then
         exit 1
      fi
      #remove patch dir
      rm -rf $opatchdir/$patchnum
      #announce completion
      echo
      echo $nam"Completed."
   #if no command line parameter then abort 
   else
      echo
      echo "Required parameter missing. Specify [-i] for install or [-r] for remove."
      #exit gracefully with exit status 1 (error)
      exit 1
   fi
}

#################
##END FUNCTIONS##
#################


########################
########################
main
########################
########################

#output to the log 
} 2>&1 | tee /tmp/$LOGFILE
   #preserve exit status
   estatus=${PIPESTATUS[0]}
   #store result based on exit code
   if [ "$estatus" == "0" ] ; then
      result=":Success"
   else
      result=":Failed"
   fi
   #announce log file and exit status success/fail
   echo
   echo "" >>/tmp/$LOGFILE
   echo "Log file for this script is /tmp/$LOGFILE" >>/tmp/$LOGFILE
   echo "" >>/tmp/$LOGFILE
  # echo "Log file for this script is /tmp/$LOGFILE" 
   echo "" >>/tmp/$LOGFILE
   #exit script gracefully with correct exit code
   echo "Exit Code $estatus $result" >>/tmp/$LOGFILE
   echo "" >>/tmp/$LOGFILE
   #echo
   #echo "Exit code $estatus $result"
   #echo
   exit $estatus

