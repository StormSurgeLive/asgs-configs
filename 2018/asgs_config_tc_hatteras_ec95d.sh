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
# Copyright(C) 2006--2016 Jason Fleming
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
INSTANCENAME=michael_test      # name of this ASGS process (Change this for every new instance)
COLDSTARTDATE=2018090800  # (date to start cold start from )
HOTORCOLD=hotstart       # "hotstart" or "coldstart" 
LASTSUBDIR=null
HINDCASTLENGTH=30.0       # length of initial hindcast, from cold (days)  
REINITIALIZESWAN=no       # used to bounce the wave solution

# Source file paths

ADCIRCDIR=/home/bblanton/ADCIRC/v52release/work
SCRIPTDIR=/home/bblanton/GitHub/renci-unc/asgs       # ASGS scripts/executables  
INPUTDIR=${SCRIPTDIR}/input/meshes/ec95d   # dir containing grid and other input files 
OUTPUTDIR=${SCRIPTDIR}/output # dir containing post processing scripts
PERL5LIB=${SCRIPTDIR}/PERL    # dir with DateCale.pm perl module

# Physical forcing

BACKGROUNDMET=off     # [de]activate NAM download/forcing 
TIDEFAC=on            # [de]activate tide factor recalc 
TROPICALCYCLONE=on    # [de]activate tropical cyclone forcing (temp. broken)
WAVES=on              # [de]activate wave forcing 
VARFLUX=off           # [de]activate variable river flux forcing

# Computational Resources

TIMESTEPSIZE=30
SWANDT=1200
HINDCASTWALLTIME="06:00:00"   # river inital and tidal spinup time in machine
ADCPREPWALLTIME="00:05:00"
NOWCASTWALLTIME="01:00:00"  # must have leading zero, e.g., 05:00:00
FORECASTWALLTIME="02:00:00" # must have leading zero, e.g., 05:00:00
NCPU=64
NUMWRITERS=0
NCPUCAPACITY=704
CYCLETIMELIMIT="03:00:00"
QUEUENAME=batch
SERQUEUE=single
ACCOUNT=null
SCRATCHDIR=/scratch/bblanton/asgs/

# External data sources : Tropical cyclones

STORM=14  # storm number, e.g. 05=ernesto in 2006 
YEAR=2018 # year of the storm (useful for historical storms) 
TRIGGER=rssembedded    # either "ftp" or "rss"
RSSSITE=filesystem # www.nhc.noaa.gov 
FTPSITE=filesystem   # ftp.nhc.noaa.gov  # real anon ftp site for hindcast/forecast files
#FDIR=/atcf/afst     # forecast dir on nhc ftp site 
#HDIR=/atcf/btk      # hindcast dir on nhc ftp site 
FDIR=/scratch/bblanton/asgs-advisories
HDIR=/scratch/bblanton/asgs-advisories

# External data sources : Background Meteorology

FORECASTCYCLE="00,06,12,18" # (cycle of forecasts, needed)
BACKSITE=ftp.ncep.noaa.gov          # NAM forecast data from NCEP
BACKDIR=/pub/data/nccf/com/nam/prod # contains the nam.yyyymmdd files
FORECASTLENGTH=84                   # hours of NAM forecast to run (max 84)
PTFILE=ptFile_oneEighth.txt         # the lat/lons for the OWI background met
ALTNAMDIR="/scratch/bblanton"

# External data sources : River Flux

#RIVERSITE=ftp.nssl.noaa.gov
#RIVERDIR=/projects/ciflow/adcirc_info

RIVERSITE=data.disaster.renci.org
RIVERDIR=/opt/ldm/storage/SCOOP/RHLRv9-OKU
RIVERUSER=ldm
RIVERDATAPROTOCOL=scp

# Input files and templates

GRIDFILE=ec_95d.grd
GRIDNAME=ec_95d  
MESHPROPERTIES=${GRIDFILE}.properties
CONTROLTEMPLATE=ec_95_fort.15_template
CONTROLPROPERTIES=ec_95_fort.15.properties
ELEVSTATIONS=cera_stations.txt # change to station file only and have a variable here
VELSTATIONS=cera_stations.txt
METSTATIONS=cera_stations.txt # change to station file only and have a variable here
NAFILE=null  #  fort.13
NAPROPERTIES=${NAFILE}.properties
SWANTEMPLATE=fort.26.ec95.template   # no swan
RIVERINIT=null  # v6brivers.88 # no 
RIVERFLUX=null  # v6brivers_fort.20_default 
HINDCASTRIVERFLUX=null  # v6brivers_fort.20_hc_default
PREPPEDARCHIVE=prepped_${GRIDNAME}_${INSTANCENAME}_${NCPU}.tar.gz   # prep all_
HINDCASTARCHIVE=prepped_${GRIDNAME}_hc_${INSTANCENAME}_${NCPU}.tar.gz

