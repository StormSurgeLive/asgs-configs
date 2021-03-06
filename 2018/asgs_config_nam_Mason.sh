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
INSTANCENAME=daily_nam_Jason      # name of this ASGS process (Change this for every new instance)
#COLDSTARTDATE=2016090400
#COLDSTARTDATE=2017010100
#COLDSTARTDATE=2017012400
#COLDSTARTDATE=2017070900
#COLDSTARTDATE=2017121500
COLDSTARTDATE=2018040900              # (date to start cold start from )
HOTORCOLD=coldstart        # "hotstart" or "coldstart" 
LASTSUBDIR=null
HINDCASTLENGTH=0.5        # length of initial hindcast, from cold (days)  
REINITIALIZESWAN=no       # used to bounce the wave solution

# Source file paths

ADCIRCDIR=/home/fhrl/Documents/Surge/adcirc # ADCIRC executables 
SCRIPTDIR=/home/fhrl/asgs        # ASGS scripts/executables  
INPUTDIR=${SCRIPTDIR}/input/meshes/Mason_iflood_mesh   # dir containing grid and other input files 
OUTPUTDIR=${SCRIPTDIR}/output # dir containing post processing scripts
PERL5LIB=${SCRIPTDIR}/PERL    # dir with DateCale.pm perl module

# Physical forcing

BACKGROUNDMET=on     # [de]activate NAM download/forcing 
TIDEFAC=on           # [de]activate tide factor recalc 
TROPICALCYCLONE=off  # [de]activate tropical cyclone forcing (temp. broken)
WAVES=off            # [de]activate wave forcing 
VARFLUX=off           # [de]activate variable river flux forcing

# Computational Resources

TIMESTEPSIZE=1
SWANDT=1200
HINDCASTWALLTIME="24:00:00"   # river inital and tidal spinup time in machine
ADCPREPWALLTIME="00:15:00"
NOWCASTWALLTIME="05:00:00"  # must have leading zero, e.g., 05:00:00
FORECASTWALLTIME="05:00:00" # must have leading zero, e.g., 05:00:00
NCPU=31
NUMWRITERS=1
NCPUCAPACITY=32
CYCLETIMELIMIT="05:00:00"
QUEUENAME=workq
SERQUEUE=single
ACCOUNT=loni_cera_2018
#SCRATCHDIR=/work/$USER    # vs default /work/cera

# External data sources : Tropical cyclones

STORM=12  # storm number, e.g. 05=ernesto in 2006 
YEAR=2013 # year of the storm (useful for historical storms) 
TRIGGER=rssembedded    # either "ftp" or "rss"
RSSSITE=www.nhc.noaa.gov 
FTPSITE=ftp.nhc.noaa.gov  # real anon ftp site for hindcast/forecast files
FDIR=/atcf/afst     # forecast dir on nhc ftp site 
HDIR=/atcf/btk      # hindcast dir on nhc ftp site 

# External data sources : Background Meteorology

FORECASTCYCLE="00,06,12,18" # (cycle of forecasts, needed)
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

GRIDFILE=fort.14
GRIDNAME=iflood  # @jasonfleming 20170814: should be nc6d
MESHPROPERTIES=${GRIDFILE}.properties
CONTROLTEMPLATE=hs_fort.15_template
CONTROLPROPERTIES=ifort_fort.15.properties
ELEVSTATIONS=null # change to station file only and have a variable here
VELSTATIONS=null
METSTATIONS=null # change to station file only and have a variable here
NAFILE=fort.13
NAPROPERTIES=${NAFILE}.properties
SWANTEMPLATE=fort.26.v6b.template   # no swan
RIVERINIT=v6brivers.88 # no 
RIVERFLUX=v6brivers_fort.20_default 
HINDCASTRIVERFLUX=v6brivers_fort.20_hc_default
PREPPEDARCHIVE=prepped_${GRIDNAME}_${INSTANCENAME}_${NCPU}.tar.gz   # prep all_
HINDCASTARCHIVE=prepped_${GRIDNAME}_hc_${INSTANCENAME}_${NCPU}.tar.gz

# Output files

# water surface elevation station output
FORT61="--fort61freq 300.0"
# water current velocity station output
FORT62="--fort62freq 0"
# full domain water surface elevation output
FORT63="--fort63freq 3600.0"   #--fort63netcdf for netcdf outputs for figgen
# full domain water current velocity output
FORT64="--fort64freq 3600.0"
# met station output
FORT7172="--fort7172freq 300.0"
# full domain meteorological output
FORT7374="--fort7374freq 3600.0"
#SPARSE="--sparse-output"
SPARSE=""
NETCDF4="--netcdf4"
OUTPUTOPTIONS="${SPARSE} ${FORT61} ${FORT62} ${FORT63} ${FORT64} ${FORT7172} ${FORT7374}"  #${NETCDF4} if netcdf needed
# fulldomain or subdomain hotstart files
HOTSTARTCOMP=fulldomain
# binary or netcdf hotstart files
HOTSTARTFORMAT=binary
# "continuous" or "reset" for maxele.63 etc files
MINMAX=reset

# Notification

EMAILNOTIFY=yes # set to yes to have host platform email notifications
NOTIFY_SCRIPT=ncfs_nam_notify.sh
ACTIVATE_LIST=""
NEW_ADVISORY_LIST=""
POST_INIT_LIST=""
POST_LIST=""
JOB_FAILED_LIST="akhalid6@gmu.edu"
NOTIFYUSER=akhalid6@gmu.edu
ASGSADMIN=akhalid6@gmu.edu

# Post processing and publication

INTENDEDAUDIENCE=general # meta data audience
INITPOST=null_init_post.sh
POSTPROCESS=null_post.sh
POSTPROCESS2=null_post.sh

TDS=(renci_tds)
TARGET=queenbee  # used in post processing to pick up HPC platform config
OPENDAPUSER=ncfs         # default value that works for RENCI opendap 
if [[ $OPENDAPHOST = "fortytwo.cct.lsu.edu" ]]; then
   OPENDAPUSER=jgflemin  # change this for other Operator running on queenbee
fi
# OPENDAPNOTIFY is used by opendap_post.sh and could be regrouped with the 
# other notification parameters above. 
OPENDAPNOTIFY="asgs.cera.lsu@gmail.com,jason.g.fleming@gmail.com"

# Archiving

ARCHIVE=null_archive.sh # if null no data gets save
ARCHIVEBASE=/work/jgflemin
ARCHIVEDIR=${ARCHIVEBASE}/asgs_archive

# Forecast ensemble members

RMAX=default
PERCENT=default
ENSEMBLESIZE=1 # number of storms in the ensemble
case $si in
-1)
      # do nothing ... this is not a forecast
   ;;
0)
   ENSTORM=namforecast
   ;;
1)
   ENSTORM=namforecastWind10m
   ADCPREPWALLTIME="00:20:00"  # adcprep wall clock time, including partmesh
   FORECASTWALLTIME="00:20:00" # forecast wall clock time
   CONTROLTEMPLATE=nv6brivers_explicit_rlevel51.nowindreduction.fort.15_template
   CONTROLPROPERTIES=${CONTROLTEMPLATE}.properties
   TIMESTEPSIZE=300.0    # 5 minute time steps
   #NCPU=31               # so total cpus match with other ensemble members
   #NUMWRITERS=1          # multiple writer procs might collide
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
