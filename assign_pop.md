### Variants extraction

first extract a variant list from the pre-computed loadings file for filtering
```
cd /PHShome/ys724/Documents/GMBI_endometriosis/pca/

cut -f1 hgdp_tgp_pca_gbmi_snps_loadings.GRCh38.plink.tsv | tail -n +2 > variants.extract
```

for each chromosome file, run the following extraction command
```
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
```

merge all chromosomes 

```
