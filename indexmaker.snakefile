configfile:"config.yaml"
GENOME=config["GENOME"]
READLENGTHS=config["READLENGTHS"]
REFFA=config["REFFA"]
GTFFILE=config["GTFFILE"]
OUTDIR=config["OUTDIR"]
SCRIPTSDIR=config["SCRIPTSDIR"]
workdir:OUTDIR

rule all:
	input:
		expand("rsemref/{genome}.transcripts.ump",genome=GENOME),
		"annotate.isoforms.txt",
		"annotate.genes.txt",
		"refFlat.txt",
		"geneinfo.bed",
		expand("STAR/2.5.2b/genes-{readlength}/SA",readlength=READLENGTHS),
		expand("{genome}.rRNA_interval_list",genome=GENOME),
		"karyoplot_gene_coordinates.txt",
		"qualimap_info.txt",
		"karyobeds/karyobed.bed"
	

rule init:
	input:
		fa=REFFA,
		gtf=GTFFILE
	output:
		"ref.fa",
		"genes.gtf"
	params:
		outdir=OUTDIR
	shell:'''
mkdir -p {params.outdir}
cd {params.outdir}
ln -s {input.fa} ref.fa
ln -s {input.gtf} genes.gtf 
'''

rule rsem:
	input:
		fa="ref.fa",
		gtf="genes.gtf"
	params:
		genome=GENOME
	output:
		"rsemref/{sample}.transcripts.ump"
	shell:'''
if [ ! -d rsemref ]; then
mkdir rsemref
fi
cd rsemref
pwd
ln -s ../genes.gtf .
ln -s ../ref.fa .
module load rsem/1.3.0
rsem-prepare-reference -p {threads} --gtf {input.gtf} {input.fa} {params.genome}
rsem-generate-ngvector {params.genome}.transcripts.fa {params.genome}.transcripts
'''

rule annotate:
	input:
		gtf="genes.gtf"
	output:
		"annotate.isoforms.txt",
		"annotate.genes.txt",
		"refFlat.txt",
		"geneinfo.bed"
	params:
		sdir=SCRIPTSDIR
	shell:'''
module load python/3.6
python {params.sdir}/get_gene_annotate.py genes.gtf > annotate.genes.txt
python {params.sdir}/get_isoform_annotate.py genes.gtf > annotate.isoforms.txt
module load ucsc/384
gtfToGenePred -ignoreGroupsWithoutExons genes.gtf genes.genepred
genePredToBed genes.genepred genes.bed12
sort -k1,1 -k2,2n genes.bed12 > genes.ref.bed
python {params.sdir}/make_refFlat.py > refFlat.txt
python {params.sdir}/make_geneinfo.py > geneinfo.bed
'''

rule star_init:
	input:
		fa="ref.fa",
		gtf="genes.gtf"
	output:
		"STAR/2.5.2b/ref.fa",
		"STAR/2.5.2b/genes.gtf"
	shell:'''
mkdir -p STAR/2.5.2b
cd STAR/2.5.2b
ln -s ../../ref.fa .
ln -s ../../genes.gtf .
'''

rule star:
	input:
		fa="STAR/2.5.2b/ref.fa",
		gtf="STAR/2.5.2b/genes.gtf"
	output:
		SA="STAR/2.5.2b/genes-{readlength}/SA"
	shell:'''
rl={wildcards.readlength}
rl=$((rl-1))
#rl=$(python subtractone.py {wildcards.readlength})
cd STAR/2.5.2b
module load STAR/2.5.2b
STAR \
--runThreadN {threads} \
--runMode genomeGenerate \
--genomeDir ./genes-{wildcards.readlength} \
--genomeFastaFiles ./ref.fa \
--sjdbGTFfile ./genes.gtf \
--sjdbOverhang $rl \
--outTmpDir tmp_{wildcards.readlength} 
'''
		
rule rRNA_list:
	input:
		fa="ref.fa",
		gtf="genes.gtf",
	output:
		expand("{genome}.rRNA_interval_list",genome=GENOME)
	params:
		genome=GENOME,
		sdir=SCRIPTSDIR
	shell:'''
module load samtools/1.9
module load python/3.6
python {params.sdir}/create_rRNA_intervals.py {input.fa} {input.gtf} {params.genome} > {params.genome}.rRNA_interval_list
'''

rule karyo_coord:
	input:
		gtf="genes.gtf"
	output:
		"karyoplot_gene_coordinates.txt"
	params:
		sdir=SCRIPTSDIR
	shell:'''
module load python/3.6
python {params.sdir}/get_karyoplot_gene_coordinates.py genes.gtf > karyoplot_gene_coordinates.txt
'''

rule qualimapinfo:
	input:
		fa="ref.fa",
		gtf="genes.gtf"
	output:
		"qualimap_info.txt"
	params:
		sdir=SCRIPTSDIR
	shell:'''
module load python/2.7
python {params.sdir}/generate_qualimap_ref.py -g {input.gtf} -f {input.fa} -o {output} --ignore-strange-chrom 2> qualimap_error.log
'''

rule karyo_beds:
	input:
		gtf=GTFFILE
	output:
		"karyobeds/karyobed.bed"
	params:
		sdir=SCRIPTSDIR
	shell:'''
module load python/3.6
mkdir -p karyobeds
cd karyobeds
python {params.sdir}/get_karyoplot_beds.py {input.gtf}
'''

