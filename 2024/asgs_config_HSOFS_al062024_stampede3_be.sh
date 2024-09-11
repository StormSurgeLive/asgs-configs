#!/bin/sh
#-- created on 2024-09-11 02:07:16 UTC, https://tools.adcirc.live --#

# Copyright(C) 2024 Jason Fleming <jason.fleming@adcirc.live>
# Copyright(C) 2024 Brett Estrade <brett.estrade@adcirc.live>

# + additional Copyright and License info is at the bottom

#-------------------------------------------------------------------
# Instance and Operator Information
#-------------------------------------------------------------------
#

INSTANCENAME=HSOFS_al062024_stampede3_be
# "name" of this ASGS process

ASGSADMIN=asgsnotify@memenesia.net
# email address of operator, HPCs need it

ACCOUNT=TG-DMS080016N
# used on HPC's to specify allocation account

QOS=vipPJ_P3000
# used for priority access at TACC

#-------------------------------------------------------------------
# Input Files and Templates 
#-------------------------------------------------------------------
#

GRIDNAME=HSOFS
source $SCRIPTDIR/config/mesh_defaults.sh

#-------------------------------------------------------------------
# Start State Information
#-------------------------------------------------------------------
#

HOTORCOLD=hotstart
# Note: Initial state (overridden by STATEFILE after ASGS gets going since
# it's then a "hotstart")

HINDCASTLENGTH=30 
# length of initial hindcast, from cold (days)

COLDSTARTDATE=auto
# ensures that COLDSTARTDATE is ignored, and it is gotten from the hotstart file

LASTSUBDIR=https://fortytwo.cct.lsu.edu/thredds/fileServer/2024/nam/2024062806/HSOFS/qbd.loni.org/HSOFS_nam_be/namforecast      
# used when HOTORCOLD=hotstart

#-------------------------------------------------------------------
# Physical Forcing (defaults set in config/forcing_defaults.sh)
#-------------------------------------------------------------------
#

TIDEFAC=on                       
# tide factor recalc

BACKGROUNDMET=off           
# download/ meteorological forcing from an upstream source

FORECASTCYCLE=""
# used when BACKGROUNDMET is turned on ("on", "NAM", "GFS", etc)

TROPICALCYCLONE=on       
# tropical cyclone forcing (mutually exclusive with BACKGROUNDMET in most cases)

   STORM=06                        
   # storm number, e.g. 05=ernesto in 2006

   YEAR=2024                          
   # year of the storm

   BASIN=al                        
   # ocean basin, e.g., AL (Atlantic), EP (East Pacific)
WAVES=on                           
# wave forcing via built-in SWAN coupling (adcswan/padcswan)

   REINITIALIZESWAN=off  
   # used to bounce the wave solution (only used when WAVES=on)

VARFLUX=off                       
# variable river flux forcing

CYCLETIMELIMIT=99:00:00         
# max time, usually just 99:00:00

#-------------------------------------------------------------------
# Computational Resources (related defaults set in ./platforms[.sh])
#-------------------------------------------------------------------
#

PPN=48                  
# platform specific, processors-per-node

NCPU=959                
# number of compute CPUs for all simulations, should be a set in consideration of PPN

NUMWRITERS=1    
# usually just 1, total CPUs for the run is NCPU+NUMWRITERS

QUEUESYS=SLURM  
# platform specific, e.g., SLURM

NCPUCAPACITY=9999
# max number of total CPUs to use

enablePostStatus=yes
enableStatusNotify=no
statusNotify="asgsnotify@memenesia.net"
# JSON Logging

#-------------------------------------------------------------------
# Post processing and publication
#-------------------------------------------------------------------
#

EMAILNOTIFY=yes

INTENDEDAUDIENCE=general             
# Settings for CERA to help determine where to post results; "general" | "developers-only"

OPENDAPPOST=opendap_post2.sh                       
# usually, "opendap_post2.sh"; for posting to OpenDAP/THREDDS servers via ssh

POSTPROCESS=(  $OPENDAPPOST ) 
# scripts to run during the POSTPROCESS ASGS hook
# email list receiving alerts via bin/asgs-sendmail

OPENDAPNOTIFY="coastalrisk.live@outlook.com,pub.coastalrisk.live@outlook.com,asgs.cera.lsu@coastalrisk.live,asgs.cera.pub.lsu@coastalrisk.live,asgsnotify@memenesia.net,jasongfleming@gmail.com,cdelcastillo21@gmail.com"

NOTIFY_SCRIPT=cera_notify.sh                   
# notification used ... 

TDS=( lsu_tds )                                   
# servers receiving results via ssh

hooksScripts[FINISH_SPINUP_SCENARIO]=" output/createOPeNDAPFileList.sh output/$OPENDAPPOST "
hooksScripts[FINISH_NOWCAST_SCENARIO]=" output/createOPeNDAPFileList.sh output/$OPENDAPPOST "

