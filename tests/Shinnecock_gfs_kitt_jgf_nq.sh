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

INSTANCENAME=Shinnecock_gfs_kitt_jgf_nq # "name" of this ASGS process

# Input files and templates

GRIDNAME=Shinnecock
parameterPackage=default
createWind10mLayer="yes"  # don't need this because there are no wind roughnesses
source $SCRIPTDIR/config/mesh_defaults.sh

# Physical forcing (defaults set in config/forcing_defaults.sh)

TIDEFAC=on              # tide factor recalc
   HINDCASTLENGTH=1.0   # length of initial hindcast, from cold (days)
BACKGROUNDMET=GFS       # NAM/GFS download/forcing
   FORECASTCYCLE="00,06,12,18"
TROPICALCYCLONE=off      # tropical cyclone forcing
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
NCPUCAPACITY=15
NUMWRITERS=0

# Post processing and publication

INTENDEDAUDIENCE=general    # "general" | "developers-only" | "professional"
OPENDAPPOST=opendap_post2.sh
POSTPROCESS=( null_post.sh )
OPENDAPNOTIFY="null"

# Monitoring

enablePostStatus="no"
enableStatusNotify="no"
statusNotify="null"
EMAILNOTIFY="no"

# Initial state (overridden by STATEFILE after ASGS gets going)

COLDSTARTDATE=2026060600
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
    *)
       echo "CONFIGURATION ERROR: Unknown scenario number: '$si'."
       ;;
esac
#
PREPPEDARCHIVE=prepped_${GRIDNAME}_${INSTANCENAME}_${NCPU}.tar.gz
HINDCASTARCHIVE=prepped_${GRIDNAME}_hc_${INSTANCENAME}_${NCPU}.tar.gz
