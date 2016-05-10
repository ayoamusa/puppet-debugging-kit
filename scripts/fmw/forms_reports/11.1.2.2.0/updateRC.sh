#!/usr/bin/env bash
# 
# Author: Greg Kenney, USFS
# 12/02/2014
# FMW11g/WebLogic
# 
# (for Red Hat EL 6) #

# require parameter
if [  "$1" != "load"  -a  "$1" != "remove" ]; then
    echo "Usage: $0 {load|remove}"
    exit 1
fi

# require root
if [ "$USER" != "root" ] ; then
    echo "Must be run as 'root'"
    exit 1
fi

# variables
ORACLE_BASE=/opt/oracle
MW_HOME=/opt/oracle/fmw/product/11.1.2

# parameters
case "$1" in
  #load RC
  load)
    echo
    echo "Configuring run control scripts..."
    #if the script exists, dont create it again
    if [ ! -e /etc/rc.d/init.d/FSWeblogic ] ; then
       #copy the script to the rc.d/init.d dir
       sudo cp $MW_HOME/FSWeblogic /etc/rc.d/init.d
       #make sure it is executable
       chmod 0755 /etc/rc.d/init.d/FSWeblogic
       #add the script to the RedHat chkconfig utility
       sudo chkconfig --add FSWeblogic
    else                                                     
       echo "init.d script already exists."                  
    fi                                                       
    echo "done."                                             
    ;;
  #remove RC
  remove)
    #remove init.d scripts
    echo
    echo "Removing run level scripts..."
    if [ -e "/etc/rc.d/init.d/FSWeblogic" ] ; then
       sudo chkconfig --del FSWeblogic
       sudo rm -f /etc/rc.d/init.d/FSWeblogic
    fi
    echo "done."
    ;;
esac

