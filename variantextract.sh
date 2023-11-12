#!/bin/bash 

#SBATCH --job-name=vcfextract 

#SBATCH --partition=long 

#SBATCH --ntasks=1 

#SBATCH --output=log%J.out 

#SBATCH --error=log%J.err 

cd /PHShome/ys724/Documents/GMBI_endometriosis/pca/

module load bcftools/1.11

for chr in {1..22};do

bcftools view -Oz \
  -i “ID = @variants.extract” \
  /data/biobank_release/datasets/0410/vcf/chr${chr}.dose.vcf.gz \
  > [/PHShome/ys724/scratch/pca/chr${chr}.extracted.vcf.gz]

done

bcftools concat -Oz /PHShome/ys724/scratch/pca/chr{1..22}.extracted.vcf.gz > /PHShome/ys724/scratch/pca/allchromosomes_0410.vcf.gz

module load Plink/2.0

cd /PHShome/ys724/scratch/pca/

plink2 \
  --vcf allchromosomes_0410.vcf.gz \
  dosage=DS \
  --make-pfile \
  --out allchromosomes_0410
