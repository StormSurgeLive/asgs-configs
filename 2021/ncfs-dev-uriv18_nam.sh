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
# ASGS is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# the ASGS.  If not, see <http://www.gnu.org/licenses/>.
#-------------------------------------------------------------------

# Fundamental

INSTANCENAME=uriv18-nam-bob-2021      # "name" of this ASGS process
SCRATCHDIR=/projects/ncfs-dev/${INSTANCENAME}
RMQMessaging_Transmit=on

# Input files and templates

GRIDNAME=uriv18
source $SCRIPTDIR/config/mesh_defaults.sh

#--------------------------------------------------------------------------
#  changes for 0.2286m sea_surface_height_above_geoid
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
# The default values of the following parameters are set in
# config/mesh_defaults.sh, so these settings have to come after the
# sourcing of the mesh_defaults.sh script.
CONTROLTEMPLATE=fort.15.template
CONTROLPROPERTIES=${CONTROLTEMPLATE}.properties
NAFILE=uriv18.13
NAPROPERTIES=${NAFILE}.properties

# Initial state (overridden by STATEFILE after ASGS gets going)

COLDSTARTDATE=2021080100  #  2020080100  # calendar year month day hour YYYYMMDDHH24
HOTORCOLD=coldstart       # "hotstart" or "coldstart"
LASTSUBDIR=null

# Physical forcing (defaults set in config/forcing_defaults.sh)

TIDEFAC=on                # tide factor recalc
   HINDCASTLENGTH=18    # length of initial hindcast, from cold (days)
BACKGROUNDMET=on          # NAM download/forcing
   FORECASTCYCLE="00,06,12,18"
TROPICALCYCLONE=off       # tropical cyclone forcing
   STORM=-1               # storm number, e.g. 05=ernesto in 2006
   YEAR=2021              # year of the storm
WAVES=off                 # wave forcing
   REINITIALIZESWAN=no    # used to bounce the wave solution
VARFLUX=off               # variable river flux forcing
   RIVERSITE=data.disaster.renci.org
   RIVERDIR=/opt/ldm/storage/SCOOP/RHLRv9-OKU
   RIVERUSER=bblanton
   RIVERDATAPROTOCOL=scp
CYCLETIMELIMIT="99:00:00"

# Computational Resources (related defaults set in platforms.sh)

NCPU=508                     # number of compute CPUs for all simulations
NCPUCAPACITY=512
#NCPU=511                     # number of compute CPUs for all simulations
#NCPUCAPACITY=512
NUMWRITERS=4
ACCOUNT=null
PARTITION=ncfs
 
# Post processing and publication

INTENDEDAUDIENCE="developers-only" # general" # ( | "developers-only" | "professional"
#POSTPROCESS=( accumulateMinMax.sh createMaxCSV.sh cpra_slide_deck_post.sh includeWind10m.sh createOPeNDAPFileList.sh opendap_post.sh )
#POSTPROCESS=( includeWind10m.sh createOPeNDAPFileList.sh opendap_post.sh transmit_rps.sh )
POSTPROCESS=( createOPeNDAPFileList.sh opendap_post.sh transmit_rps.sh ncfs_post_to_current.sh )
#OPENDAPNOTIFY="asgs.cera.lsu@gmail.com jason.g.fleming@gmail.com"
#OPENDAPNOTIFY="bblanton@renci.org, asgs.cera.lsu@gmail.com, rluettich1@gmail.com, jason.g.fleming@gmail.com, asgsnotifications@opayq.com, cera.asgs.tk@gmail.com, asgsnotes4ian@gmail.com, janelle.fleming@seahorsecoastal.com"
OPENDAPNOTIFY="bblanton@renci.org, rluettich1@gmail.com, dullman@uri.edu, dcrowley@uri.edu, iginis@uri.edu"
#OPENDAPNOTIFY="bblanton@renci.org"
NOTIFY_SCRIPT=ncfs_nam_notify.sh

# Scenario package

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
       ENSTORM=namforecast
       ;;
    1)
       ENSTORM=namforecastWind10m
       source $SCRIPTDIR/config/io_defaults.sh # sets met-only mode based on "Wind10m" suffix
       ;;
    *)   
       echo "CONFIGRATION ERROR: Unknown ensemble member number: '$si'."
      ;;
esac

PREPPEDARCHIVE=prepped_${GRIDNAME}_${INSTANCENAME}_${NCPU}.tar.gz
HINDCASTARCHIVE=prepped_${GRIDNAME}_hc_${INSTANCENAME}_${NCPU}.tar.gz
