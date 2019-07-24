module load snakemake
#snakemake -s indexmaker.snakefile -pr
snakemake $1 -s indexmaker.snakefile --printshellcmds --cluster-config cluster.json --cluster "sbatch --cpus-per-task {cluster.threads} -p {cluster.partition} -t {cluster.time} --mem {cluster.mem}" -j 500 --rerun-incomplete --keep-going --restart-times 1 --stats stats.txt |tee -a snakemake.log
