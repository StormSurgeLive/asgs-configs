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
# Copyright(C) 2018--2021 Jason Fleming
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
# The defaults for parameters that can be reset in this config file
# are preset in the following scripts:
# {SCRIPTDIR/platforms.sh               # also contains Operator-specific info
# {SCRIPTDIR/config/config_defaults.sh
# {SCRIPTDIR/config/mesh_defaults.sh
# {SCRIPTDIR/config/forcing_defaults.sh
# {SCRIPTDIR/config/io_defaults.sh
# {SCRIPTDIR/config/operator_defaults.sh
#-------------------------------------------------------------------

# Fundamental

INSTANCENAME=EC2001v2e_nam_50s_jgf  # "name" of this ASGS process

# Input files and templates

GRIDNAME=EC2001v2e
source $SCRIPTDIR/config/mesh_defaults.sh
# change values loaded from mesh_defaults.sh:
CONTROLTEMPLATE=ec2001_v2e_adcircv55_fort.15.template # designed for larger timestep (e.g., 50s)
TIMESTEPSIZE=50.0

# Physical forcing (defaults set in config/forcing_defaults)

TIDEFAC=on            # tide factor recalc
HINDCASTLENGTH=15.0   # length of initial hindcast, from cold (days)
BACKGROUNDMET=on      # NAM download/forcing
FORECASTCYCLE="06"
   forecastSelection="strict"
TROPICALCYCLONE=off   # tropical cyclone forcing
#STORM=07             # storm number, e.g. 05=ernesto in 2006
#YEAR=2018            # year of the storm
WAVES=off             # wave forcing
REINITIALIZESWAN=no   # used to bounce the wave solution
VARFLUX=off           # variable river flux forcing
CYCLETIMELIMIT="99:00:00"

# Computational Resources (related defaults set in platforms.sh)

NCPU=15                # number of compute CPUs for all simulations
NUMWRITERS=1
NCPUCAPACITY=9999
# since this will only run on one node, even in parallel, need
# to submit it to the single queue on queenbeeC
if [[ $HPCENV = "qbc.loni.org" && $NCPU -lt 48 ]]; then
   QUEUENAME="single"
fi

# Post processing and publication

INTENDEDAUDIENCE=general    # can also be "developers-only" or "professional"
#POSTPROCESS=( createMaxCSV.sh cpra_slide_deck_post.sh includeWind10m.sh createOPeNDAPFileList.sh opendap_post.sh )
POSTPROCESS=( createMaxCSV.sh includeWind10m.sh )
#OPENDAPNOTIFY="asgs.cera.lsu@gmail.com,jason.g.fleming@gmail.com,rluettich@gmail.com,cera.asgs.tk@gmail.com,asgsnotes4ian@gmail.com,asgsnotifications@opayq.com"
OPENDAPNOTIFY="jason.g.fleming@gmail.com"
TDS=( )

# Initial state (overridden by STATEFILE after ASGS gets going)

COLDSTARTDATE=2021032000
HOTORCOLD=coldstart      # "hotstart" or "coldstart"
LASTSUBDIR=null

# I/O parameters

# Add for testing with ADCIRPOLATE
# fulldomain or subdomain hotstart files
HOTSTARTCOMP=subdomain
# binary or netcdf hotstart files
HOTSTARTFORMAT=binary

# Scenario package

#PERCENT=default
SCENARIOPACKAGESIZE=2 # number of storms in the ensemble
case $si in
 -2)
   ENSTORM=hindcast
   ;;
-1)
   # do nothing ... this is not a forecast
   ENSTORM=nowcast
   ;;
 0)
   ENSTORM=namforecastWind10m
   source $SCRIPTDIR/config/io_defaults.sh # sets met-only mode based on "Wind10m" suffix
   # Add for testing with ADCIRPOLATE
   # FIXME: had to add these here due to them getting reset in io_defaults.sh; need
   # to have ASGS handle this automatically
   # fulldomain or subdomain hotstart files
   HOTSTARTCOMP=subdomain
   # binary or netcdf hotstart files
   HOTSTARTFORMAT=binary
   NCPU=15
   ;;
1)
   ENSTORM=namforecast
   ;;
*)
   echo "CONFIGRATION ERROR: Unknown scenario number: '$si'."
   ;;
esac

PREPPEDARCHIVE=prepped_${GRIDNAME}_${INSTANCENAME}_${NCPU}.tar.gz
HINDCASTARCHIVE=prepped_${GRIDNAME}_hc_${INSTANCENAME}_${NCPU}.tar.gz
