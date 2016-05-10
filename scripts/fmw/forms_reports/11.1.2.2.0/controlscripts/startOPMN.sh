#!/usr/bin/env bash

########################################################
#Created by Greg Kenney, USDA Forest Service 12/02/2014#
########################################################

# startOPMN.sh (for Red Hat EL 6)

#Script for starting OPMN 

# Set environment variables

export MW_HOME=/opt/oracle/fmw/product/11.1.2
export WL_HOME=$MW_HOME/wlserver_10.3
export DOMAIN_NAME=frdomain
export DOMAIN_HOME=$MW_HOME/user_projects/domains/frdomain
export ORACLE_INSTANCE=$MW_HOME/instances/frinst_1
export ORACLE_HOME=$MW_HOME/oracle_fr

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# SYSTEM COMPONENTS STARTUP (http server,emagent)
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

echo "Starting the OPMN managed components ..."
#Check if OPMN is already running before attempting to start it
   ckopmn=`ps -ef |grep -v grep |grep -c  "$ORACLE_HOME/opmn/bin/opmn -d"`
   if [ $ckopmn -gt 0 ] ; then
      echo "Already running."
   else
      $ORACLE_INSTANCE/bin/opmnctl startall
   fi

