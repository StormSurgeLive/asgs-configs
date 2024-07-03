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
# Copyright(C) 2020 Jason Fleming
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

# "name" of this ASGS process
INSTANCENAME=TXLA22a_al022024_frontera_be
ASGSADMIN="asgsnotifications@memenesia.net"

# Input files and templates

GRIDNAME=TXLA22a
source $SCRIPTDIR/config/mesh_defaults.sh

# Initial state (overridden by STATEFILE after ASGS gets going)

HOTORCOLD=coldstart
COLDSTARTDATE=$(get-coldstart-date)
LASTSUBDIR=null

# Physical forcing (defaults set in config/forcing_defaults.sh)

TIDEFAC=on               # tide factor recalc
   HINDCASTLENGTH=30.0   # length of initial hindcast, from cold (days)
BACKGROUNDMET=off        # NAM download/forcing
   FORECASTCYCLE="00,06,12,18"
TROPICALCYCLONE=on       # tropical cyclone forcing
   STORM=02              # storm number, e.g. 05=ernesto in 2006
   YEAR=2024             # year of the storm
WAVES=on                 # wave forcing
   REINITIALIZESWAN=no   # used to bounce the wave solution
VARFLUX=off              # variable river flux forcing
CYCLETIMELIMIT="99:00:00"

# Computational Resources (related defaults set in platforms.sh)
NCPU=1459                # number of compute CPUs for all simulations
NCPUCAPACITY=9999
NUMWRITERS=1

enablePostStatus="yes"
enableStatusNotify="yes"
statusNotify="jason.g.fleming@gmail.com,coastalrisk.live@outlook.com,pub.coastalrisk.live@outlook.com,asgs.cera.pub.lsu@coastalrisk.live,asgs.cera.lsu@coastalrisk.live,asgsnotify@memenesia.net"

# Post processing and publication
EMAILNOTIFY=yes
INTENDEDAUDIENCE=general    # "general" | "developers-only
OPENDAPPOST=opendap_post2.sh
POSTPROCESS=( createMaxCSV.sh includeWind10m.sh createOPeNDAPFileList.sh $OPENDAPPOST )
OPENDAPNOTIFY="jason.g.fleming@gmail.com,coastalrisk.live@outlook.com,pub.coastalrisk.live@outlook.com,asgs.cera.pub.lsu@coastalrisk.live,asgs.cera.lsu@coastalrisk.live,asgsnotify@memenesia.net"
NOTIFY_SCRIPT=cera_notify.sh
TDS=( tacc_tds3 )

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
       OPENDAPNOTIFY="jason.g.fleming@gmail.com,asgsnotify@memenesia.net"
       ;;
    0)
       ENSTORM=nhcConsensus
       OPENDAPNOTIFY="jason.g.fleming@gmail.com,coastalrisk.live@outlook.com,pub.coastalrisk.live@outlook.com,asgs.cera.pub.lsu@coastalrisk.live,asgs.cera.lsu@coastalrisk.live,asgsnotify@memenesia.net"
       ;;
#    1)
#       ENSTORM=nhcConsensusWind10m
#       OPENDAPNOTIFY="jason.g.fleming@gmail.com,asgsnotify@memenesia.net"
#       ;;
    *)
       echo "CONFIGURATION ERROR: Unknown ensemble member number: '$si'."
      ;;
esac
source $SCRIPTDIR/config/io_defaults.sh # sets met-only mode based on "Wind10m" suffix
#
PREPPEDARCHIVE=prepped_${GRIDNAME}_${INSTANCENAME}_${NCPU}.tar.gz
HINDCASTARCHIVE=prepped_${GRIDNAME}_hc_${INSTANCENAME}_${NCPU}.tar.gz
