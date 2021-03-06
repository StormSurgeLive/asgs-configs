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
# Copyright(C) 2006--2018 Jason Fleming
# Copyright(C) 2006, 2007 Brett Estrade 
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
#
# Fundamental 
#
INSTANCENAME=142018hiresr # name of this ASGS process, to differentiate results
COLDSTARTDATE=2018091618
HOTORCOLD=coldstart       # "hotstart" or "coldstart" 
LASTSUBDIR=null
HINDCASTLENGTH=20.0       # length of initial hindcast, from cold (days)
REINITIALIZESWAN=no       # used to bounce the wave solution
SWANHSCOMPRESSION=no

# Source file paths

ADCIRCDIR=~/adcirc/forks/adcirc/v53release/work # ADCIRC executables 
SWANDIR=~/adcirc/forks/adcirc/v53release/swan   # SWAN executables 
SCRIPTDIR=~/asgs/branches/2014stable            # ASGS scripts/executables  
INPUTDIR=${SCRIPTDIR}/input/meshes/nc_v9.99_w_rivers # dir containing grid and other input files 
OUTPUTDIR=${SCRIPTDIR}/output # dir containing post processing scripts
PERL5LIB=${SCRIPTDIR}/PERL    # dir with DateCale.pm perl module

# Physical forcing

BACKGROUNDMET=off    # [de]activate NAM download/forcing 
TIDEFAC=on           # [de]activate tide factor recalc 
TROPICALCYCLONE=on   # [de]activate tropical cyclone forcing (temp. broken)
WAVES=on             # [de]activate wave forcing 
VARFLUX=on           # [de]activate variable river flux forcing

# Computational Resources

TIMESTEPSIZE=0.5
SWANDT=1200
HINDCASTWALLTIME="12:00:00"
ADCPREPWALLTIME="01:15:00"
NOWCASTWALLTIME="05:00:00"  # must have leading zero, e.g., 05:00:00
FORECASTWALLTIME="05:00:00" # must have leading zero, e.g., 05:00:00
NCPU=500
NCPUCAPACITY=1280
NUMWRITERS=10
CYCLETIMELIMIT="05:00:00"
# queue
QUEUENAME=null
SERQUEUE=null
SCRATCHDIR=/projects/ncfs/data # for the NCFS on blueridge
#ACCOUNT=batch # or "ncfs" on hatteras to use pre-empt capability
PARTITION=ncfs
RESERVATION=ncfs
#CONSTRAINT='hatteras&sandybridge'
CONSTRAINT=null

# External data sources : Tropical cyclones

STORM=14  # storm number, e.g. 05=ernesto in 2006 
YEAR=2018 # year of the storm (useful for historical storms) 
TRIGGER=rssembedded       # either "ftp" or "rss"
RSSSITE=www.nhc.noaa.gov 
#RSSSITE=filesystem
FTPSITE=ftp.nhc.noaa.gov  # real anon ftp site for hindcast/forecast files
FDIR=/atcf/afst          # forecast dir on nhc ftp site 
#FDIR=/home/ncfs/asgs/branches/2014stable/input/sample_advisories/2018 # forecast dir on nhc ftp site 
HDIR=/atcf/btk            # hindcast dir on nhc ftp site 

# External data sources : Background Meteorology

FORECASTCYCLE="06,18"
BACKSITE=ftp.ncep.noaa.gov          # NAM forecast data from NCEP
BACKDIR=/pub/data/nccf/com/nam/prod # contains the nam.yyyymmdd files
FORECASTLENGTH=84                   # hours of NAM forecast to run (max 84)
PTFILE=ptFile_oneEighth.txt         # the lat/lons for the OWI background met
ALTNAMDIR="/projects/ncfs/data/asgs16441"

# External data sources : River Flux

#RIVERSITE=ftp.nssl.noaa.gov
#RIVERDIR=/projects/ciflow/adcirc_info

RIVERSITE=data.disaster.renci.org
RIVERDIR=/opt/ldm/storage/SCOOP/RHLRv9-OKU
RIVERUSER=ldm
RIVERDATAPROTOCOL=scp

# Input files and templates

