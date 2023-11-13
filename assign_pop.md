### Variants extraction

first extract a variant list from the pre-computed loadings file for filtering
```
cd /PHShome/ys724/Documents/GMBI_endometriosis/pca/

cut -f1 hgdp_tgp_pca_gbmi_snps_loadings.GRCh38.plink.tsv | tail -n +2 > variants.extract
```

For each chromosome file, run the following extraction command, then merge
```
cd /PHShome/ys724/Documents/GMBI_endometriosis/pca/

module load bcftools/1.11

for chr in {1..22};do

bcftools view -Oz \
  -i “ID = @variants.extract” \
  /data/biobank_release/datasets/0410/vcf/chr${chr}.dose.vcf.gz \
  > [/PHShome/ys724/scratch/pca/chr${chr}.extracted.vcf.gz]

done

# merge all chromosomes

bcftools concat -Oz /PHShome/ys724/scratch/pca/chr{1..22}.extracted.vcf.gz > /PHShome/ys724/scratch/pca/allchromosomes_0410.vcf.gz

#convert vcf to plink2 

module load Plink/2.0

cd /PHShome/ys724/scratch/pca/

plink2 \
  --vcf allchromosomes_0410.vcf.gz \
  dosage=DS \
  --make-pfile \
  --out allchromosomes_0410

```
