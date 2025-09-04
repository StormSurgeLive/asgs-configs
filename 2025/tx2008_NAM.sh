#!/usr/bin/env bash
#-- created on 2025-06-09 05:21:20 UTC, https://tools.adcirc.live --#

# Copyright(C) 2025 Jason Fleming <jason.fleming@adcirc.live>
# Copyright(C) 2025 Brett Estrade <brett.estrade@adcirc.live>

# All Copyright information must be retained when sharing, modifying,
# or deriving works from this source code file; additional Copyright
# and Licensing information should be at the bottom of this file.

# file:
#   asgs_config_tx2008_NAM_ls6_be.sh
#-------------------------------------------------------------------
# Instance and Operator Information
#-------------------------------------------------------------------
#

INSTANCENAME=TX2008_nam_qbd_be
   # !! "name" of this ASGS process
#ASGSADMIN=asgsnotify@memenesia.net
   # !! email address of operator, HPCs need it
#ACCOUNT=ADCIRC # NOTE: consider setting in ~/.asgsh_profile on the host machine
   # !! used on HPC's to specify allocation account
#QOS=vipPJ_P3000
   # !! used for priority access at TACC

#-------------------------------------------------------------------
# Grid and Domain Settings - DO NOT MOVE THIS SECTION (see note)
#-------------------------------------------------------------------
#
# Anything set in this section needs to be set before the mesh_defaults
# file is source'd
#

GRIDNAME=tx2008_r35h
   # !! the "mesh"
#parameterPackage=default
   # !! if not set, uses 'hardcoded', options are defined in mesh_defaults.sh
   # !! for given GRIDNAME
createWind10mLayer="no"
   # !! older versions of ASGS may require explictly defining the "Wind10m"
   # !! scenario runs, but this happens automatically now if set to "yes",
   # !! otherwise, these need to be defined explicitly if set to "no"
ADCIRCVERSION="v56.0.2"
   # !! intended ADCIRC version (no impact as of 2025-06-09 05:21:20 UTC)

#-------------------------------------------------------------------
# Source mesh_defaults - DO NOT PUT GRID SETTINGS ABOVE PAST the mesh_defaults.sh line below
#-------------------------------------------------------------------
#
# Anything affecting the fort.15 templating or mesh configurations must
# be set _BEFORE_ sourcing the mesh_defaults.sh file - also note, the
# standard mesh_defaults already accounts for local resources set via
# the ASGS_LOCAL_DIR environmental variable. In summary, the following
# line should only be changed if you have a very good reason to do so.
#

source $SCRIPTDIR/config/mesh_defaults.sh
   # !! Sets all the mesh related defaults based the various env
   # !! variables set ahead of it; type "list meshes" to see what
   # !! meshes are available. Falls back to ASGS_LOCAL_DIR if set,
   # !! so no need to touch this in that case either.

#-------------------------------------------------------------------
# Logging Settings
#-------------------------------------------------------------------
#

enablePostStatus=yes
enableStatusNotify=no
statusNotify="asgsnotify@memenesia.net"
   # !! required for JSON Logging

#-------------------------------------------------------------------
# Start State Information
#-------------------------------------------------------------------
#

HOTORCOLD=hotstart
   # !! initial state (overridden by STATEFILE after ASGS gets going since it's then a "hotstart")
  COLDSTARTDATE=$(get-coldstart-date)
   # !! already computes based on HINDCASTLENGTH (default is 30 days before TODAY)
  LASTSUBDIR=https://fortytwo.cct.lsu.edu/thredds/fileServer/2025/nam/2025062412/tx2008_r35h/qbd.loni.org/tx2008_NAM/namforecast/
   # !! used when HOTORCOLD=hotstart
HINDCASTLENGTH=30
   # !! length of initial hindcast, from cold (days)

#-------------------------------------------------------------------
# Physical Forcing (defaults set in config/forcing_defaults.sh)
#-------------------------------------------------------------------
#

# Meteorological (winds - NAM, GFS, etc)
BACKGROUNDMET=on
   # !! download/ meteorological forcing from an upstream source
  FORECASTCYCLE="00,06,12,18"
   # !! !! used when BACKGROUNDMET is turned on (e.g., "00,06,12,18"), in UTC / "Z"

