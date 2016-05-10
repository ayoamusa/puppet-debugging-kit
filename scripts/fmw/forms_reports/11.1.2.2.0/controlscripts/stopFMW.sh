#!/usr/bin/env bash

########################################################
#Created by Greg Kenney, USDA Forest Service 12/02/2014#
########################################################

# stopFMW.sh (for Red Hat EL 6)

#Script for stopping the entire Fusion Middleware stack

# Set environment variables

export MW_HOME=/opt/oracle/fmw/product/11.1.2
export WL_HOME=$MW_HOME/wlserver_10.3
export DOMAIN_NAME=frdomain
export DOMAIN_HOME=$MW_HOME/user_projects/domains/frdomain
export ORACLE_INSTANCE=$MW_HOME/instances/frinst_1
export ORACLE_HOME=$MW_HOME/oracle_fr

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# SYSTEM COMPONENTS SHUTDOWN (http server,emagent)
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
echo "Initiating Fusion Middleware 11g shutdown..."
$ORACLE_INSTANCE/bin/opmnctl stopall

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# WEBLOGIC SERVER DOMAIN SHUTDOWN (nodemanager,adminserver,managed server)
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
. $MW_HOME/stopManaged.sh
. $MW_HOME/stopAdmin.sh
. $MW_HOME/stopNM.sh
