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
# Copyright(C) 2024 Jason Fleming
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

INSTANCENAME=NCv6d_gfs # "name" of this ASGS process

# Input files and templates

GRIDNAME=NCv6d
source $SCRIPTDIR/config/mesh_defaults.sh

# Physical forcing (defaults set in config/forcing_defaults.sh)

TIDEFAC=on               # tide factor recalc
   HINDCASTLENGTH=10.0   # length of initial hindcast, from cold (days)
BACKGROUNDMET=GFS        # GFS download/forcing
   FORECASTCYCLE="06"
   GFSFORECASTLENGTH=24
TROPICALCYCLONE=off      # tropical cyclone forcing
   STORM=08              # storm number, e.g. 05=ernesto in 2006
   YEAR=2021             # year of the storm
WAVES=off                # wave forcing
   REINITIALIZESWAN=no   # used to bounce the wave solution
VARFLUX=default              # variable river flux forcing

# Computational Resources (related defaults set in platforms.sh)

NCPU=15                 # number of compute CPUs for all simulations
NCPUCAPACITY=9999
NUMWRITERS=1
CYCLETIMELIMIT="99:00:00"

# Post processing and publication

INTENDEDAUDIENCE=developers-only    # "general" | "developers-only" | "professional"
OPENDAPPOST=opendap_post2.sh
POSTPROCESS=( null_post.sh )
#POSTPROCESS=( includeWind10m.sh createOPeNDAPFileLit.sh $OPENDAPPOST )
#OPENDAPNOTIFY="coastalrisk.live@outlook.com,pub.coastalrisk.live@outlook.com,jason.fleming@seahorsecoastal.com,jason.fleming@stormsurge.live"
#hooksScripts[FINISH_SPINUP_SCENARIO]=" output/createOPeNDAPFileList.sh output/$OPENDAPPOST "
#hooksScripts[FINISH_NOWCAST_SCENARIO]=" output/createOPeNDAPFileList.sh output/$OPENDAPPOST "

# Monitoring

enablePostStatus="no"
enableStatusNotify="no"
statusNotify="null"

# Initial state (overridden by STATEFILE after ASGS gets going)

COLDSTARTDATE=2024020500
HOTORCOLD=coldstart
LASTSUBDIR=null

#
# Scenario package
#
#PERCENT=default
SCENARIOPACKAGESIZE=1
case $si in
   -2)
       ENSTORM=hindcast
       ;;
   -1)
       # do nothing ... this is not a forecast
       ENSTORM=nowcast
       ;;
    0)
       ENSTORM=gfsforecast
       ;;
    *)
       echo "CONFIGURATION ERROR: Unknown ensemble member number: '$si'."
      ;;
esac
#
PREPPEDARCHIVE=prepped_${GRIDNAME}_${INSTANCENAME}_${NCPU}.tar.gz
HINDCASTARCHIVE=prepped_${GRIDNAME}_hc_${INSTANCENAME}_${NCPU}.tar.gz
