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
# Copyright(C) 2025 Jason Fleming
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

INSTANCENAME=HSOFS_al132025rrfsBlend_qbd_jgf # "name" of this ASGS process

# Input files and templates

GRIDNAME=HSOFS
parameterPackage=default   # <-----<<
createWind10mLayer="yes"   # <-----<<
source $SCRIPTDIR/config/mesh_defaults.sh

#--------------------------------------------------------------
# -- I N C R E A S E   I N I T I A L   W A T E R   L E V E L --
#
# use fort.13 template that has this nodal attribute in it (unlike the default fort.13 template for HSOFS)
NAFILE=hsofs-parameters-v2.13
#
# add 15cm to the default initial water level for this mesh (HSOFS is 0.0 by default)
stericOffset=0.15
newValue=$(printf "%.4f" $(echo ${nodal_attribute_default_values["sea_surface_height_above_geoid"]} + $stericOffset | bc -l))
nodal_attribute_default_values["sea_surface_height_above_geoid"]=$newValue
#
# add this nodal attribute to fort.15 files for this instance (it is not activated by default for HSOFS)
nodal_attribute_activate+=( sea_surface_height_above_geoid )
#--------------------------------------------------------------

# Physical forcing (defaults set in config/forcing_defaults.sh)

TIDEFAC=on               # tide factor recalc
   HINDCASTLENGTH=20.0   # length of initial hindcast, from cold (days)
BACKGROUNDMET=rrfsBlend # RRFS download/blending/forcing
   FORECASTCYCLE="00,06,12,18"
TROPICALCYCLONE=on       # tropical cyclone forcing
   STORM=13              # storm number, e.g. 05=ernesto in 2006
   YEAR=2025             # year of the storm
WAVES=on                 # wave forcing
   REINITIALIZESWAN=no   # used to bounce the wave solution
VARFLUX=off              # variable river flux forcing
#
CYCLETIMELIMIT="99:00:00"

# Computational Resources (related defaults set in platforms.sh)

NCPU=959                 # number of compute CPUs for all simulations
NCPUCAPACITY=9999
NUMWRITERS=1

# Post processing and publication

INTENDEDAUDIENCE=developers-only   # "general" | "developers-only" | "professional"
OPENDAPPOST=opendap_post2.sh
#POSTPROCESS=( null_post.sh )
POSTPROCESS=( includeWind10m.sh createOPeNDAPFileList.sh $OPENDAPPOST )
OPENDAPNOTIFY="coastalrisk.live@outlook.com,pub.coastalrisk.live@outlook.com,asgs.cera.pub.lsu@coastalrisk.live,asgs.cera.lsu@coastalrisk.live"
hooksScripts[FINISH_SPINUP_SCENARIO]=" output/createOPeNDAPFileList.sh output/$OPENDAPPOST "
hooksScripts[FINISH_NOWCAST_SCENARIO]=" output/createOPeNDAPFileList.sh output/$OPENDAPPOST "

# Monitoring

EMAILNOTIFY="yes"
enablePostStatus="yes"
enableStatusNotify="no"
statusNotify="null"

# Initial state (overridden by STATEFILE after ASGS gets going)

COLDSTARTDATE=auto
HOTORCOLD=hotstart
LASTSUBDIR=https://fortytwo.cct.lsu.edu/thredds/fileServer/2025/GFS/2025102500/HSOFS/qbc.loni.org/HSOFS_gfs_qbc_of_015_sn/gfsforecast

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
       ;;
    0)
       ENSTORM=nhcConsensus
       ;;
    *)
       echo "CONFIGURATION ERROR: Unknown ensemble member number: '$si'."
      ;;
esac
#
PREPPEDARCHIVE=prepped_${GRIDNAME}_${INSTANCENAME}_${NCPU}.tar.gz
HINDCASTARCHIVE=prepped_${GRIDNAME}_hc_${INSTANCENAME}_${NCPU}.tar.gz