# Output files

# water surface elevation station output
FORT61="--fort61freq 300.0 --fort61netcdf"
# water current velocity station output
FORT62="--fort62freq 300.0  --fort62netcdf"
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
OUTPUTOPTIONS="${SPARSE} ${FORT61} ${FORT62} ${FORT63} ${FORT64} ${FORT7172} ${FORT7374} ${NETCDF4}" 
# fulldomain or subdomain hotstart files
HOTSTARTCOMP=fulldomain
# binary or netcdf hotstart files
HOTSTARTFORMAT=binary
# "continuous" or "reset" for maxele.63 etc files
MINMAX=reset

# Notification

EMAILNOTIFY=yes # set to yes to have host platform email notifications
ems="bblanton@renci.org"
NOTIFY_SCRIPT=blanton_cyclone_notify.sh
ACTIVATE_LIST="$ems"
NEW_ADVISORY_LIST="$ems"
POST_INIT_LIST="$ems"
POST_LIST="$ems"
JOB_FAILED_LIST="$ems" 
NOTIFYUSER="$ems"
ASGSADMIN="$ems"

# RMQ Messaging

RMQMessaging_Script="${SCRIPTDIR}/asgs-msgr.py"
RMQMessaging_NcoHome="/home/bblanton/"
RMQMessaging_Python="/projects/storm_surge/anaconda/bin/python"
RMQMessaging_LocationName="RENCI"
RMQMessaging_ClusterName="Hatteras"

# Post processing and publication

INTENDEDAUDIENCE=hatteras_msg_test # meta data audience
INITPOST=null_init_post.sh
POSTPROCESS=blanton_rmq_test_post_hatteras.sh
POSTPROCESS2=null_post.sh

TDS=(renci_tds)
TARGET=hatteras              # used in post processing to pick up HPC platform config
OPENDAPUSER=bblanton         # default value that works for RENCI opendap 
# OPENDAPNOTIFY is used by opendap_post.sh and could be regrouped with the 
# other notification parameters above. 
OPENDAPNOTIFY="bblanton@renci.org"

# Archiving

ARCHIVE=null_archive.sh # if null no data gets save
ARCHIVEBASE=/scratch/bblanton/asgs/
ARCHIVEDIR=archive

# Forecast ensemble members

RMAX=default
PERCENT=default
ENSEMBLESIZE=1 # number of storms in the ensemble
case $si in
-1)
      # do nothing ... this is not a forecast
   ;;
0)
   ENSTORM=nhcForecast
   ;;
1)
   ENSTORM=veerLeft10
   PERCENT=-10
   ;;
2)
   ENSTORM=veerRight10
   PERCENT=10
   ;;
3)
   ENSTORM=veerLeft20
   PERCENT=-20
   ;;
4)
   ENSTORM=veerRight20
   PERCENT=20
   ;;
5)
   ENSTORM=veerLeft30
   PERCENT=-30
   ;;
6)
   ENSTORM=veerRight30
   PERCENT=30
   ;;
7)
   ENSTORM=veerLeft40
   PERCENT=-40
   ;;
8)
   ENSTORM=veerRight40
   PERCENT=40
   ;;
9)
   ENSTORM=veerLeft50
   PERCENT=-50
   ;;
10)
   ENSTORM=veerRight50
   PERCENT=50
   ;;
11)
   ENSTORM=veerLeft60
   PERCENT=-60
   ;;
12)
   ENSTORM=veerRight60
   PERCENT=60
   ;;
13)
   ENSTORM=veerLeft70
   PERCENT=-70
   ;;
14)
   ENSTORM=veerRight70
   PERCENT=70
   ;;
15)
   ENSTORM=veerLeft80
   PERCENT=-80
   ;;
16)
   ENSTORM=veerRight80
   PERCENT=80
   ;;
17)
   ENSTORM=veerLeft90
   PERCENT=-90
   ;;
18)
   ENSTORM=veerRight90
   PERCENT=90
   ;;
19)
   ENSTORM=veerLeft100
   PERCENT=-100
   ;;
20)
   ENSTORM=veerRight100
   PERCENT=100
   ;;
*)
   echo "CONFIGRATION ERROR: Unknown ensemble member number: '$si'."
   ;;
esac
