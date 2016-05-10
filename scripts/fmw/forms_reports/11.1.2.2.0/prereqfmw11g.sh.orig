#!/usr/bin/env bash

########################################################
#Created by Greg Kenney, USDA Forest Service 11/28/2014#
########################################################

# prereqfmw11g.sh (For RHEL6)

#capture current time and date
NOW=$(date +"%m%d%y%H%M%S")

#define log file name
LOGFILE=prereqfmw11g\_$NOW.log

{

#set standard PATH
PATH=$PATH:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin ;export PATH

#identify hostname fqdn and ip address 
host=`hostname -s`
fqdn=`hostname -f`
ipadd=`hostname -i`

#expected kernel version
kernel="2.6.32"

# Prerequisite Script for FMW 11g
# Verifies system is ready for installation

#define output message labels
name="PRECHECK:" #label for activity related to 'checking' prereqs

CHK_PLAT () 
{
#This procedure verifies the Linux platform is 64bit
   echo
   #capture uname result (OS type)
   platnam=`uname -s`
   #capture uname result (platform)
   platarch=`uname -i`
   #if uname has OS type Linux then we can continue.   
   if [ $platnam == "Linux" ] ; then
      #if uname does not report 64-bit the platform is not supported.
      if [ "$platarch" != "x86_64" ] ; then
         echo "$name Failure: Platform check. ERROR:Unsupported platform. $platnam $platarch"
      #if uname reports 64-bit then we know the platform is supported.
      else
         echo "$name Success: Platform check. Found $platnam $platarch" 
      fi
   # if uname did not report Linux, we cannot continue.
   else
      echo "$name Failure: Platform check. ERROR:Unsupported platform. $platnam $platarch"
   fi
}

CHK_OS ()
{
#This procedure checks the Linux version using /etc/red-hat-release 
   #capture Linux version to a variable
   osver=`cat /etc/redhat-release |cut -d " " -f7`
   #isolate major version
   osver1=`echo $osver |cut -d "." -f1`
   #isolate update level
   osver2=`echo $osver |cut -d "." -f2`
   #if the major version is not 6, then we dont support it.
   if [ $osver1 != "6" ] ; then
      echo "$name Failure: OS version check. ERROR:Unsupported OS version. $osver"
   #otherwise the OS version is 6 and is supported
   else
      echo "$name Success: OS version check. Found RHEL $osver"
   fi
   #not going to check update level since min requirement is 1
   #anything greater than update level 1 is fine.
}

CHK_CPU ()
{
#Procedure for verifying correct number of cpu/cores
   #capture cpu/core count
   punits=`nproc --all`
   #if cpu/cores is less than 4 then throw error
   if [ $punits -lt 4 ] ; then
      echo "$name Failure: CPU check. ERROR:Insufficient number of processing units [$punits]. Requires a minimum of 4"
   else
      echo "$name Success: CPU check. Found $punits processing units"  
   fi
}

CHK_KERN ()
{
#Procedure for verifying correct kernel version
   #capture kernel version
   linuxkern=`uname -r |cut -d "-" -f1`
   #if kernel version doesnt match then it is unsupported
   if [ $linuxkern != "$kernel" ] ; then
      echo "$name Failure: Kernel check. ERROR:Unsupported kernel $linuxkern. Required is $kernel"
   else
      echo "$name Success: Kernel check. Found $linuxkern"  
   fi
}

CHK_RAM ()
{
# Procedure for verifying sufficient RAM
   #capture the amount of installed memory (MB) to a variable
   pram=`free -m |grep "Mem:" |awk -F " " '{print $2}'`
   #if the memory is less than the required minimum then throw error
   if [ $pram -lt "7600" ] ; then
      echo "$name Failure: RAM check. ERROR:Insufficient RAM $pram MB. Recommended is 8192 MB."
   else
      echo "$name Success: RAM check. Found $pram MB"
   fi
}

CHK_SWAP ()
{
# Procedure for verifying sufficient SWAP
   #capture virtual memory size in MB
   swap=`free -m |grep "Swap:" |awk -F " " '{print $2}'`
   #if the SWAP is less than the required minimum then it is not supported
   if [ $swap -lt "3600" ] ; then
      echo "$name Failure: SWAP check. ERROR:Insufficient free SWAP $swap MB. Recommended is 4096 MB."
   else
      echo "$name Success: SWAP check. Found $swap MB"
   fi
}

CHK_DISK ()
{
# Procedure for verifying free disk space
   #confirm if the disk mount point exists. 0=no, 1+=yes
   cdisk=`df -a |grep -v "/opt/oracle/" |grep -c /opt/oracle`
   #if the mount point does not exist then the prereq fails
   if [ $cdisk -lt "1" ] ; then
      echo "$name Failure: Disk check. ERROR:Missing mount point. '/opt/oracle'"
   else
      #capture the mount point size to a variable
      sdisk=`df -aPm |grep "/opt/oracle" |grep -v "/opt/oracle/" |awk '{print $4}'`
      #if the size is smaller than the minimum then the prereq fails
      if [ $sdisk -lt "15000" ] ; then #error if less than 15GB
         echo "$name Failure: Disk check. ERROR:Insufficient free space '/opt/oracle' $sdisk MB.  Recommended is 21000 MB." #recommend 21GB
      else
         echo "$name Success: Disk check '/opt/oracle'. Found $sdisk MB"
      fi
   fi
}      

CHK_NFS ()
{
# Procedure for verifying fslink symbolic link
   #determine if /fslink exists
   if [ ! -L "/fslink/sysinfra" ] ; then
      echo "$name Failure: Symlink does not exist. ERROR:'/fslink/sysinfra'" 
   else
      echo "$name Success: Symlink check. Found symlink '/fslink/sysinfra'"
   fi
}

CHK_TMP ()
{ 
# Procedure for verifying TMP space
   #determine if /tmp mount point exists
   tdisk1=`df -a |grep -v "/tmp/" |grep -c /tmp`
   #if the mount point does not exist then the the prereq fails
   if [ $tdisk1 -lt "1" ] ; then
      echo "$name Failure: TMP check. ERROR:Missing mount point. '/tmp'"
   else
      #store the size of the /tmp mount point to a variable
      let tdisk2=`df -aPm |grep -v "/tmp/" |grep "/tmp" |awk '{print $4}'`
      #if the size is less than the minimum, the prereq fails
      if [ $tdisk2 -lt "1200" ] ; then #error if less than 1.2GB
         echo "$name Failure: TMP check. ERROR:Insufficient free space '/tmp' $tdisk2 MB. Recommended is 2000 MB." #recommend 2GB
      else
         echo "$name Success: TMP check '/tmp'. Found $tdisk2 MB"
      fi
   fi
}       

CHK_SUDOERS ()
{
# Procedure for verifying sudoers entries
   if [ `sudo -v 2>&1|grep -c "may not run sudo"` -gt 0 ] ; then
      echo "$name Failure: Sudoers is not configured for user 'oracle'"
   else
      #entry 1
      sentry1="root.sh"
      #entry 2
      sentry2="oracleRoot.sh"
      #entry 3
      sentry3="updateRC.sh"
      #check for first entry
      se1=`sudo -l |grep -c "$ORACLE_HOME/$sentry1"`
      #check for second entry
      se2=`sudo -l |grep -c "$ORACLE_HOME/$sentry2"`
      #check for third entry
      se3=`sudo -l |grep -c "$MW_HOME/$sentry3"`
      #validate entries
      if [ $se1 -lt 1 ] ; then
         echo "$name Failure: Missing sudoers entry for 'root.sh'"
      fi
      if [ $se2 -lt 1 ] ; then
         echo "$name Failure: Missing sudoers entry for 'oracleRoot.sh'"
      fi
      if [ $se3 -lt 1 ] ; then
         echo "$name Failure: Missing sudoers entry for 'updateRC.sh'"
      fi
      if [ $se1 -gt 0 -a $se2 -gt 0 -a $se3 -gt 0 ] ; then
         echo "$name Success: Sudoers check. Found sudoers entries"
      fi
   fi
} 

CHK_HOST ()
{
# Procedure for verifying /etc/hosts
   #resolved may be empty if name resolution failed
   if [ -z "$resolved" ] ; then
      resolved="empty"
   fi
   #continue if name resolution succeeded
   if [ $resolved == "true" ] ; then
      #parse /etc/hosts for IP address
      etchosts1=`grep "^$ipadd" /etc/hosts |awk '{print $1}'`
      #parse /etc/hosts for fqdn
      etchosts2=`grep "^$ipadd" /etc/hosts |awk '{print $2}'`
      #parse /etc/hosts for hostname/alias
      etchosts3=`grep "^$ipadd" /etc/hosts |awk '{print $3}'`
      #if /etc/hosts is missing the IP address then the prereq fails
      if [ -z "$etchosts1" ] ; then
         echo "$name Failure: Hosts check. ERROR:Missing entry in /etc/hosts for $host"
      else
         #if the /etc/hosts contains a full entry for the host 
         if [ "$etchosts1" == "$ipadd" -a "$etchosts2" == "$fqdn" -a "$etchosts3" == "$host" ] ; then
            echo "$name Success: Hosts check '/etc/hosts'. Found valid entry"
         else
            echo "$name Failure: Hosts check '/etc/hosts'. ERROR:Incorrectly formatted"
         fi
      fi
   else
      #name resolution failed so we cannot check the hosts file
      echo "$name Warning: Hosts check '/etc/hosts'. WARN:Unable to verify hosts file until DNS is working"   
   fi
}   

CHK_NLKP ()
{
# Procedure for verifying nslookup resolves host/ip
   #capture result of nslookup against hostname and does it return the ipadd
   if [ -z "$ipadd" ] ; then
      alookup="0"
   else 
      alookup=`nslookup $host |grep -c "$ipadd"`
   fi 
   #capture result of nslookup against fqdn and does it return the ipadd
   if [ -z "$ipadd" ] ; then
      flookup="0"
   else 
      flookup=`nslookup $fqdn |grep -c "$ipadd"`
   fi
   #capture result of nslookup against ipadd and does it return the fqdn
   if [ -z "$fqdn" ] ; then
      ilookup="0"
   else
      ilookup=`nslookup $ipadd |grep -c "$fqdn"`
   fi
   #if nslookup against hostname fails then the prereq fails
   if [ $alookup -lt "1" ] ; then
      echo "$name Failure: DNS check. ERROR:Expected $ipadd"
      echo "          Check Forward Lookup Hostname >> IP and FQDN >> IP"
      echo "          Run 'hostname -s' to confirm correct hostname"
      echo "          Run 'hostname -i' to confirm correct IP Address"
      echo "          Run 'nslookup $host' to confirm DNS resolves to correct IP Address"
   fi
   #if the nslookup against fqdn fails then the prereq fails
   if [ $flookup -lt "1" ] ; then
      echo "$name Failure: DNS check. ERROR:Expected $ipadd"
      echo "          Check Forward Lookup FQDN >> IP and Hostname >> IP"
      echo "          Run 'hostname -f' to confirm correct FQDN"
      echo "          Run 'hostname -i' to confirm correct IP Address"
      echo "          Run 'nslookup $fqdn' to confirm DNS resolves to correct IP Address"
   fi
   #if the nslookup against ipadd fails then the prereq fails
   if [ $ilookup -lt "1" ] ; then
      echo "$name Failure: DNS check. ERROR:Expected $fqdn"
      echo "          Check Reverse Lookup IP >> FQDN and Hostname >> FQDN"
      echo "          Run 'hostname -f' to confirm correct FQDN"
      echo "          Run 'hostname -i' to confirm correct IP Address"
      echo "          Run 'nslookup $ipadd' to confirm DNS resolves to correct FQDN"
   fi
   #if the nslookup against hostname,fqdn, and ipadd succeeds prereq succeeds
   if [ "$alookup" -gt "0" -a "$flookup" -gt "0" -a "$ilookup" -gt "0" ] ; then 
      echo "$name Success: DNS check. Name resolution is working correctly"
      resolved="true"
   fi
}

CHK_PORT ()
{
# Procedure for verifying required port availability
   #define array with all ports that will be used by the installation
   declare -a staticports=('1810' '5556' '9001' '9002' '9003' '8888' '8889' '8890' '80' '443' '8092' '8093' '8091' '6700' '6701' '6702' '5155')
   #go thru each port number and make sure it is not in use with netstat 
   count=0
   for h in "${staticports[@]}"
   do
      #determine if port shows up in netstat output
      pvalidate=`netstat -anut |grep LISTEN |grep -c ":$h"`
      if [ $pvalidate -gt 0 ] ; then
         #record the used port number to a new array
         let count=$count+1
         cports[$count]=$h
      fi
   done
   #if the 'ports in use' array is empty then there will be no port conflicts
   if [ $count -lt 1 ] ; then
      echo "$name Success: Port check. All required ports are available"
   else
      echo "$name Failure: Port check. ERROR:Some required ports are already in-use"
      #print each port conflict from the 'port in use' array (cports)
      for c in "${cports[@]}"
      do
         echo "     Port $c"
      done
   fi
}

CHK_UG ()
{
# Procedure for verifying oracle user and group exists
   #capture result of whether or not the oracle user exists
   uexist=`id |grep -c "oracle"`
   #capture result of whether or not the oinstall group exists
   gexist1=`id |grep -c "oinstall"` 
   #capture result of whether or not the dba group exists
   gexist2=`id |grep -c "dba"`
   #capture result of whether or not the oper group exists
   gexist3=`id |grep -c "oper"`
   #if the oinstall group exists then the prereq succeeds
   if [ $gexist1 -gt "0" ] ; then
      echo "$name Success: Group check. Found OS group 'oinstall'"
   else
      echo "$name Failure: Group check. ERROR:Group does not exist. 'oinstall'"
   fi
   #if the dba group exists then the prereq succeeds
   if [ $gexist2 -gt "0" ] ; then
      echo "$name Success: Group check. Found OS group 'dba'"
   else
      echo "$name Failure: Group check. ERROR:Group does not exist. 'dba'"
   fi
   #if the oper group exists then the prereq succeeds
   if [ $gexist3 -gt "0" ] ; then
      echo "$name Success: Group check. Found OS group 'oper'"
   else
      echo "$name Failure: Group check. ERROR:Group does not exist. 'oper'"
   fi
   #if the user oracle exists then the prereq succeeds
   if [ $uexist -gt "0" ] ; then
      echo "$name Success: User check. Found user 'oracle'"
   else 
      echo "$name Failure: User check. ERROR:User does not exist. 'oracle'"
   fi
}

CHK_PROF ()
{
# Procedure for verifying oracle profile
   #capture whether or not the bash profile has been setup
   oprofile=`grep -c "MW_HOME" /home/oracle/.bash_profile`
   #if the profile was already setup then the prereq succeeds
   if [ $oprofile -gt "0" ] ; then
      echo "$name Success: Profile check. Profile for 'oracle' is configured"
   else 
      #append profile
      cat >> /home/oracle/.bash_profile <<EOF 
##############################
# Oracle Fusion Middleware Requirements
##############################

# ---------------------------------------------------
# .bash_profile
# ---------------------------------------------------
# OS User:      oracle
# Application:  Oracle Software Owner
# Version:      Oracle Fusion Middleware 11g
# ---------------------------------------------------

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
      . ~/.bashrc
fi

# ---------------------------------------------------
# MW_HOME
# ---------------------------------------------------
# Specifies the top level directory for the middleware 
# home
# ---------------------------------------------------
ORACLE_BASE=/opt/oracle/fmw; export ORACLE_BASE
MW_HOME=/opt/oracle/fmw/product/11.1.2; export MW_HOME

# ---------------------------------------------------
# JAVA_HOME
# ---------------------------------------------------
# Specifies the directory of the Java SDK and Runtime
# Environment.
# ---------------------------------------------------
JAVA_HOME=/opt/oracle/fmw/product/11.1.2/jdk; export JAVA_HOME

# ---------------------------------------------------
# ORACLE_HOME
# ---------------------------------------------------
# Specifies the directory containing the Oracle
# software binaries.
# ---------------------------------------------------
ORACLE_HOME=/opt/oracle/fmw/product/11.1.2/oracle_fr; export ORACLE_HOME

# ---------------------------------------------------
# WL_HOME
# ---------------------------------------------------
# Specifies the WLS binary home directory
# ---------------------------------------------------
WL_HOME=/opt/oracle/fmw/product/11.1.2/wlserver_10.3; export WL_HOME

# ---------------------------------------------------
# DOMAIN_HOME
# ---------------------------------------------------
# Specifies the WLS Domain home directory
# ---------------------------------------------------
DOMAIN_HOME=/opt/oracle/fmw/product/11.1.2/user_projects/domains/frdomain; export DOMAIN_HOME

# ---------------------------------------------------
# ORACLE_INSTANCE
# ---------------------------------------------------
# Specifies the Oracle Instance home directory
# ---------------------------------------------------
ORACLE_INSTANCE=/opt/oracle/fmw/product/11.1.2/instances/frinst_1; export ORACLE_INSTANCE

# ---------------------------------------------------
# PATH
# ---------------------------------------------------
# Used by the shell to locate executable programs;
# must include the $ORACLE_HOME/bin directory.
# ---------------------------------------------------
PATH=.:/opt/oracle/fmw/product/11.1.2/oracle_fr/bin:/opt/oracle/fmw/product/11.1.2/jdk/bin:$PATH:/usr/bin/X11
export PATH

# ---------------------------------------------------
# LD_LIBRARY_PATH
# ---------------------------------------------------
# Specifies the list of directories that the shared
# library loader searches to locate shared object
# libraries at runtime.
# ---------------------------------------------------
LD_LIBRARY_PATH=/opt/oracle/fmw/product/11.1.2/oracle_fr/lib:/lib:/usr/lib:/usr/local/lib
export LD_LIBRARY_PATH

# ---------------------------------------------------
# CLASSPATH
# ---------------------------------------------------
# Specifies the directory or list of directories that
# contain compiled Java classes.
# ---------------------------------------------------
CLASSPATH=/opt/oracle/fmw/product/11.1.2/oracle_fr/lib:/opt/oracle/fmw/product/11.1.2/jdk/lib
export CLASSPATH

# ---------------------------------------------------
# TEMP, TMP
# ---------------------------------------------------
# Specify the default directories for temporary
# files; if set, tools that create temporary files
# create them in one of these directories.
# ---------------------------------------------------
export TEMP=/tmp
export TMP=/tmp

# ---------------------------------------------------
# ORACLE FORMS AND REPORTS RELATED
# ---------------------------------------------------
# These env variables are required
# for Oracle Forms and Reports
# ---------------------------------------------------
export LC_ALL=C
export NLS_LANG=AMERICAN_AMERICA.WE8ISO8859P15

# ---------------------------------------------------
# UMASK
# ---------------------------------------------------
# Set the default file mode creation mask
# (umask) to 022 to ensure that the user performing
# the Oracle software installation creates files
# with 644 permissions.
# ---------------------------------------------------
umask 022
EOF
      #check profile again
      CHK_PROF
   fi
}

CHK_LIM ()
{
# Procedure for verifying limits
   #capture current limits
   let softfilelimit=`ulimit -n`
   let hardfilelimit=`ulimit -Hn`
   let softproclimit=`ulimit -u`
   let hardproclimit=`ulimit -Hu`
   #if soft file limit is configured then the prereq succeeds
   if [ $softfilelimit -ge 4096 ] ; then
      echo "$name Success: Ulimit -n check. Ulimit is sufficient [$softfilelimit]"
   else
      echo "$name Failure: Ulimit -n check. ERROR:Ulimit is insufficient [$softfilelimit]"
   fi
   #if hard file limit is configured then the prereq succeeds
   if [ $hardfilelimit -ge 65536 ] ; then
      echo "$name Success: Ulimit -Hn check. Ulimit is sufficient [$hardfilelimit]"
   else
      echo "$name Failure: Ulimit -Hn check. ERROR:Ulimit is insufficient [$hardfilelimit]"
   fi
   #if soft proc limit is configured then the prereq succeeds
   if [ $softproclimit -ge 2047 ] ; then
      echo "$name Success: Ulimit -u check. Ulimit is sufficient [$softproclimit]"
   else
      echo "$name Failure: Ulimit -u check. ERROR:Ulimit is insufficient [$softproclimit]"
   fi
   #if hard proc limit is configured then the prereq succeeds
   if [ $hardproclimit -ge 16384 ] ; then
      echo "$name Success: Ulimit -Hu check. Ulimit is sufficient [$hardproclimit]"
   else
      echo "$name Failure: Ulimit -Hu check. ERROR:Ulimit is insufficient [$hardproclimit]"
   fi
}

CHK_KPARM ()
{
# Procedure for verifying sufficient shared memory segment
   #minimum setting
   minshmmax=4294967295
   #current setting
   curshmmax=`/sbin/sysctl -n kernel.shmmax`
   #if parameter missing then value is 0
   if [ -z $curshmmax ] ; then
      curshmmax=0
   fi
   #if value is sufficient report success
   if [ $curshmmax -ge $minshmmax ] ; then
      echo "$name Success: Kernel.shmmax. Value is sufficient [$curshmmax]"
   #if value is insufficient report failure
   else
      echo "$name Failure: Kernel.shmmax. ERROR: Value is insufficient [$curshmmax]"
   fi
}

CHK_PTR ()
{
# Procedure for verifying presence of oraInst.loc
   if [ -f "/etc/oraInst.loc" ] ; then
      echo "$name Success: Pointer check. Found oraInst.loc"
   else
      echo "$name Failure: Pointer check. ERROR:oraInst.loc not found"
   fi
}

CHK_RPM ()
{
# procedure for verifying RPM package requirements
   # build array for the rpms for Red Hat 6
   echo "$name Results: RPM check. (reports error if rpm not found)"
   RPM=(
        binutils-2.*.x86_64
        compat-libcap1-1.*.x86_64 
        compat-libstdc++-33-*.*.x86_64 
        compat-libstdc++-33-*.*.i686 
        gcc-4.*.x86_64 
        gcc-c++-4.*.x86_64 
        glibc-2.*.x86_64
        glibc-2.*.i686
        glibc-devel-2.*.i686
        libaio-0.*.x86_64
        libaio-devel-0.*.x86_64
        libgcc-4.*.x86_64 
        libstdc++-4.*.x86_64
        libstdc++-4.*.i686
        libstdc++-devel-4.*.x86_64
        libXext-*.*.i686
        libXtst-*.*.i686
        openmotif-2.*.x86_64
        openmotif22-2.*.x86_64
        sysstat-9.*.x86_64 
        redhat-lsb-core-4.*.x86_64
        ksh-*.*.x86_64
        )
   # write list of installed rpms to file
   rpm -qa > /tmp/rpmlist.txt
   # loop through array to determine what is missing
   for i in ${RPM[*]}
   do
      # value greater than 0 of rpm exists
      rpmexist=`grep -c ^$i /tmp/rpmlist.txt`
      # full name of rpm
      rpmname=`grep ^$i /tmp/rpmlist.txt`
      # print found to screen if rpm found
      if [ $rpmexist -ge 1 ] ; then
         echo "     Found $rpmname"
      else
         # print error to screen if rpm not found
         echo "     ERROR: The rpm $i was NOT found"
      fi
   done
   # remove temporary output file
   rm /tmp/rpmlist.txt
   echo "   RPM check done."
}

### Begin running of Precheck procedures ###
### Any one procedure can be disable by placing a leading '#'

echo
echo "Initiating the WebLogic 11g Midtier Prereq Script...."
CHK_PLAT #verifies Linux 64bit
CHK_OS #verifies correct operating system version
#CHK_CPU #verifies correct number of CPU/Cores [disabled 12/24/2014 gk]
CHK_KERN #verifies correct kernel version
CHK_RAM #verifies sufficient physical memory
CHK_SWAP #verifies sufficient SWAP size
CHK_DISK #verifies sufficient disk space
CHK_NFS #verifies symbolic link /fslink/sysinfra
CHK_TMP #verifies sufficient TMP space
CHK_SUDOERS #verifies correct sudoers entries
CHK_NLKP #verifies DNS lookups are working
CHK_HOST #verifies /etc/hosts is configured
CHK_PORT #verifies there will be no port conflicts
CHK_UG #verifies user and groups exist
CHK_PROF #verifies oracle profile is configured
CHK_LIM #verifies ulimit is configured
CHK_KPARM #verifies shmmax setting
CHK_PTR #verifies oraInst.loc present
CHK_RPM #verifies all RPMs are installed
### End Precheck procedures ###
echo
echo "*****************************************************************"
echo "**   All items above should show 'Success' before continuing   **" 
echo "*****************************************************************"

#output to the log
} 2>&1 | tee /tmp/$LOGFILE
echo
echo "Log file for this script is /tmp/$LOGFILE"
echo
exit
