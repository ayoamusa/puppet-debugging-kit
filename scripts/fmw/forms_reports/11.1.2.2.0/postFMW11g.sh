#!/usr/bin/env bash

########################################################
#Created by Greg Kenney, USDA Forest Service 12/02/2014#
########################################################

# postFMW11g.sh (for Red Hat EL 6)

#Script to handle post configuration tasks for FMW/WLS 11g

#capture current time and date
NOW=$(date +"%m%d%y%H%M%S")

#define log file name
LOGFILE=postFMW11g\_$NOW.log

{

#procedure to define all session variables
DEF_VAR ()
{
   #Set env variables
   export MEDIA_SRC=/fslink/sysinfra/oracle/media/fmw
   export SCRIPT_SRC=/fslink/sysinfra/oracle/scripts/fmw
   export MW_HOME=/opt/oracle/fmw/product/11.1.2
   export DOMAIN_NAME=frdomain
   export DOMAIN_HOME=/opt/oracle/fmw/product/11.1.2/user_projects/domains/frdomain
   . $DOMAIN_HOME/bin/setDomainEnv.sh
   export JAVA_HOME=/opt/oracle/fmw/product/11.1.2/jdk
   export PATH=$PATH:$JAVA_HOME/bin
   export ORACLE_HOME=/opt/oracle/fmw/product/11.1.2/oracle_fr
   export ORACLE_INSTANCE=/opt/oracle/fmw/product/11.1.2/instances/frinst_1
   OPMNLOC=$ORACLE_INSTANCE/config/OPMN/opmn

}

#procedure to fix some oracle files
FIX_SCRIPT()
{
   echo
   echo "Updating Oracle Home and Instance files..."
   #remove webcache entries from oracleRoot.sh if they exist
   if [ -f "$ORACLE_HOME/oracleRoot.sh" ] ; then
      #backup file
      mv $ORACLE_HOME/oracleRoot.sh $ORACLE_HOME/oracleRoot.old
      #remove entries
      sed -e '/webcache/d' -e '/Web Cache/d' $ORACLE_HOME/oracleRoot.old >$ORACLE_HOME/oracleRoot.sh
      #restore permissions
      chmod 700 $ORACLE_HOME/oracleRoot.sh
   fi
   #add Group directive to httpd.conf if it doesnt exist
   if [ `grep -c "Group oinstall" $ORACLE_INSTANCE/config/OHS/ohs1/httpd.conf` -lt 1 ] ; then
      #backup file
      mv $ORACLE_INSTANCE/config/OHS/ohs1/httpd.conf $ORACLE_INSTANCE/config/OHS/ohs1/httpd.orig
      #append to file
      sed '/User oracle/ a\
Group oinstall' $ORACLE_INSTANCE/config/OHS/ohs1/httpd.orig >$ORACLE_INSTANCE/config/OHS/ohs1/httpd.conf
      #restore permissions
      chmod 644 $ORACLE_INSTANCE/config/OHS/ohs1/httpd.conf
   fi
   echo "done."
}

FRMS_CFG ()
{
#fix jpi entry in formsweb.cfg to relax jre6u12 plugin requirement
   echo
   echo "Updating formsweb.cfg..."
   #backup current file but dont overwrite an existing backup
   if [ ! -e "$DOMAIN_HOME/config/fmwconfig/servers/WLS_FORMS/applications/formsapp_11.1.2/config/formsweb.backup" ] ; then
      cp $DOMAIN_HOME/config/fmwconfig/servers/WLS_FORMS/applications/formsapp_11.1.2/config/formsweb.cfg $DOMAIN_HOME/config/fmwconfig/servers/WLS_FORMS/applications/formsapp_11.1.2/config/formsweb.backup
   fi
   #create temp file with new changes
   sed -e 's/jpi_mimetype=application\/x-java-applet;jpi-version=1.6.0_12/jpi_mimetype=application\/x-java-applet/g' -e 's/jpi_codebase=http:\/\/java.sun.com\/update\/1.6.0\/jinstall-6-windows-i586.cab#Version=1,6,0,12/#jpi_codebase=http:\/\/java.sun.com\/update\/1.7.0\/jinstall-7u60-windows-i586.cab#Version=1,7,0,60/g' -e 's/jpi_download_page=http:\/\/java.sun.com\/products\/archive\/j2se\/6u12\/index.html/jpi_download_page=http:\/\/java.sun.com\/products\/archive\/j2se\/7u60\/index.html/g' -e 's/jpi_classid=clsid:CAFEEFAC-0016-0000-0012-ABCDEFFEDCBA/jpi_classid=clsid:CAFEEFAC-0017-0000-FFFF-ABCDEFFEDCBA/g'  $DOMAIN_HOME/config/fmwconfig/servers/WLS_FORMS/applications/formsapp_11.1.2/config/formsweb.cfg >$DOMAIN_HOME/config/fmwconfig/servers/WLS_FORMS/applications/formsapp_11.1.2/config/formsweb.temp
   #remove existing file
   rm -f $DOMAIN_HOME/config/fmwconfig/servers/WLS_FORMS/applications/formsapp_11.1.2/config/formsweb.cfg
   #rename temp file to formsweb.cfg
   mv $DOMAIN_HOME/config/fmwconfig/servers/WLS_FORMS/applications/formsapp_11.1.2/config/formsweb.temp $DOMAIN_HOME/config/fmwconfig/servers/WLS_FORMS/applications/formsapp_11.1.2/config/formsweb.cfg
   echo "done."
}

#procedure for running required post install root script
RUN_ROOT ()
{
#run $OH/oracleRoot.sh
   echo
   echo "Running $ORACLE_HOME/oracleRoot.sh"
   sudo $ORACLE_HOME/oracleRoot.sh
   echo "done."
}

#procedure for installing RC startup/shutdown script (auto start on boot)
CFG_RC ()
{
   #copy RC related files to MWHOME
   cp $SCRIPT_SRC/forms_reports/11.1.2.2.0/updateRC.sh $MW_HOME
   cp $SCRIPT_SRC/forms_reports/11.1.2.2.0/FSWeblogic $MW_HOME
   if [ -f "$MW_HOME/updateRC.sh" ] ; then
      if [ ! -f "/etc/init.d/FSWeblogic" ] ; then
         sudo $MW_HOME/updateRC.sh load
      fi
   fi
}

#procedure for fixing FMW Control (EM) problem with IE11
FIX_EM ()
{
   #apply patch to allow IE11 to work with FMW Control (EM)
   $SCRIPT_SRC/forms_reports/11.1.2.2.0/patch18277370.sh -i
}

#######################################################
##################Run Procedures######################
#######################################################
   if [ ! -d "/opt/oracle/fmw/product/11.1.2" ] ; then
      echo
      echo "The WebLogic Midtier is not installed. Script aborted."
      echo
      exit
   fi
   echo
   echo "Initiating Post Configuration Tasks..."
   DEF_VAR     #defines variables
   FIX_SCRIPT  #updates a few oracle files
   RUN_ROOT    #runs necessary post-install root operations
   FRMS_CFG    #updates forms configuration files
   CFG_RC      #installs and activates runtime scripts
   FIX_EM      #fixes issue with IE11 and FMW Control (EM)
#######################################################
##################End Procedures#######################
#######################################################
echo
echo "Script completed."

#output to the log
} 2>&1 | tee /tmp/$LOGFILE
echo
echo "Log file for this script is /tmp/$LOGFILE"
exit 
