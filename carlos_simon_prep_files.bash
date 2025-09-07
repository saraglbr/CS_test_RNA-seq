
#Download data using the spratoolkit/////////////
#Run in HPC environment 
#Prior to starting - created a text file with all required accession numbers (list_sra.txt)

cd /exports/eddie/scratch/s1659595/download/

module load igmm/apps/sratoolkit/3.1.1 #load spratoolkit into environment

prefetch --option-file list_sra.txt #download data

vdb-validate SRR* #confirm data integrity in all SRR subfolders

cd /exports/eddie/scratch/s1659595/fastq 

fasterq-dump /exports/eddie/scratch/s1659595/download/SRR* #extract fastq files 

module load igmm/apps/FastQC/0.12.1
fastqc --noextract --nogroup -o fastqc SRR* #run FASTQC to check quality of raw reads 



#Preparing STAR genome index ////////////////////////
#As I usually work in mouse, I need to generate STAR genome index for human

#Download genome and annotation files
wget https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_49/GRCh38.p14.genome.fa.gz

wget https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_49/gencode.v49.annotation.gtf.gz

#Unzip files
gunzip GRCh38.p14.genome.fa.gz
gunzip gencode.v49.annotation.gtf.gz

#Code used to generate STAR indexes was submitted as a job (see h_gen_STAR_index.txt for details)
qsub h_gen_STAR_index.txt 