GRIDFILE=nc_inundation_v9.99a_w_rivers.grd
GRIDNAME=nc_inundation_v9.99_w_rivers
MESHPROPERTIES=${GRIDFILE}.properties
CONTROLTEMPLATE=nc_9.99wrivers_vortex_offset_fort.15.template
CONTROLPROPERTIES=fort.15.properties
ELEVSTATIONS=ncv999_stations_20180907.txt
VELSTATIONS=$ELEVSTATIONS
METSTATIONS=$ELEVSTATIONS
NAFILE=nc_inundation_v9.99_rivers.13
NAPROPERTIES=${NAFILE}.properties
SWANTEMPLATE=fort.26.template
RIVERINIT=v6brivers.88
RIVERFLUX=v6brivers_fort.20_default
HINDCASTRIVERFLUX=v6brivers_fort.20_hc_default
PREPPEDARCHIVE=prepped_${GRIDNAME}_${INSTANCENAME}_${NCPU}.tar.gz
HINDCASTARCHIVE=prepped_${GRIDNAME}_hc_${INSTANCENAME}_${NCPU}.tar.gz

# Output files

# water surface elevation station output
FORT61="--fort61freq 300.0 --fort61netcdf"
# water current velocity station output
FORT62="--fort62freq 0"
# full domain water surface elevation output
FORT63="--fort63freq 3600.0 --fort63netcdf"
# full domain water current velocity output
FORT64="--fort64freq 3600.0 --fort64netcdf"
# met station output
FORT7172="--fort7172freq 300.0 --fort7172netcdf"
# full domain meteorological output
FORT7374="--fort7374freq 3600.0 --fort7374netcdf"
#SPARSE="--sparse-output"
SPARSE=""
NETCDF4="--netcdf4"
OUTPUTOPTIONS="${SPARSE} ${NETCDF4} ${FORT61} ${FORT62} ${FORT63} ${FORT64} ${FORT7172} ${FORT7374}"
# fulldomain or subdomain hotstart files
HOTSTARTCOMP=fulldomain
# binary or netcdf hotstart files
HOTSTARTFORMAT=netcdf
# "continuous" or "reset" for maxele.63 etc files
MINMAX=reset

# Notification

EMAILNOTIFY=yes # set to yes to have host platform email notifications
NOTIFY_SCRIPT=ncfs_cyclone_notify.sh
ACTIVATE_LIST=null
NEW_ADVISORY_LIST=null
POST_INIT_LIST=null
POST_LIST=null
JOB_FAILED_LIST=jason.g.fleming@gmail.com
NOTIFYUSER=jason.g.fleming@gmail.com
ASGSADMIN=jason.g.fleming@gmail.com

# Post processing and publication

INTENDEDAUDIENCE=general
INITPOST=null_init_post.sh
POSTPROCESS=cera_post.sh

TDS=(renci_tds)
TARGET=hatteras  # used in post processing to pick up HPC platform config
OPENDAPUSER=ncfs         # default value that works for RENCI opendap 
if [[ $OPENDAPHOST = "fortytwo.cct.lsu.edu" ]]; then
   OPENDAPUSER=jgflemin  # change this for other Operator running on queenbee
fi
# OPENDAPNOTIFY is used by opendap_post.sh and could be regrouped with the 
# other notification parameters above. 
OPENDAPNOTIFY="asgs.cera.lsu@gmail.com,jason.g.fleming@gmail.com,rick_luettich@unc.edu"

# Archiving

ARCHIVE=enstorm_pedir_removal.sh
ARCHIVEBASE=/projects/ncfs/data
ARCHIVEDIR=archive

# Forecast ensemble members

RMAX=default
PERCENT=default
ENSEMBLESIZE=6 # number of storms in the ensemble
case $si in
-1)
      # do nothing ... this is not a forecast
   ;;
3)
   ENSTORM=nhcConsensus
   ;;
0)
   ENSTORM=nhcConsensusWind10m
   ADCPREPWALLTIME="00:20:00"  # adcprep wall clock time, including partmesh
   FORECASTWALLTIME="00:20:00" # forecast wall clock time
   CONTROLTEMPLATE=nc_9.99wrivers.nowindreduction.fort.15.template
   CONTROLPROPERTIES=${CONTROLTEMPLATE}.properties
   TIMESTEPSIZE=300.0   # 5 minute time steps
   NCPU=15               # so total cpus match with other ensemble members
   NUMWRITERS=1          # multiple writer procs might collide
   WAVES=off             # deactivate wave forcing 
   # turn off water surface elevation station output
   FORT61="--fort61freq 0"
   # turn off water current velocity station output
   FORT62="--fort62freq 0"
   # turn off full domain water surface elevation output
   FORT63="--fort63freq 0"
   # turn off full domain water current velocity output
   FORT64="--fort64freq 0"
   # met station output
   FORT7172="--fort7172freq 300.0 --fort7172netcdf"
   # full domain meteorological output
   FORT7374="--fort7374freq 3600.0 --fort7374netcdf"
   #SPARSE="--sparse-output"
   SPARSE=""
   NETCDF4="--netcdf4"
   OUTPUTOPTIONS="${SPARSE} ${NETCDF4} ${FORT61} ${FORT62} ${FORT63} ${FORT64} ${FORT7172} ${FORT7374}"
   # prevent collisions in prepped archives
   PREPPEDARCHIVE=prepped_${GRIDNAME}_${INSTANCENAME}_${NCPU}.tar.gz
   POSTPROCESS=null_post.sh
   ;;
