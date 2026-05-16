#!/bin/sh
#-------------------------------------------------------------------
# Test large forecast scenario package
#-------------------------------------------------------------------
#
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

INSTANCENAME=EC95d_al132020_kitt_jgf_branching # "name" of this ASGS process

# Input files and templates

GRIDNAME=EC95d
parameterPackage=default
createWind10mLayer="no"  # don't need this because there are no wind roughnesses
source $SCRIPTDIR/config/mesh_defaults.sh

# Physical forcing (defaults set in config/forcing_defaults.sh)

TIDEFAC=on               # tide factor recalc
   HINDCASTLENGTH=30.0   # length of initial hindcast, from cold (days)
BACKGROUNDMET=off        # NAM/GFS download/forcing
   FORECASTCYCLE="00,06,12,18"
TROPICALCYCLONE=on       # tropical cyclone forcing
   STORM=13              # storm number, e.g. 05=ernesto in 2006
   YEAR=2020             # year of the storm
   FDIR=$WORK
   HDIR="$FDIR"
   RSSSITE=filesystem
   FTPSITE=filesystem
WAVES=off                # wave forcing
   REINITIALIZESWAN=no   # used to bounce the wave solution
VARFLUX=off              # variable river flux forcing
#
CYCLETIMELIMIT="99:00:00"

# Computational Resources (related defaults set in platforms.sh)

NCPU=15                 # number of compute CPUs for all simulations
NCPUCAPACITY=16
NUMWRITERS=1

# Post processing and publication

INTENDEDAUDIENCE=general    # "general" | "developers-only" | "professional"
OPENDAPPOST=opendap_post2.sh
#POSTPROCESS=( includeWind10m.sh createOPeNDAPFileList.sh $OPENDAPPOST )
#hooksScripts[FINISH_SPINUP_SCENARIO]=" output/createOPeNDAPFileList.sh output/$OPENDAPPOST "
#hooksScripts[FINISH_NOWCAST_SCENARIO]=" output/includeWind10m.sh output/createOPeNDAPFileList.sh output/$OPENDAPPOST "
OPENDAPNOTIFY="jason.fleming@stormsurge.live"

# Monitoring

enablePostStatus="no"
enableStatusNotify="no"
statusNotify="null"

# Initial state (overridden by STATEFILE after ASGS gets going)

COLDSTARTDATE=2020072300
HOTORCOLD=coldstart
LASTSUBDIR=null
#
# Scenario package
#
case $si in
   -2)
       ENSTORM=hindcast
       OPENDAPNOTIFY="null"
       ;;
   -1)
       ENSTORM=nowcast
       OPENDAPNOTIFY="null"
       ;;
    0)
       ENSTORM=branching09
       ;;
    1)
       ENSTORM=branching03
       ;;
    2)
       ENSTORM=branching15
       ;;
    3)
       ENSTORM=branching06
       ;;
    4)
       ENSTORM=branching12
       ;;
    5)
       ENSTORM=branching17
       ;;
    6)
       ENSTORM=branching01
       ;;
    7)
       ENSTORM=branching05
       ;;
    8)
       ENSTORM=branching13
       ;;
    9)
       ENSTORM=branching11
       ;;
   10)
       ENSTORM=branching07
       ;;
   11)
       ENSTORM=branching14
       ;;
   12)
       ENSTORM=branching16
       ;;
   13)
       ENSTORM=branching10
       ;;
   14)
       ENSTORM=branching08
       ;;
   15)
       ENSTORM=branching02
       ;;
   16)
       ENSTORM=branching04
       ;;
    *)
       echo "CONFIGURATION ERROR: Unknown scenario number: '$si'."
       ;;
esac
#
PREPPEDARCHIVE=prepped_${GRIDNAME}_${INSTANCENAME}_${NCPU}.tar.gz
HINDCASTARCHIVE=prepped_${GRIDNAME}_hc_${INSTANCENAME}_${NCPU}.tar.gz
