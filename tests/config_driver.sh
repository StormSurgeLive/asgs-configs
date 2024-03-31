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
# set which ASGS config file template is to be used
configTemplate=~/Campaigns/Development/asgs-configs/tests/asgs_config_Shinnecock_template.sh
instanceBase="asgs_config_shinnecock_test"
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
nodalAttributesActiveLists=( "null" "sea_surface_height_above_geoid" "sea_surface_height_above_geoid;surface_directional_effective_roughness_length;surface_canopy_coefficient" )
NAFILEs=( "null" "shinnecock_nodal_attributes.template" )
COLDSTARTDATEs=( "2024032400" )
BACKGROUNDMETs=( "GFS" )
WAVESs=( "on" )
addWind10mScenario=( "no" "yes" )
createWind10mLayer=( "yes" "no" )
#
# Set derived parameters whose values are based on combination of
# parameters above
INSTANCENAME=""
SCENARIOPACKAGESIZE=""
declare -a scenarioNames
declare -a scenarioSettings=""
#
# Calculate the number of config files to be generated
numFiles=$(expr ${#GRIDNAMEs[@]} \* ${#nodalAttributesActiveLists[@]} \* ${#NAFILEs[@]} \* ${#COLDSTARTDATEs[@]} \* ${#BACKGROUNDMETs[@]} \* ${#WAVESs[@]} \* ${#addWind10mScenario[@]} \* ${#createWind10mLayer[@]} )
echo "numFiles is $numFiles"
configFile=0
for mesh in ${GRIDNAMEs[@]}; do
    for naList in ${nodalAttributesActiveLists[@]}; do
        for naFile in ${NAFILEs[@]}; do
            for csDate in ${COLDSTARTDATEs[@]}; do
                for met in ${BACKGROUNDMETs[@]}; do
                    for waves in ${WAVESs[@]}; do
                        for wind10mScenario in ${addWind10mScenario[@]}; do
                            for wind10mLayer in ${createWind10mLayer[@]}; do
                                INSTANCENAME=${instanceBase}_$(printf %03d $configFile)
                                SCENARIOPACKAGESIZE=1
                                scenarioNames=( gfsforecast )
                                scenarioSettings=( null )
                                configFileName=${configTemplate//template/$(printf %03d $configFile)}
                                #echo $configFileName
                                if [[ $wind10mScenario == "yes" ]]; then
                                    SCENARIOPACKAGESIZE=2
                                    scenarioNames+=( ${scenarioNames[0]}Wind10m )
                                    scenarioSettings+=( "source $SCRIPTDIR/config/io_defaults.sh" )
                                fi
                                #echo "${mesh}_${naList}_${naFile}_${csDate}_${met}_${waves}_${wind10mScenario}_${wind10mLayer}"
                                echo $INSTANCENAME $SCENARIOPACKAGESIZE ${scenarioNames[@]} ${scenarioSettings[@]}
                                # nodal attributes
                                configFile=$(expr $configFile + 1)
                            done
                        done
                    done
                done
            done
        done
    done
done

#sed \
#    -e "s/%NULLGETGFSTEMPLATEFILE%/$gfsTemplateName/" \
#    -e "s/%NULLGETGFSTEMPLATEFILLEDFILE%/$filledGfsTemplateName/" \
#    -e "s/%NULLLASTUPDATETIME%/$DATETIME/" \
#     < $SCRIPTDIR/$gfsTemplateName \
#     > "part_$filledGfsTemplateName"
#if [[ $? != 0 ]]; then
#    echo "$THIS: Failed to fill in GFS data request template with sed."
#fi