#!/usr/bin/env python

from __future__ import print_function
import argparse, sys, os, subprocess

def _run(cmd, args=''):
	subprocess.check_call(cmd + args, shell=True)

def configure(filename, options):
	with open(filename, 'w') as fh:
		fh.write('GENOME: "{}"\n'.format(options.reference_genome))
		fh.write('REFFA: "{}"\n'.format(options.reference_fa))
		fh.write('GTFFILE: "{}"\n'.format(options.reference_gtf))
		fh.write('OUTDIR: "{}"\n'.format(options.working_directory))
		fh.write('SCRIPTSDIR: "{}/src/Scripts"\n'.format(options.pim_home))
		fh.write('PIM_HOME: "{}"\n'.format(options.pim_home))
		fh.write('GENOME: "{}"\n'.format(options.reference_genome))
		fh.write('READLENGTHS:\n')
		if not options.read_length:
			options.read_length = ['50', '75', '100', '125', '150']
		for readlen in options.read_length:
			fh.write('  - {}\n'.format(readlen))


def parse_args():
	'''Parse command-line arguments and check for correct usage'''

	parser = argparse.ArgumentParser(description='Main Entry Point of Pipeliner Index Maker (PIM): Checks usage, parses command-line arguments, edits config.yaml, and run snakemake.')
	parser.add_argument('-n','--dry-run', required=False, action='store_true', dest='dryrun', help='<optional> Flag: Dry-run the pipeline using snakemake')
	parser.add_argument('-i','--reference-genome', type=str, required=True, help='<required> Reference genome name: i.e. mm10 or hg19 or hg38')
	parser.add_argument('-f','--reference-fa', type=str, required=True, help='<required> Genomic FASTA file of reference genome')
	parser.add_argument('-g','--reference-gtf', type=str, required=True, help='<required> GTF file for reference genome')
	parser.add_argument('-o','--working-directory', type=str, required=True, help='<required> Working Directory: Location of output directory')
	parser.add_argument('-p','--pim-home', type=str, required=True, help='<required> Location of PIM repository, IndexMaker defaults to location of {}'.format(__file__))
	parser.add_argument('-rl','--read-length', action='append', help='<optional> Read Lengths of STAR Indices: i.e. 50, 75, 100, 125, 150', default=[], required=False)
	arguments = parser.parse_args()

	return arguments

def main():
	'''Check command-line usage and parse arguments
	USAGE: /path/to/PIM/IndexMaker.py --reference-genome=mm10 --reference-fa=/path/to/genome/ref.fa --reference-gtf=/path/to/reference/genes.gtf --working-directory=/path/to/output/everything/ --pim-home=/path/to/repo/PIM/
	'''

	args = parse_args()
	configure('config.yaml', args)

	if args.dryrun:
		dryrun = '-n'
	else:
		dryrun = ''

	cmd = 'module load snakemake/5.1.3; snakemake {0} -s {1}/src/Snakefiles/indexmaker.snakefile --printshellcmds --cluster-config {1}/cluster.json --cluster "sbatch --cpus-per-task {{cluster.threads}} -p {{cluster.partition}} -t {{cluster.time}} --mem {{cluster.mem}}" -j 500 --rerun-incomplete --keep-going --restart-times 1 --stats {1}/stats.txt --stats {1}/initialqc.stats -T 2>&1 | tee -a {1}/snakemake.log'.format(dryrun, args.pim_home)

	_run(cmd)

if __name__ == '__main__':

	main()