# Tropical/Hurricane (ATCF data for internal GAHM wind generation)
TROPICALCYCLONE=off
   # !! tropical cyclone forcing (mutually exclusive with BACKGROUNDMET in most cases)

# Other
TIDEFAC=on
   # !! tide factor recalc
WAVES=on
   # !! wave forcing via built-in SWAN coupling (adcswan/padcswan)
   REINITIALIZESWAN=off
   # !! !! used to bounce the wave solution (only used when WAVES=on)
VARFLUX=off
   # !! variable river flux forcing
CYCLETIMELIMIT=99:00:00
   # !! max time, usually just 99:00:00

#-------------------------------------------------------------------
# Computational Resources (related defaults set in ./platforms[.sh])
#-------------------------------------------------------------------
#

QUEUESYS=SLURM
   # !! platform specific, e.g., SLURM
#PPN=128
   # !! platform specific, processors-per-node
NCPU=959
   # !! number of compute CPUs for all simulations, should be a set in consideration of PPN
NUMWRITERS=1
   # !! usually just 1, total CPUs for the run is NCPU+NUMWRITERS
NCPUCAPACITY=9999
   # !! max number of total CPUs to use

#-------------------------------------------------------------------
# Post processing and publication
#-------------------------------------------------------------------
#

EMAILNOTIFY=yes
   # !! email notification master switch
INTENDEDAUDIENCE=general
   # !! used by CERA to pick where to display result; "general" | "developers-only"
OPENDAPPOST=opendap_post2.sh
   # !! posts OpenDAP/THREDDS servers via ssh (default, opendap_post2.sh)
POSTPROCESS=( includeWind10m.sh createOPeNDAPFileList.sh $OPENDAPPOST )
   # !! scripts to run during the POSTPROCESS ASGS hook
postAdditionalFiles=""
   # !! additional files to send over 
OPENDAPNOTIFY="coastalrisk.live@outlook.com,pub.coastalrisk.live@outlook.com,asgs.cera.lsu@coastalrisk.live,asgs.cera.pub.lsu@coastalrisk.live asgsnotify@memenesia.net"
   # !! main set of email addresses to notify
NOTIFY_SCRIPT=cera_notify.sh
   # !! notification used ...
TDS=( lsu_tds )
   # !! servers receiving results via ssh

hooksScripts[FINISH_SPINUP_SCENARIO]=" output/createOPeNDAPFileList.sh output/$OPENDAPPOST "
hooksScripts[FINISH_NOWCAST_SCENARIO]=" output/createOPeNDAPFileList.sh output/$OPENDAPPOST "
   # !! additional hook scripts, required for correctly posting data to CERA

#-------------------------------------------------------------------
# Scenario Package (Ensemble) Settings
#-------------------------------------------------------------------
#

# Used for Hindcast Only configurations
#HINDCASTONCE_AND_EXIT=
   # !! if set, will cause asgs_main.sh (main loop) to exit after the first hindcast
#PERCENT=default
   # !! default is the track as described by the ATCF data; veerRight is positive;
   # !! veerLeft is negative. 100 is wrt the right most edge of the cone, -100 is
   # !! wrt left most edge of the cone
SCENARIOPACKAGESIZE=2
case $si in
 -2)
   ENSTORM=hindcast
   # initial ramp up during a coldstart
   OPENDAPNOTIFY="asgsnotify@memenesia.net"
   ;;
-1)
   ENSTORM=nowcast
   # do nothing ... this is "catch up", not a forecast
   OPENDAPNOTIFY="asgsnotify@memenesia.net"
   ;;
0)
   ENSTORM=namforecastWind10m
   OPENDAPNOTIFY="asgsnotify@memenesia.net"
   ;;
1)
   ENSTORM=namforecast
   OPENDAPNOTIFY="coastalrisk.live@outlook.com,pub.coastalrisk.live@outlook.com,asgs.cera.lsu@coastalrisk.live,asgs.cera.pub.lsu@coastalrisk.live asgsnotify@memenesia.net"
   ;;
*)
   echo "CONFIGRATION ERROR: Unknown scenario number: '$si'."
   ;;
esac

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
# Copyright(C) 2025 Jason Fleming <jason.fleming@adcirc.live>
# Copyright(C) 2025 Brett Estrade <brett.estrade@adcirc.live>
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

#-- created on 2025-06-09 05:21:20 UTC, https://tools.adcirc.live --#

