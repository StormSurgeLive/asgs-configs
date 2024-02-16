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

INSTANCENAME=shinnecock-al102023-alt   # "name" of this ASGS process

# Input files and templates

GRIDNAME=Shinnecock-parameters
source $SCRIPTDIR/config/mesh_defaults.sh

# Initial condition

COLDSTARTDATE=2023082500  # calendar year month day hour YYYYMMDDHH24
HOTORCOLD=coldstart       # "hotstart" or "coldstart"
LASTSUBDIR=null           # path to previous execution (if HOTORCOLD=hotstart)

# Forcing

TIDEFAC=on              # tide factor recalc
   HINDCASTLENGTH=5.0   # length of initial hindcast, from cold (days)
BACKGROUNDMET=off       # synoptic download/forcing
   FORECASTCYCLE="06"
   GFSFORECASTLENGTH=24
TROPICALCYCLONE=on      # tropical cyclone forcing
   STORM=10             # storm number, e.g. 05=ernesto in 2006
   YEAR=2023            # year of the storm
   VORTEXMODEL=GAHM     # default is GAHM (NWS20); ASYMMETRIC (NWS19) possible
   RSSSITE=filesystem
   FTPSITE=filesystem
   FDIR=~/scratch/al102023
   HDIR=$FDIR
WAVES=on                # wave forcing
   REINITIALIZESWAN=no  # used to bounce the wave solution
   SWANHSFULL=no        # don't create a fulldomain swan hotstart file
VARFLUX=off             # variable river flux forcing

# Physics
bottom_friction_limit=0.003                #<--<< ADCIRC Parameter
advection="on"                             #<--<< ADCIRC Parameter
metControl["WindDragLimit"]="0.0020"       #<--<< ADCIRC Parameter

# Nodal Attributes
nodal_attribute_default_values["sea_surface_height_above_geoid"]="0.001" #<--<< ADCIRC Parameter

# Computational Resources

NCPU=2                      # number of compute CPUs for all simulations
NUMWRITERS=1
NCPUCAPACITY=20
CYCLETIMELIMIT="99:00:00"

# Post processing and publication

INTENDEDAUDIENCE=developers-only
OPENDAPPOST=opendap_post2.sh
#POSTPROCESS=( includeWind10m.sh createOPeNDAPFileList.sh $OPENDAPPOST )
POSTPROCESS=( includeWind10m.sh  )
OPENDAPNOTIFY="null"
#hooksScripts[FINISH_SPINUP_SCENARIO]=" output/createOPeNDAPFileList.sh output/$OPENDAPPOST "
#hooksScripts[FINISH_NOWCAST_SCENARIO]=" output/createOPeNDAPFileList.sh output/$OPENDAPPOST "
#
netcdf_metadata["NCHOST"]="frontera.tacc.utexas.edu"           #<--<< ADCIRC Parameter
netcdf_metadata["NCCONT"]="jason.fleming@seahorsecoastal.com"  #<--<< ADCIRC Parameter

# Monitoring and Logging

OPENDAPNOTIFY="null"
NOTIFY_SCRIPT=null_notify.sh
enablePostStatus="no"
enableStatusNotify="no"
statusNotify="null"
#
nfover="1 19.0 1 99 30.0"  #<--<< ADCIRC Parameter: nonfatal override; warnelev and errorelev
log_level="ECHO"           #<--<< ADCIRC Parameter: NABOUT (DEBUG=-1, ECHO=0, INFO=1, WARNING=2, ERROR=3)

# Scenario package

#PERCENT=default
SCENARIOPACKAGESIZE=2 # number of storms in the ensemble
case $si in
-2)
   ENSTORM=hindcast
   OPENDAPNOTIFY="null"
   ;;
-1)
   # do nothing ... this is not a forecast
   ENSTORM=nowcast
   OPENDAPNOTIFY="null"
   ;;
 0)
   ENSTORM=nhcConsensusWind10m
   source $SCRIPTDIR/config/io_defaults.sh # sets met-only mode based on "Wind10m" suffix
   ;;
1)
   ENSTORM=nhcConsensus
   ;;
*)
   echo "CONFIGRATION ERROR: Unknown scenario number: '$si'."
   ;;
esac

PREPPEDARCHIVE=prepped_${GRIDNAME}_${INSTANCENAME}_${NCPU}.tar.gz
HINDCASTARCHIVE=prepped_${GRIDNAME}_hc_${INSTANCENAME}_${NCPU}.tar.gz
