#!/bin/bash

set -euo pipefail

if [[ $# -eq 0 ]] ; then
        # Checking if PIM's directory is given
        echo -e "USAGE: Failed to provide '$1', which is the path the PIM directory"
	exit 0
fi


# Get PIM repository PATH
PIM_HOME="$1"

snakemake -s ${PIM_HOME}/src/Snakefiles/indexmaker.snakefile --printshellcmds --cluster-config ${PIM_HOME}/cluster.json --cluster "sbatch --cpus-per-task {cluster.threads} -p {cluster.partition} -t {cluster.time} --mem {cluster.mem}" -j 500 --rerun-incomplete --keep-going --restart-times 1 --stats ${PIM_HOME}/stats.txt | tee -a ${PIM_HOME}/snakemake.log
