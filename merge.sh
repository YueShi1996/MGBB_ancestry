#!/bin/bash

#BATCH --job-name=merge 

#SBATCH --partition=long 

#SBATCH --ntasks=1 

#SBATCH --output=log%J.out 

#SBATCH --error=log%J.err 

mkdir /PHShome/ys724/scratch/pca/merge/

folders=("0410" "0411" "0412" "0413")

for fl in "${folders[@]}"; do
cd /PHShome/ys724/scratch/pca/${fl}
	ls chr*.pgen | sed -e 's/.pgen//' > merge-list_${fl}.txt
	/PHShome/ys724/software/plink2 --pmerge-list merge-list_${fl}.txt --out /PHShome/ys724/scratch/pca/merge/${fl}_merge    
done



