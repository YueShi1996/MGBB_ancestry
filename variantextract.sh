#!/bin/bash 

#SBATCH --job-name=vcfextract 

#SBATCH --partition=long 

#SBATCH --ntasks=1 

#SBATCH --output=log%J.out 

#SBATCH --error=log%J.err 

folders=("0410" "0411" "0412" "0413")

module load Plink/2.0

for fl in "${folders[@]}"; do

tmpdir=/PHShome/ys724/scratch/PCA/${fl}
mkdir ${tmpdir}
cd /data/biobank_release/datasets/${fl}/vcf

for chr in $(seq 1 22);do

plink2 \
  --vcf chr${chr}.dose.vcf.gz \
  dosage=DS \
  --make-pfile \
  --extract /PHShome/ys724/Documents/GMBI_endometriosis/pca/variants.extract \
  --out ${tmpdir}/chr${chr}_dosage_extract

zcat chr${chr}.info.gz | awk '$7 > 0.3 {print $1}' >  ${tmpdir}/chr${chr}_info_0.3.snplist
  
done
done
