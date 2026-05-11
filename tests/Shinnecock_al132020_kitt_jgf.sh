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

INSTANCENAME=Shinnecock_al132020_kitt_jgf # "name" of this ASGS process

# Input files and templates

GRIDNAME=Shinnecock
parameterPackage=default
createWind10mLayer="no"  # don't need this because there are no wind roughnesses
source $SCRIPTDIR/config/mesh_defaults.sh

# Physical forcing (defaults set in config/forcing_defaults.sh)

TIDEFAC=on               # tide factor recalc
   HINDCASTLENGTH=1.0   # length of initial hindcast, from cold (days)
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

NCPU=3                 # number of compute CPUs for all simulations
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

COLDSTARTDATE=2020082300
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
       ENSTORM=09.nhcTrack       # track 09
       PERCENT=default
       ;;
    1)
       ENSTORM=03.veerLeft75     # track 03
       PERCENT=-75
       ;;
    2)
       ENSTORM=15.veerRight75    # track 15
       PERCENT=75
       ;;
    3)
       ENSTORM=01.veerLeft100    # track 01
       PERCENT=-100
       ;;
    4)
       ENSTORM=02.veerLeft87.5   # track 02
       PERCENT=-87.5
       ;;
    5)
       ENSTORM=04.veerLeft62.5   # track 04
       PERCENT=-62.5
       ;;
    6)
       ENSTORM=05.veerLeft50     # track 05
       PERCENT=-75
       ;;
    7)
       ENSTORM=06.veerLeft37.5   # track 06
       PERCENT=-37.5
       ;;
    8)
       ENSTORM=07.veerLeft25     # track 07
       PERCENT=-25
       ;;
    9)
       ENSTORM=08.veerLeft12.5   # track 08
       PERCENT=-12.5
       ;;
   10)
       ENSTORM=10.veerRight12.5  # track 10
       PERCENT=12.5
       ;;
   11)
       ENSTORM=11.veerRight25    # track 11
       PERCENT=25
       ;;
   12)
       ENSTORM=12.veerRight37.5  # track 12
       PERCENT=37.5
       ;;
   13)
       ENSTORM=13.veerRight50    # track 13
       PERCENT=50
       ;;
   14)
       ENSTORM=14.veerRight62.5  # track 14
       PERCENT=62.5
       ;;
   15)
       ENSTORM=16.veerRight87.5  # track 16
       PERCENT=87.5
       ;;
   16)
       ENSTORM=17.veerRight100   # track 17
       PERCENT=100
       ;;
    *)
       echo "CONFIGURATION ERROR: Unknown scenario number: '$si'."
       ;;
esac
#
PREPPEDARCHIVE=prepped_${GRIDNAME}_${INSTANCENAME}_${NCPU}.tar.gz
HINDCASTARCHIVE=prepped_${GRIDNAME}_hc_${INSTANCENAME}_${NCPU}.tar.gz
