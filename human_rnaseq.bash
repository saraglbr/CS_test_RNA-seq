#!/bin/bash

#CALLING THE VARIABLES"
echo $1 # Read project folder
echo $2 # name of the samples
echo $3 # final name of sample

#load modules
. /etc/profile.d/modules.sh
module load java/jdk-22.0.1
module load igmm/apps/TrimGalore/0.6.6
module load igmm/apps/cutadapt/4.6
module load igmm/apps/STAR/2.7.11b 
module load igmm/apps/samtools/1.6 
module load R
module load igmm/apps/subread/2.1.0
module load anaconda

conda activate subread_env  

#creates folders
cd /exports/eddie/scratch/s1659595/$1/
mkdir trimmed_fastq
mkdir aln
mkdir samtools 
mkdir feature_count/

#enter into the fastq folder
cd /exports/eddie/scratch/s1659595/$1/fastq


#TRIMMING ADAPTERS from reads
trim_galore --path_to_cutadapt cutadapt --paired -stringency 5 -length 27 -o /exports/eddie/scratch/s1659595/$1/trimmed_fastq/ -q 20 $2_1.fastq $2_2.fastq

cd /exports/eddie/scratch/s1659595/$1/trimmed_fastq/


#STAR 2-PASS ALIGNMENT
STAR --genomeDir /exports/eddie/scratch/s1659595/human_genome \
  --readFilesIn $2_1_val_1.fq $2_2_val_2.fq \
  --outSAMtype BAM Unsorted --quantMode TranscriptomeSAM \
  --outFilterMultimapNmax 10 --outFilterMismatchNmax 10 --outFilterMismatchNoverLmax 0.3 \
  --alignIntronMin 21 --alignIntronMax 0 --alignMatesGapMax 10000 --alignSJoverhangMin 5 \
  --runThreadN 12 --twopassMode Basic --twopass1readsN -1 --sjdbOverhang 100 \
  --outFileNamePrefix /exports/eddie/scratch/s1659595/$1/aln/$2_


cd /exports/eddie/scratch/s1659595/$1/aln/

#APPLY Q10 FILTER STEP AND SORT BAM by coordinates
#ON THE ALIGNED TO GENOME
samtools view -q 10 -b $2_Aligned.out.bam | samtools sort -T $2_Aligned.out.bam -o /exports/eddie/scratch/s1659595/$1/samtools/$2_genome_STAR_srt.bam -O bam - 

#ON THE ALIGNED TO TRANSCRIPTOME 
samtools view -q 10 -b $2_Aligned.toTranscriptome.out.bam | samtools sort -T $2_Aligned.toTranscriptome.out.bam -O bam -o /exports/eddie/scratch/s1659595/$1/samtools/$2_transcriptome_STAR_srt.bam -

cd /exports/eddie/scratch/s1659595/$1/samtools

#THE FOLLOWING COMMANDS RUN THE MAIN STATS FOR THE ALN SEQUENCES 
samtools flagstat $2_genome_STAR_srt.bam >  $2_genome_STAR_srt.txt
samtools flagstat $2_transcriptome_STAR_srt.bam > $2_transcriptome_STAR_srt.txt



# FEATURE_COUNTS (using conda-installed featureCounts)
featureCounts -T 8 -p -C -t exon -g gene_id \
  -a /exports/eddie/scratch/s1659595/human_genome/gencode.v49.annotation.gtf \
  -o /exports/eddie/scratch/s1659595/$1/feature_count/$3_genome.txt \
  $2_genome_STAR_srt.bam

featureCounts -T 8 -p -C -t exon -g gene_id \
  -a /exports/eddie/scratch/s1659595/human_genome/gencode.v49.annotation.gtf \
  -o /exports/eddie/scratch/s1659595/$1/feature_count/$3_transcriptome.txt \
  $2_transcriptome_STAR_srt.bam
  
  
