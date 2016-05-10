#!/usr/bin/env bash

########################################################
#Created by Greg Kenney, USDA Forest Service 12/02/2014#
########################################################

# storePass.sh (for Red Hat EL 6)

#Script to store the fsweblogic password after a password change
#This is required to update boot.properties and keystores
   echo
   echo "Initiating password store script..."

#procedure for defining session variables
DEF_VAR ()
{
   #Set env variables
   export MW_HOME=/opt/oracle/fmw/product/11.1.2
   export DOMAIN_NAME=frdomain
   export $MW_HOME/user_projects/domains/$DOMAIN_NAME
   . $DOMAIN_HOME/bin/setDomainEnv.sh
   export JAVA_HOME=$MW_HOME/jdk
   export PATH=$PATH:$JAVA_HOME/bin
   export ORACLE_HOME=$MW_HOME/oracle_fr
   export ORACLE_INSTANCE=$MW_HOME/instances/frinst_1
}

#procedure for creating new boot.properties
BOOT_PROP ()
{
#create and copy boot.properties
   echo
   echo "Creating boot.properties..."
   echo
   wpwd=""
   #ask user for the new password
   while [ -z "$wpwd" ] ; do
   read -s -p "What is the new password for user 'fsweblogic': " wpwd
   echo
   done
   wpwd2=""
   #ask user to confirm new password
   while [ -z "$wpwd2" ] ; do
   read -s -p "Confirm password: " wpwd2
   echo
   done
   if [ "$wpwd" == "$wpwd2" ] ; then
      #store password
      wpwd="$wpwd2"
   else
      echo
      echo "Password does not match."
      echo
      #password does not match so ask the user again
      BOOT_PROP
   fi
   echo
   #make a backup of the existing boot.properties
   mv $DOMAIN_HOME/servers/AdminServer/security/boot.properties $DOMAIN_HOME/servers/AdminServer/security/boot.properties.orig
   #create the new boot.properties
   echo "username=fsweblogic" >$DOMAIN_HOME/servers/AdminServer/security/boot.properties
   echo "password=$wpwd" >>$DOMAIN_HOME/servers/AdminServer/security/boot.properties
   #stop the adminserver
   $MW_HOME/stopAdmin.sh
   #start the adminserver to encrypt boot.properties
   $MW_HOME/startAdmin.sh
   #make sure the adminserver comes back up
   asnetstat=`netstat -an |grep "LISTEN" |grep -oc ":1810"`
   if [ $asnetstat -lt 1 ] ; then
      echo
      #if it doesnt come back up then there was a problem
      echo "The AdminServer did not restart. Script aborted."
      #remove the new boot.properties
      rm -f $DOMAIN_HOME/servers/AdminServer/security/boot.properties
      #restore the original boot.properties
      mv $DOMAIN_HOME/servers/AdminServer/security/boot.properties.orig $DOMAIN_HOME/servers/AdminServer/security/boot.properties
      #abort the script
      exit 1
   else
      #the new boot.properties is good so we can remove the old file
      echo
      rm -f $DOMAIN_HOME/servers/AdminServer/security/boot.properties.orig
   fi
}

#procedure for storing encrypted uname/pword for Managed servers
STOR_CFG ()
{
#jython script for storing user config and key file
   echo
   echo "Running WLS storeconfig script..."
   #if a store file exists, remove it
   if [ -e "$DOMAIN_HOME/security/userconfigfile.secure" ] ; then
      rm -f $DOMAIN_HOME/security/userconfigfile.secure
   fi
   #if the key file exists, remove it
   if [ -e "$DOMAIN_HOME/security/userkeyfile.secure" ] ; then
      rm -f $DOMAIN_HOME/security/userkeyfile.secure
   fi
   #temporarily copy the boot.properties to the domain dir
   cp $DOMAIN_HOME/servers/AdminServer/security/boot.properties $DOMAIN_HOME
   #create an answer file to avoid user prompting
   echo "y" >$MW_HOME/answer.txt
   #execute the jython script for storing the uname/pword
   cd $DOMAIN_HOME
   nohup java weblogic.WLST $MW_HOME/storeconfig.jy <$MW_HOME/answer.txt >/dev/null 2>&1 
   #cleanup temporary files
   rm -f $MW_HOME/answer.txt
   rm -f $DOMAIN_HOME/boot.properties
   echo "done."
}

#######################################################
##################Run Procedurees######################
#######################################################
DEF_VAR
BOOT_PROP
STOR_CFG
#######################################################
##################End Procedures#######################
#######################################################

echo
echo "Script completed."
