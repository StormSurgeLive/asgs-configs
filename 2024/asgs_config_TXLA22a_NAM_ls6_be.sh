#!/bin/sh
#-- created on 2024-09-08 06:25:52 UTC, https://tools.adcirc.live --#

# Copyright(C) 2024 Jason Fleming <jason.fleming@adcirc.live>
# Copyright(C) 2024 Brett Estrade <brett.estrade@adcirc.live>

# + additional Copyright and License info is at the bottom

#-------------------------------------------------------------------
# Instance and Operator Information
#-------------------------------------------------------------------
#

INSTANCENAME=TXLA22a_NAM_ls6_be
# "name" of this ASGS process

ASGSADMIN=asgsnotify@memenesia.net
# email address of operator, HPCs need it

ACCOUNT=ADCIRC
# used on HPC's to specify allocation account

QOS=vipPJ_P3000
# used for priority access at TACC

#-------------------------------------------------------------------
# Input Files and Templates 
#-------------------------------------------------------------------
#

GRIDNAME=TXLA22a
source $SCRIPTDIR/config/mesh_defaults.sh

#-------------------------------------------------------------------
# Start State Information
#-------------------------------------------------------------------
#

HOTORCOLD=coldstart
# Note: Initial state (overridden by STATEFILE after ASGS gets going since
# it's then a "hotstart")

HINDCASTLENGTH=30 
# length of initial hindcast, from cold (days)

COLDSTARTDATE=$(get-coldstart-date) 
# already computes based on HINDCASTLENGTH (default is 30 days before TODAY)

LASTSUBDIR=null      
# used when HOTORCOLD=hotstart

#-------------------------------------------------------------------
# Physical Forcing (defaults set in config/forcing_defaults.sh)
#-------------------------------------------------------------------
#

TIDEFAC=on                       
# tide factor recalc

BACKGROUNDMET=on           
# download/ meteorological forcing from an upstream source

FORECASTCYCLE="00,06,12,18"
# used when BACKGROUNDMET is turned on ("on", "NAM", "GFS", etc)

TROPICALCYCLONE=off       
# tropical cyclone forcing (mutually exclusive with BACKGROUNDMET in most cases)

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

PPN=128                  
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

OPENDAPNOTIFY="coastalrisk.live@outlook.com,pub.coastalrisk.live@outlook.com,asgs.cera.lsu@coastalrisk.live,asgs.cera.pub.lsu@coastalrisk.live,cdelcastillo21@gmail.com"

NOTIFY_SCRIPT=cera_notify.sh                   
# notification used ... 

TDS=( lsu_tds )                                   
# servers receiving results via ssh

#-------------------------------------------------------------------
# Scenario Package (Ensemble) Settings
#-------------------------------------------------------------------
#

# Used for Hindcast Only configurations
#HINDCASTONCE_AND_EXIT=
#PERCENT=default

SCENARIOPACKAGESIZE=2         
# define scenarios to run,
#1 and
#2 below (doesn't affect -2, -1) 

case $si in
 -2)
   ENSTORM=hindcast           
   # initial ramp up during a coldstart

   OPENDAPNOTIFY="coastalrisk.live@outlook.com,pub.coastalrisk.live@outlook.com,asgs.cera.lsu@coastalrisk.live,asgs.cera.pub.lsu@coastalrisk.live"
   ;;
-1)
   ENSTORM=nowcast            
   # do nothing ... this is "catch up", not a forecast 

   OPENDAPNOTIFY="null"
   ;;
0)
   ENSTORM=namforecastWind10m 
   # generates winds and writes them to a fort.22, very fast running

   source $SCRIPTDIR/config/io_defaults.sh
   # sets met-only mode based on "Wind10m" suffix
   ;;
1)
   ENSTORM=namforecast
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

#-- created on 2024-09-08 06:25:52 UTC, https://tools.adcirc.live --#

