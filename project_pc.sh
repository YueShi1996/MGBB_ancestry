#!/bin/bash 

#SBATCH --job-name=vcfextract 

#SBATCH --partition=long 

#SBATCH --ntasks=1 

#SBATCH --output=log%J.out 

#SBATCH --error=log%J.err 

cd /PHShome/ys724/scratch/pca/merge/
mkdir /PHShome/ys724/scratch/pca/projectpc

plink2 \
  --pfile 0410_merge \
  --score /PHShome/ys724/Documents/GMBI_endometriosis/pca/hgdp_tgp_pca_gbmi_snps_loadings.GRCh38.plink.tsv \
  variance-standardize \
  cols=-scoreavgs,+scoresums \
  list-variants \
  header-read \
  --score-col-nums 3-22 \
  --read-freq /PHShome/ys724/Documents/GMBI_endometriosis/pca/hgdp_tgp_pca_gbmi_snps_loadings.GRCh38.plink.afreq \
  --out /PHShome/ys724/scratch/pca/projectpc/0410_projectpc
