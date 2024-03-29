#!/bin/bash 

#SBATCH --job-name=mergefolder 

#SBATCH --partition=long 

#SBATCH --ntasks=1 

#SBATCH --output=log%J.out 

#SBATCH --error=log%J.err 

cd /PHShome/ys724/scratch/pca/merge/

folders=("0410" "0411" "0412" "0413")

for fl in "${folders[@]}"; do
awk '{print $3}' ${fl}_merge.pvar > ${fl}_snplist.txt
sort ${fl}_snplist.txt > ${fl}_snplist_sorted.txt
done

comm -12 0410_snplist_sorted.txt 0411_snplist_sorted.txt > common_0410_0411.txt
comm -12 common_0410_0411.txt 0412_snplist_sorted.txt > common_0410_0411_0412.txt
comm -12 common_0410_0411_0412.txt 0413_snplist_sorted.txt > common_all.txt

# take only SNP present in both datasets
module load Plink/2.0

for fl in "${folders[@]}"; do

plink2 \
  --keep-allele-order \
  --pfile ${fl}_merge \
  --extract common_all.txt \
  --make-bed \
  --out ${fl}_common
  
done

ls *_common.pgen | sed -e 's/.pgen//' > merge.txt

# merge datasets
/PHShome/ys724/software/plink2 --pmerge-list merge.txt --make-pfile --out MGBB