#-------------------------------------------------------------------
# Scenario Package (Ensemble) Settings
#-------------------------------------------------------------------
#

# Used for Hindcast Only configurations
#HINDCASTONCE_AND_EXIT=
#PERCENT=default

SCENARIOPACKAGESIZE=6 

case $si in
 -2)
   ENSTORM=hindcast           
   # initial ramp up during a coldstart
   OPENDAPNOTIFY="coastalrisk.live@outlook.com,pub.coastalrisk.live@outlook.com,asgs.cera.lsu@coastalrisk.live,asgs.cera.pub.lsu@coastalrisk.live,asgsnotify@memenesia.net,jasongfleming@gmail.com,cdelcastillo21@gmail.com"
   ;;
-1)
   ENSTORM=nowcast            
   # do nothing ... this is "catch up", not a forecast 
   OPENDAPNOTIFY="null"
   ;;
0)
   ENSTORM=nhcConsensus
   PERCENT=0
   OPENDAPNOTIFY="coastalrisk.live@outlook.com,pub.coastalrisk.live@outlook.com,asgs.cera.lsu@coastalrisk.live,asgs.cera.pub.lsu@coastalrisk.live,asgsnotify@memenesia.net,jasongfleming@gmail.com,cdelcastillo21@gmail.com"
   source $SCRIPTDIR/config/io_defaults.sh
   ;;
1)
   ENSTORM=nhcConsensusWind10m
   PERCENT=0
   OPENDAPNOTIFY="asgsnotify@memenesia.net"
   source $SCRIPTDIR/config/io_defaults.sh
   ;;
2)
   ENSTORM=veerRight100
   PERCENT=100
   OPENDAPNOTIFY="coastalrisk.live@outlook.com,pub.coastalrisk.live@outlook.com,asgs.cera.lsu@coastalrisk.live,asgs.cera.pub.lsu@coastalrisk.live,asgsnotify@memenesia.net,jasongfleming@gmail.com,cdelcastillo21@gmail.com"
   source $SCRIPTDIR/config/io_defaults.sh
   ;;
3)
   ENSTORM=veerRight100Wind10m
   PERCENT=100
   OPENDAPNOTIFY="asgsnotify@memenesia.net"
   source $SCRIPTDIR/config/io_defaults.sh
   ;;
4)
   ENSTORM=veerLeft100
   PERCENT=-100
   OPENDAPNOTIFY="coastalrisk.live@outlook.com,pub.coastalrisk.live@outlook.com,asgs.cera.lsu@coastalrisk.live,asgs.cera.pub.lsu@coastalrisk.live,asgsnotify@memenesia.net,jasongfleming@gmail.com,cdelcastillo21@gmail.com"
   source $SCRIPTDIR/config/io_defaults.sh
   ;;
5)
   ENSTORM=veerLeft100Wind10m
   PERCENT=-100
   OPENDAPNOTIFY="asgsnotify@memenesia.net"
   source $SCRIPTDIR/config/io_defaults.sh
   ;;
*)
   echo "CONFIGRATION ERROR: Unknown scenario number: '$si'."
   ;;
esac

source $SCRIPTDIR/config/io_defaults.sh
# sets met-only mode based on "Wind10m" suffix

PREPPEDARCHIVE=prepped_${GRIDNAME}_${INSTANCENAME}_${NCPU}.tar.gz
HINDCASTARCHIVE=prepped_${GRIDNAME}_hc_${INSTANCENAME}_${NCPU}.tar.gz

#
#-------------------------------------------------------------------
# config.sh: This file is read at the beginning of the execution of the ASGS to
# set up the runs  that follow. It is reread at the beginning of every cycle,
# every time it polls the datasource for a new advisory. This gives the user
# the opportunity to edit this file mid-storm to change config parameters
# (e.g., the name of the queue to submit to, the addresses on the mailing list,
# etc)
#-------------------------------------------------------------------
#
# Copyright(C) 2024 Jason Fleming <jason.fleming@adcirc.live>
# Copyright(C) 2024 Brett Estrade <brett.estrade@adcirc.live>
#
# This file is part of the ADCIRC Surge Guidance System (ASGS) and has been
# generated by ADCIRC Live (C) - https://tools.adcirc.live
#
# The ASGS is free software: you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# ASGS is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# It is available for free at https://github.com/StormSurgeLive/asgs
#
# See the results available, particularly for tropical cyclones at LSU's CERA,
#   COASTAL EMERGENCY RISKS ASSESSMENT
#     ~ Storm Surge Guidance for Emergency Management and Real-Time Decisions ~
#
#   https://cera.coastalrisk.live
#
# You should have received a copy of the GNU General Public License along with
# the ASGS.  If not, see <http://www.gnu.org/licenses/>.
#-------------------------------------------------------------------

#-- created on 2024-09-11 02:07:16 UTC, https://tools.adcirc.live --#

