# PIM
Pipeliner Index Maker


Given 
 * a reference fasta file (ref.fa) and 
 * a GTF style annotation file (genes.gtf), 
 
 
 these set of scripts orchestrate the creation of required files to run RNASeq pipeline on Biowulf.
 
 Once you have a fasta and a GTF file, here are the steps to create an index folder:
 
 1. check out PIM 
 
 ```
 git clone https://github.com/CCBR/PIM.git
 ```
 
 These files are already checked out at `/data/CCBR_Pipeliner/db/PipeDB/PIM` on Biowulf
 
 2. appropriately edit the `config.yaml`. See details of YAML file below.
 
 3. submit jobs to slurm using `runit.sh`. See details of `runit.sh` below.
 
 4. create a new genome specific JSON file to be added to the CCBR Pipliner
 
 ## YAML file
 
 This file has all the required inputs to run the PIM
 
| Variable | Comment |
|----------|:-------------:|
| GENOME | Name of the genome, eg. "mm10" |
| REFFA | Absolute path to reference fasta file |
| GTFFILE | Absolute path to annotation GTF file |
| OUTDIR | Absoulte path to where the results (indices) will be saved |
| SCRIPTSDIR | Absolute path to where the scripts in this repo have been checked out |
| READLENGTHS | List of STAR readlengths to generate indices for |

Here is an example config.yaml file:

```
GENOME: "mm10"
REFFA: "/data/CCBR_Pipeliner/db/PipeDB/Indices/mm10_basic/indexes/mm10.fa"
GTFFILE: "/data/CCBR_Pipeliner/db/PipeDB/Indices/mm10_basic/genes.gtf"
OUTDIR: "/scratch/indexmaker/test"
SCRIPTSDIR: "/scratch/indexmaker"
READLENGTHS:
  - 50
  - 100
```

## runit.sh

After editing YAML file, you can dryrun using 

```
sh runit.sh "-n"
```

If everything checks out then run

```
sh runit.sh ""
```

This will submit jobs to slurm job scheduler and create the files needed. To view cluster resources requested, please read `cluster.json`
