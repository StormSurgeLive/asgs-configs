#!/bin/sh
#-------------------------------------------------------------------
# config.sh : Operator specifications for an ASGS instance
#-------------------------------------------------------------------
# Copyright(C) 2026 Jason Fleming
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

INSTANCENAME=LKOKE_gfs_kitt_jgf # "name" of this ASGS process

# Input files and templates

GRIDNAME=LKOKE
parameterPackage=default   # <-----<<
createWind10mLayer="yes"   # <-----<<
source $SCRIPTDIR/config/mesh_defaults.sh

# Physical forcing (defaults set in config/forcing_defaults.sh)

TIDEFAC=off              # tide factor recalc
   HINDCASTLENGTH=0.0   # length of initial hindcast, from cold (days)
BACKGROUNDMET=GFS        # GFS download/forcing
   FORECASTCYCLE="06"
TROPICALCYCLONE=off      # tropical cyclone forcing
   STORM=08              # storm number, e.g. 05=ernesto in 2006
   YEAR=2021             # year of the storm
WAVES=off                # wave forcing
   REINITIALIZESWAN=no   # used to bounce the wave solution
VARFLUX=off              # variable river flux forcing
#
CYCLETIMELIMIT="99:00:00"

# Computational Resources (related defaults set in platforms.sh)

NCPU=15                # number of compute CPUs for all simulations
NCPUCAPACITY=9999
NUMWRITERS=1
#PPN=40
#JOBLAUNCHER='srun -n %totalcpu%'

# Post processing and publication

INTENDEDAUDIENCE=general    # "general" | "developers-only" | "professional"
OPENDAPPOST=opendap_post2.sh
POSTPROCESS=( null_post.sh )
#POSTPROCESS=( includeWind10m.sh createOPeNDAPFileList.sh $OPENDAPPOST )
OPENDAPNOTIFY="coastalrisk.live@outlook.com,pub.coastalrisk.live@outlook.com,jason.fleming@seahorsecoastal.com,jason.fleming@stormsurge.live"
#hooksScripts[FINISH_SPINUP_SCENARIO]=" output/createOPeNDAPFileList.sh output/$OPENDAPPOST "
#hooksScripts[FINISH_NOWCAST_SCENARIO]=" output/createOPeNDAPFileList.sh output/$OPENDAPPOST "

# Monitoring

enablePostStatus="no"
enableStatusNotify="no"
statusNotify="null"
EMAILNOTIFY="no"

# Initial state (overridden by STATEFILE after ASGS gets going)

COLDSTARTDATE=2026021000
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
