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
INSTANCENAME=EGOMv20b_al092022
ACCOUNT=ADCIRC
QOS=vippj_p3000 # for priority during a storm
PPN=128 # ls6
ASGSADMIN="asgsnotifications@opayq.com"

# Input files and templates

GRIDNAME=EGOMv20b
source $SCRIPTDIR/config/mesh_defaults.sh

# Initial state (overridden by STATEFILE after ASGS gets going)

COLDSTARTDATE=$(get-coldstart-date)
HOTORCOLD=hotstart
LASTSUBDIR=https://fortytwo.cct.lsu.edu/thredds/fileServer/2022/al09/01/EGOMv20b/mike.hpc.lsu.edu/EGOMv20b_al092022_jgf_mike3/nhcConsensus

RMQMessaging_Enable="off"
RMQMessaging_Transmit="off"

# Physical forcing (defaults set in config/forcing_defaults.sh)

TIDEFAC=on               # tide factor recalc
   HINDCASTLENGTH=30.0   # length of initial hindcast, from cold (days)
BACKGROUNDMET=off        # NAM download/forcing
   FORECASTCYCLE="06"
TROPICALCYCLONE=on      # tropical cyclone forcing
   STORM=09              # storm number, e.g. 05=ernesto in 2006
   YEAR=2022             # year of the storm
WAVES=on                 # wave forcing
   REINITIALIZESWAN=no   # used to bounce the wave solution
VARFLUX=off              # variable river flux forcing
CYCLETIMELIMIT="99:00:00"

# Computational Resources (related defaults set in platforms.sh)
NCPU=959                 # number of compute CPUs for all simulations
NCPUCAPACITY=9999
NUMWRITERS=1

enablePostStatus="yes"
enableStatusNotify="yes"
statusNotify="asgs.cera.lsu@coastalrisk.live,jason.g.fleming@gmail.com,jason.fleming@seahorsecoastal.com,asgsnotifications@opayq.com"

# Post processing and publication

EMAILNOTIFY=yes
INTENDEDAUDIENCE=general    # "general" | "developers-only" | "professional"
OPENDAPPOST=opendap_post2.sh
POSTPROCESS=( createMaxCSV.sh includeWind10m.sh createOPeNDAPFileList.sh $OPENDAPPOST )
OPENDAPNOTIFY="asgs.cera.lsu@coastalrisk.live,jason.g.fleming@gmail.com,asgsnotifications@opayq.com"
NOTIFY_SCRIPT=cera_notify.sh
TDS=( tacc_tds3 )

#
# Scenario package
#
#PERCENT=default
SCENARIOPACKAGESIZE=6
case $si in
   -2)
       ENSTORM=hindcast
       ;;
   -1)
       # do nothing ... this is not a forecast
       ENSTORM=nowcast
       ;;
    0)
       ENSTORM=nhcConsensusWind10m
       ;;
    1)
       ENSTORM=nhcConsensus
       ;;
    2)
       ENSTORM=veerLeft100Wind10m
       PERCENT=-100
       ;;
    3)
       ENSTORM=veerLeft100
       PERCENT=-100
       ;;
    4)
       ENSTORM=veerRight100Wind10m
       PERCENT=100
       ;;
    5)
       ENSTORM=veerRight100
       PERCENT=100
       ;;
    *)
       echo "CONFIGURATION ERROR: Unknown ensemble member number: '$si'."
      ;;
esac
source $SCRIPTDIR/config/io_defaults.sh # sets met-only mode based on "Wind10m" suffix
#
PREPPEDARCHIVE=prepped_${GRIDNAME}_${INSTANCENAME}_${NCPU}.tar.gz
HINDCASTARCHIVE=prepped_${GRIDNAME}_hc_${INSTANCENAME}_${NCPU}.tar.gz
