#!/bin/bash

AMXSC="/home/cstrike/csdm/cstrike/addons/amxmodx/scripting/"
PLUGIN="mapstat.sma"
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${AMXSC}

${AMXSC}/amxxpc ${PLUGIN}
