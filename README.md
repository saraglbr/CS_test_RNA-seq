# CS_test_RNA-seq
Technical exercise for Carlos Simon foundation consisting of the analysis of 6 RNA-seq samples, 3 biological repeats of two contidions "control" and treated"
Repository contains:

Code used to download data and prepare the genome for STAR mapping: 

      carlos_simon_prep_files.bash 
      h_genome_STAR_index

Code use for preprocessing (trimming, mapping & generating count matrix):

    human_rnaseq.bash

Further analysis after importing count matrix into R (differential gene expression analysis):

    carlos_simon_RNA.Rmd

