#!/bin/sh
#-------------------------------------------------------------------
# config.sh: This file is read at the beginning of the execution of the ASGS to
# set up the runs  that follow. It is reread at the beginning of every cycle,
# every time it polls the datasource for a new advisory. This gives the user
# the opportunity to edit this file mid-storm to change config parameters
# (e.g., the name of the queue to submit to, the addresses on the mailing list,
# etc)
#-------------------------------------------------------------------
#
# Copyright(C) 2023 Jason Fleming
#
# This file is part of the ADCIRC Surge Guidance System (ASGS).
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
# You should have received a copy of the GNU General Public License along with
# the ASGS.  If not, see <http://www.gnu.org/licenses/>.
#-------------------------------------------------------------------

# Fundamental

INSTANCENAME=SABv20a_al092025_be # "name" of this ASGS process

# Input files and templates

GRIDNAME=SABv20a
parameterPackage=default
   # !! if not set, uses 'hardcoded', options are defined in mesh_defaults.sh
   # !! for given GRIDNAME
createWind10mLayer="yes"
   # !! older versions of ASGS may require explictly defining the "Wind10m"
   # !! scenario runs, but this happens automatically now if set to "yes",
   # !! otherwise, these need to be defined explicitly if set to "no"
ADCIRCVERSION="v56.0.4"
   # !! intended ADCIRC version (no impact as of 2025-09-27 06:36:24 UTC)
source $SCRIPTDIR/config/mesh_defaults.sh

# Physical forcing (defaults set in config/forcing_defaults.sh)

TIDEFAC=on               # tide factor recalc
   HINDCASTLENGTH=20.0   # length of initial hindcast, from cold (days)
BACKGROUNDMET=off        # GFS download/forcing
   FORECASTCYCLE="06"
TROPICALCYCLONE=on      # tropical cyclone forcing
   STORM=09              # storm number, e.g. 05=ernesto in 2006
   YEAR=2025             # year of the storm
WAVES=on                 # wave forcing
   REINITIALIZESWAN=no   # used to bounce the wave solution
VARFLUX=off              # variable river flux forcing
#
CYCLETIMELIMIT="99:00:00"

# Computational Resources (related defaults set in platforms.sh)

NCPU=1919                # number of compute CPUs for all simulations
NCPUCAPACITY=9999
NUMWRITERS=1

# Post processing and publication

INTENDEDAUDIENCE=general    # "general" | "developers-only" | "professional"
OPENDAPPOST=opendap_post2.sh
#POSTPROCESS=( null_post.sh )
POSTPROCESS=( includeWind10m.sh createOPeNDAPFileList.sh $OPENDAPPOST )
OPENDAPNOTIFY="coastalrisk.live@outlook.com,pub.coastalrisk.live@outlook.com,jason.fleming@stormsurge.live,asgs.cera.lsu@coastalrisk.live,asgs.cera.pub.lsu@coastalrisk.live"
hooksScripts[FINISH_SPINUP_SCENARIO]=" output/createOPeNDAPFileList.sh output/$OPENDAPPOST "
hooksScripts[FINISH_NOWCAST_SCENARIO]=" output/createOPeNDAPFileList.sh output/$OPENDAPPOST "

# Monitoring

enablePostStatus="yes"
enableStatusNotify="no"
statusNotify="null"

# Initial state (overridden by STATEFILE after ASGS gets going)

COLDSTARTDATE=$(get-coldstart-date)
HOTORCOLD=hotstart
LASTSUBDIR=https://fortytwo.cct.lsu.edu/thredds/fileServer/2025/GFS/2025092806/SABv20a/mike.hpc.lsu.edu/SABv20a_gfs_mike_jgf/gfsforecast/

# Used for Hindcast Only configurations
#HINDCASTONCE_AND_EXIT=
   # !! if set, will cause asgs_main.sh (main loop) to exit after the first hindcast
#PERCENT=default
   # !! default is the track as described by the ATCF data; veerRight is positive;
   # !! veerLeft is negative. 100 is wrt the right most edge of the cone, -100 is
   # !! wrt left most edge of the cone
SCENARIOPACKAGESIZE=2
   # !! GAHM (using ATCF/BEST data) can have many different scenarios
   # !! as the tracks of the storm may be altered; here there are 2
   # !! scenarios, not including the hindcast and the nowcast
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
   ENSTORM=nhcConsensus
   PERCENT=0
   OPENDAPNOTIFY="coastalrisk.live@outlook.com,pub.coastalrisk.live@outlook.com,asgs.cera.lsu@coastalrisk.live,asgs.cera.pub.lsu@coastalrisk.live,asgsnotify@memenesia.net,jasongfleming@gmail.com,clint.dawson@austin.utexas.edu"
   ;;
1)
   ENSTORM=veerLeft100
   PERCENT=-100
   OPENDAPNOTIFY="coastalrisk.live@outlook.com,pub.coastalrisk.live@outlook.com,asgs.cera.lsu@coastalrisk.live,asgs.cera.pub.lsu@coastalrisk.live,asgsnotify@memenesia.net,jasongfleming@gmail.com,clint.dawson@austin.utexas.edu"
   ;;
*)
   echo "CONFIGRATION ERROR: Unknown scenario number: '$si'."
   ;;
esac

#
PREPPEDARCHIVE=prepped_${GRIDNAME}_${INSTANCENAME}_${NCPU}.tar.gz
HINDCASTARCHIVE=prepped_${GRIDNAME}_hc_${INSTANCENAME}_${NCPU}.tar.gz
