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
# Copyright(C) 2019 Jason Fleming
#
# This file is part of the ADCIRC Surge Guidance System (ASGS).
#
# The ASGS is free software: you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
## ASGS is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# the ASGS.  If not, see <http://www.gnu.org/licenses/>.
#-------------------------------------------------------------------

# Fundamental

INSTANCENAME=v54.01-custom-hatteras-ec95d      # "name" of this ASGS process
SCRATCHDIR=/projects/ees/dhs-crc/joshua_p/asgs/${INSTANCENAME}
#QSCRIPTTEMPLATE=$SCRIPTDIR/config/2022/ncfs-dev/qscript.template.renci
QSCRIPTTEMPLATE=$SCRIPTDIR/qscript.template.renci  # Custom template pulled from Shintaro's directory, per 5/27/22 email from Brian Blanton
RMQMessaging_Transmit=on  # was right under SCRATCHDIR, but moved before RMQ to try to avoid module-related errors 
ADCIRCDIR=/home/dullman/adcirc-cg/work  # Dave Ullman's modified version of ADCIRC 

# Input files and templates

GRIDNAME=ec95d
source $SCRIPTDIR/config/mesh_defaults.sh

# Initial state (overridden by STATEFILE after ASGS gets going)

COLDSTARTDATE=2022062600  # calendar year month day hour YYYYMMDDHH24
HOTORCOLD=coldstart       # "hotstart" or "coldstart"
LASTSUBDIR=null

# Physical forcing (defaults set in config/forcing_defaults.sh)

TIDEFAC=on               # tide factor recalc
   HINDCASTLENGTH=14.0   # length of initial hindcast, from cold (days)
BACKGROUNDMET=GFS        # wind download/forcing; set to "on" or "NAM" for NAM
   #FORECASTCYCLE="00,06,12,18"
   FORECASTCYCLE="00,12" # reduced cadence to be mindful of CPU time while testing
TROPICALCYCLONE=off      # tropical cyclone forcing
   STORM=-1              # storm number, e.g. 05=ernesto in 2006
   YEAR=2021             # year of the storm
WAVES=off                # wave forcing
   REINITIALIZESWAN=off  # used to bounce the wave solution
VARFLUX=off              # variable river flux forcing
   RIVERSITE=data.disaster.renci.org
   RIVERDIR=/opt/ldm/storage/SCOOP/RHLRv9-OKU
   RIVERUSER=bblanton
   RIVERDATAPROTOCOL=scp
CYCLETIMELIMIT="99:00:00"

# Computational Resources (related defaults set in platforms.sh)
# INCREASE THIS ONCE YOU'RE USING THE URI MESH.

NCPU=64                    # number of compute CPUs for all simulations
NCPUCAPACITY=64
NUMWRITERS=0
ACCOUNT=null
#EXCLUDE="compute-9-xx"
QUEUENAME="lowpri"

# Post processing and publication

INTENDEDAUDIENCE=developers-only    # "general" | "developers-only" | "professional"

FINISH_NOWCAST_SCENARIO=( output/opendap_post_nowcast.sh ) # output/run_adda.sh )
POSTPROCESS=( richamp_scale_and_subset.sh createOPeNDAPFileList.sh opendap_post.sh transmit_rps.sh )

OPENDAPNOTIFY="joshua_port@uri.edu"
#NOTIFY_SCRIPT=ncfs_nam_notify.sh
#NOTIFY_SCRIPT=null_notify.sh
NOTIFY_SCRIPT=blanton_cyclone_notify.sh

# Scenario package

#PERCENT=default
SCENARIOPACKAGESIZE=3 # setting to 1-10 makes ASGS generate 1-10 forecasts too. 0 is just nowcasts.
case $si in
   -2) 
       ENSTORM=hindcast
       ;;
   -1)      
       # do nothing ... this is not a forecast
       ENSTORM=nowcast
       ;;
    0)
       ENSTORM=gfsforecast  # was namforecast; updated in case the product name is a keyword
       ;;
    1)
       ENSTORM=veerLeftEdge
       PERCENT=-100 # -100 for left edge, 100 for right edge
       ;;
    2) ENSTORM=veerRightEdge
       PERCENT=100
       ;;
    *)   
       echo "CONFIGRATION ERROR: Unknown ensemble member number: '$si'."
      ;;
esac

PREPPEDARCHIVE=prepped_${GRIDNAME}_${INSTANCENAME}_${NCPU}.tar.gz
HINDCASTARCHIVE=prepped_${GRIDNAME}_hc_${INSTANCENAME}_${NCPU}.tar.gz
