#!/bin/bash

AMXSC="/home/cstrike/csdm/cstrike/addons/amxmodx/scripting/"
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${AMXSC}

for PLUGIN in *.sma; do
	${AMXSC}/amxxpc ${PLUGIN}
done
