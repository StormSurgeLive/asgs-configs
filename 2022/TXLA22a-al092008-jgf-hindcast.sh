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
# Copyright(C) 2022 Jason Fleming
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

INSTANCENAME=TXLA22a-al092008-jgf-hindcast     # "name" of this ASGS process

# Initial conditions

COLDSTARTDATE=2008081100
HOTORCOLD=coldstart
LASTSUBDIR=null

# Input files and templates

GRIDNAME=TXLA22a
source $SCRIPTDIR/config/mesh_defaults.sh
STORM=09              # storm number, e.g. 05=ernesto in 2006
YEAR=2008             # year of the storm
TRIGGER=rssembedded
RSSSITE=filesystem
FTPSITE=$RSSSITE
FDIR=$WORK/storm-archive/ike
HDIR=$FDIR
PSEUDOSTORM=yes

# Physical forcing (defaults set in config/forcing_defaults.sh)

TIDEFAC=on               # tide factor recalc
   HINDCASTLENGTH=30.0   # length of initial hindcast, from cold (days)
BACKGROUNDMET=off        # NAM download/forcing
   FORECASTCYCLE="06,12,18,00"
TROPICALCYCLONE=on       # tropical cyclone forcing
WAVES=off                # wave forcing
   REINITIALIZESWAN=no   # used to bounce the wave solution
VARFLUX=off              # variable river flux forcing

# Computational Resources (related defaults set in platforms.sh)

NCPU=959           # number of compute CPUs for all simulations
NUMWRITERS=1       # number of writers, usually 1
NCPUCAPACITY=9999  # total max number of CPUs used concurrently

# Post processing and publication

INTENDEDAUDIENCE=general    # "general" | "developers-only" | "professional"
POSTPROCESS=( includeWind10m.sh createOPeNDAPFileList.sh opendap_post.sh )
OPENDAPNOTIFY="null"
hooksScripts[FINISH_SPINUP_SCENARIO]=" output/createOPeNDAPFileList.sh output/opendap_post.sh "
hooksScripts[FINISH_NOWCAST_SCENARIO]=" output/createOPeNDAPFileList.sh output/opendap_post.sh "

# Monitoring

RMQMessaging_Enable="off"
RMQMessaging_Transmit="off"
enablePostStatus="no"
enableStatusNotify="no"
statusNotify="null"

# Scenario package

#PERCENT=default
SCENARIOPACKAGESIZE=0 # <-<< will not run any forecasts
case $si in
   -2)
       ENSTORM=hindcast
       ;;
   -1)
       # do nothing ... this is not a forecast
       ENSTORM=nowcast
       ;;
    0)
       ENSTORM=nhcConsensus
       ;;
    *)
       echo "CONFIGRATION ERROR: Unknown ensemble member number: '$si'."
      ;;
esac
PREPPEDARCHIVE=prepped_${GRIDNAME}_${INSTANCENAME}_${NCPU}.tar.gz
HINDCASTARCHIVE=prepped_${GRIDNAME}_hc_${INSTANCENAME}_${NCPU}.tar.gz
