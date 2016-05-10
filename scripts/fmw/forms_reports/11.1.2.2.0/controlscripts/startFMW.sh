#!/usr/bin/env bash

########################################################
#Created by Greg Kenney, USDA Forest Service 12/02/2014#
########################################################

# startFMW.sh (for Red Hat EL 6)

#Script for starting the entire Fusion Middleware stack

# Set environment variables

export WL_HOME=/opt/oracle/fmw/product/11.1.2/wlserver_10.3
export MW_HOME=/opt/oracle/fmw/product/11.1.2
export DOMAIN_NAME=frdomain
export DOMAIN_HOME=$MW_HOME/user_projects/domains/frdomain
export ORACLE_INSTANCE=$MW_HOME/instances/frinst_1
export ORACLE_HOME=$MW_HOME/oracle_fr

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# WEBLOGIC SERVER DOMAIN STARTUP (nodemanager,adminserver,managed servers)
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
echo "Initiating FMW 11g startup..."
. $MW_HOME/startNM.sh
. $MW_HOME/startAdmin.sh
. $MW_HOME/startManaged.sh

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# SYSTEM COMPONENTS STARTUP (http server,emagent)
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
. $MW_HOME/startOPMN.sh
