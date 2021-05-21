# PIM
Pipeliner Index Maker


Given
 * a reference fasta file (ref.fa) and
 * a GTF style annotation file (genes.gtf),


 these set of scripts orchestrate the creation of required files to run [RNASeq CCBR pipeliner](https://github.com/CCBR/Pipeliner) on [Biowulf](https://hpc.nih.gov/).

 **Disclaimer**

 If you have 2 GTFs, eg. viral + host hybrid genomes, then you need to create one FASTA and one GTF file for the hybrid genome prior to running PIM.

**Creating Hyrbid Fasta File**

Once you have two fasta files (eg. viral fasta and host fasta), then we can use [`fasta_formatter `](https://hpc.nih.gov/apps/fastxtoolkit.html) like this on biowulf:

```bash
% cat host.fa virus.fa | fasta_formatter -w80 -o host_virus.fa
```

**Creating GTF File**

Most times you do have a well-formated GTF file for the host from Ensembl or Gencode, but that is not the case for the virus. The thing to ensure is that your GTF (even if it is hand curated) includes:

*  a `gene` feature
* each `gene` feature has atleast one `transcript` feature
* and each `transcript` feature has atleast one `exon` feature. If not then the GTF file needs to be manipulated until these conditions are satisfied.

Here is an example feature from a hand-curated Biotyn_probe GTF file:

```bash
Biot1	BiotynProbe	gene	1	21	0.000000	+	.	gene_id "Biot1"; gene_name "Biot1"; gene_biotype "biotynlated_probe_control";
Biot1	BiotynProbe	transcript	1	21	0.000000	+	.	gene_id "Biot1"; gene_name "Biot1"; gene_biotype "biotynlated_probe_control"; transcript_id "Biot1"; transcript_name "Biot1"; transcript_type "biotynlated_probe_control";
Biot1	BiotynProbe	exon	1	21	0.000000	+	.	gene_id "Biot1"; transcript_id "Biot1"; transcript_type "biotynlated_probe_control";
```

In this tab-delimited example, 

* first line: `gene` feature with 2 required attributes in column9, namely, `gene_id`, `gene_name` and an optional attribute `gene_biotype` 
* second line: `transcript` for the above `gene` repeating the attributes with few more attributes, namely, `transcript_id `(required), `transcript_name` (required) and `transcript_type` (optional)
* third line: `exon` for the above transcript with `gene_id` and `transcript_id` attributes required.

Once you have the host and virus GTFs in acceptable formats, you can simply concatenate them to use as input for PIM, like so:

```bash
% cat host.gtf virus.gtf > host_virus.gtf
```

> **NOTE**
>
> It is important to ensure that the sequence ids in the *fasta* match with the sequence ids in the *gtf*, else PIM will produce unexpected results.
>
> ```bash
> % grep "^>" host_virus.fa | awk '{print $1}' | sed "s/>//g" | sort > fasta_sequence_ids.txt
> % cut -f1 host_virus.gtf | sort | uniq > gtf_sequence_ids.txt
> % diff fasta_sequence_ids.txt gtf_sequence_ids.txt
> ```
>
> Ideally, the above `diff` command should produce no result, indicating that the sequence_ids are identical.

Once you have a fasta and a GTF file, here are the steps to create an index folder:

 1. check out PIM

 ```bash
% git clone https://github.com/CCBR/PIM.git
 ```

 These files are already checked out at `/data/CCBR_Pipeliner/db/PipeDB/PIM` on Biowulf

 2. appropriately edit the `config.yaml`. See details of YAML file below.

 3. submit jobs to slurm using `IndexMaker`. See details of `IndexMaker` below.

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
SCRIPTSDIR: "/scratch/indexmaker/Scripts"
READLENGTHS:
  - 50
  - 100
```

- Please also see an example configuration file in 'examples/' directory.


## IndexMaker

After editing YAML file, you can dryrun using

```bash
% bash IndexMaker --use-config -n
```
- **Note**: This assumes you have a `config.yaml` file in the root of PIM's directory: `/path/to/repo/of/PIM/config.yaml`.

If everything checks out then run:

```bash
% bash IndexMaker --use-config
```

This will submit jobs to SLURM job scheduler to create the reference files. To view cluster resources requested, please read `cluster.json`.