4)
   ENSTORM=veerRight50
   PERCENT=50
   ;;
1)
   ENSTORM=veerRight50Wind10m
   PERCENT=50
   #CONSTRAINT=hatteras
   PARTITION=ncfs
   ADCPREPWALLTIME="00:20:00"  # adcprep wall clock time, including partmesh
   FORECASTWALLTIME="00:20:00" # forecast wall clock time
   CONTROLTEMPLATE=nc_9.99wrivers.nowindreduction.fort.15.template
   CONTROLPROPERTIES=${CONTROLTEMPLATE}.properties
   TIMESTEPSIZE=300.0   # 5 minute time steps
   NCPU=15               # so total cpus match with other ensemble members
   NUMWRITERS=1          # multiple writer procs might collide
   WAVES=off             # deactivate wave forcing 
   # turn off water surface elevation station output
   FORT61="--fort61freq 0"
   # turn off water current velocity station output
   FORT62="--fort62freq 0"
   # turn off full domain water surface elevation output
   FORT63="--fort63freq 0"
   # turn off full domain water current velocity output
   FORT64="--fort64freq 0"
   # met station output
   FORT7172="--fort7172freq 300.0 --fort7172netcdf"
   # full domain meteorological output
   FORT7374="--fort7374freq 3600.0 --fort7374netcdf"
   #SPARSE="--sparse-output"
   SPARSE=""
   NETCDF4="--netcdf4"
   OUTPUTOPTIONS="${SPARSE} ${NETCDF4} ${FORT61} ${FORT62} ${FORT63} ${FORT64} ${FORT7172} ${FORT7374}"
   # prevent collisions in prepped archives
   PREPPEDARCHIVE=prepped_${GRIDNAME}_${INSTANCENAME}_${NCPU}.tar.gz
   POSTPROCESS=null_post.sh
   ;;
5)
   ENSTORM=veerRight100
   PERCENT=100
   ;;
2)
   ENSTORM=veeRight100Wind10m
   PERCENT=100
   ADCPREPWALLTIME="00:20:00"  # adcprep wall clock time, including partmesh
   FORECASTWALLTIME="00:20:00" # forecast wall clock time
   CONTROLTEMPLATE=nc_9.99wrivers.nowindreduction.fort.15.template
   CONTROLPROPERTIES=${CONTROLTEMPLATE}.properties
   TIMESTEPSIZE=300.0   # 5 minute time steps
   NCPU=15               # so total cpus match with other ensemble members
   NUMWRITERS=1          # multiple writer procs might collide
   WAVES=off             # deactivate wave forcing 
   # turn off water surface elevation station output
   FORT61="--fort61freq 0"
   # turn off water current velocity station output
   FORT62="--fort62freq 0"
   # turn off full domain water surface elevation output
   FORT63="--fort63freq 0"
   # turn off full domain water current velocity output
   FORT64="--fort64freq 0"
   # met station output
   FORT7172="--fort7172freq 300.0 --fort7172netcdf"
   # full domain meteorological output
   FORT7374="--fort7374freq 3600.0 --fort7374netcdf"
   #SPARSE="--sparse-output"
   SPARSE=""
   NETCDF4="--netcdf4"
   OUTPUTOPTIONS="${SPARSE} ${NETCDF4} ${FORT61} ${FORT62} ${FORT63} ${FORT64} ${FORT7172} ${FORT7374}"
   # prevent collisions in prepped archives
   PREPPEDARCHIVE=prepped_${GRIDNAME}_${INSTANCENAME}_${NCPU}.tar.gz
   POSTPROCESS=null_post.sh
   ;;
*)
   echo "CONFIGRATION ERROR: Unknown ensemble member number: '$si'."
   ;;
esac

