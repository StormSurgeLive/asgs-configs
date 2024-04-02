#!/bin/bash
#-------------------------------------------------------------------
# config_driver.sh: Fills in ASGS config file templates for use
# in smoke testing ASGS.
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
#
# sample script:
# for num in $(seq 0 31); do save profile shinnecock_test_$(printf %03d $num) ; define config ~/Campaigns/Development/2024/test-issue-1251/asgs_config_Shinnecock_$(printf %03d $num).sh ; rl ; run ; done
#
# set which ASGS config file template is to be used
configTemplate=~/Campaigns/Development/asgs-configs/tests/asgs_config_Shinnecock_template.sh
instanceBase="shinnecock_test"
#
# Declare arrays of parameters to be used in the ASGS config file template.
declare -a GRIDNAMEs             # Shinnecock|Shinnecock-parameters
declare -a NAFILEs               # nodal attributes files, incl. null to mean "no nodal attributes file"
declare -a COLDSTARTDATEs        # reasonable value based on met forcing
declare -a BACKGROUNDMETs        # GFS
declare -a WAVESs                # off
declare -a addWind10mScenario    # yes|no
declare -a createWind10mLayers   # yes|no
declare -a nodalAttributesActiveLists # empty list, list not including canopy/roughness, list incl. canopy/roughness
#
# Specify parameter values
GRIDNAMEs=( "Shinnecock" "Shinnecock-parameters" )
nodalAttributesActiveLists=( "null" "sea_surface_height_above_geoid" "sea_surface_height_above_geoid,surface_directional_effective_roughness_length,surface_canopy_coefficient" )
NAFILEs=( "null" "shinnecock_nodal_attributes.template" )
COLDSTARTDATEs=( "2024033000" )
TRIGGER="auto"
BACKGROUNDMETs=( "GFS" )
WAVESs=( "off" )
addWind10mScenario=( "no" "yes" )
addWind10mLayer=( "yes" "no" )
#
# Set derived parameters whose values are based on combination of
# parameters above
INSTANCENAME=""
SCENARIOPACKAGESIZE=""
declare -a scenarioNames
declare -a scenarioSettings
declare -a POSTPROCESS
#
configFileNum=0
for GRIDNAME in ${GRIDNAMEs[@]}; do
    for naList in ${nodalAttributesActiveLists[@]}; do
        for NAFILE in ${NAFILEs[@]}; do
            for COLDSTARTDATE in ${COLDSTARTDATEs[@]}; do
                for BACKGROUNDMET in ${BACKGROUNDMETs[@]}; do
                    for WAVES in ${WAVESs[@]}; do
                        for wind10mScenario in ${addWind10mScenario[@]}; do
                            for createWind10mLayer in ${addWind10mLayer[@]}; do
                                configFileName=$(basename ${configTemplate//template/$(printf %03d $configFileNum)})
                                INSTANCENAME=${instanceBase}_$(printf %03d $configFileNum)
                                SCENARIOPACKAGESIZE=1
                                scenarioNames=( gfsforecast unreachableScenario )
                                scenarioSettings=( '# no scenario settings' '# unreachable settings' )
                                POSTPROCESS=( )
                                if [[ $wind10mScenario == "yes" ]]; then
                                    SCENARIOPACKAGESIZE=2
                                    scenarioNames=( gfsforecastWind10m gfsforecast )
                                    scenarioSettings=( 'source $SCRIPTDIR/config/io_defaults.sh' '# no scenario settings' )
                                    POSTPROCESS=( includeWind10m.sh )
                                fi
                                # nodal attributes
                                nodal_attribute_activate=( ${naList//,/ } )
                                if [[ $naList == "null" ]]; then
                                    nodal_attribute_activate=( )
                                else
                                    # if a nonzero list of nodal attributes was specified to be activated
                                    # in the fort.15 there must be a nodal attributes file to supply them
                                    if [[ $NAFILE == "null" ]]; then
                                        continue
                                    fi
                                fi
                                configFileNum=$(expr $configFileNum + 1)
                                echo $configFileName
                                sed \
                                    -e "s/%INSTANCENAME%/$INSTANCENAME/" \
                                    -e "s/%GRIDNAME%/$GRIDNAME/" \
                                    -e "s/%nodalAttributeActivateList%/${nodal_attribute_activate[*]}/" \
                                    -e "s/%NAFILE%/$NAFILE/" \
                                    -e "s/%COLDSTARTDATE%/$COLDSTARTDATE/" \
                                    -e "s/%TRIGGER%/$TRIGGER/" \
                                    -e "s/%BACKGROUNDMET%/$BACKGROUNDMET/" \
                                    -e "s/%WAVES%/$WAVES/" \
                                    -e "s/%createWind10mLayer%/$createWind10mLayer/" \
                                    -e "s/%POSTPROCESS%/${POSTPROCESS[*]}/" \
                                    -e "s/%SCENARIOPACKAGESIZE%/$SCENARIOPACKAGESIZE/" \
                                    -e "s/%SCENARIO000%/${scenarioNames[0]}/" \
                                    -e "s?%SCENARIO000_settings%?${scenarioSettings[0]}?" \
                                    -e "s/%SCENARIO001%/${scenarioNames[1]}/" \
                                    -e "s?%SCENARIO001_settings%?${scenarioSettings[1]}?" \
                                     < $configTemplate \
                                     > $configFileName
                                if [[ $? != 0 ]]; then
                                    echo "config_driver: Failed to fill in ASGS configuration file template  with sed."
                                fi
                            done
                        done
                    done
                done
            done
        done
    done
done

