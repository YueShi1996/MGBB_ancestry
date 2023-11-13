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
mkdir /PHShome/ys724/scratch/pca/merge/

folders=("0410" "0411" "0412" "0413")

for fl in "${folders[@]}"; do
cd /PHShome/ys724/scratch/pca/${fl}
	ls chr*.pgen | sed -e 's/.pgen//' > merge-list_${fl}.txt
	/PHShome/ys724/software/plink2 --pmerge-list merge-list_${fl}.txt --out /PHShome/ys724/scratch/pca/merge/${fl}_merge    
done
```
### Project PC
```
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
  --out /PHShome/ys724/scratch/pca/projectpc/0410_score
```

### Assign pop
```R```
library(randomForest)
library(tidyverse)
library(ggsci)
library(RColorBrewer)
library(data.table)

setwd("/Users/shiyue//Desktop/Ancestry/")
ref <- fread("gnomad_meta_hgdp_tgp_v1.txt") #4150 individuals
ref1 <- fread("hgdp_tgp_pca_covid19hgi_snps_scores.txt.gz") # 3327 individuals
refs <- merge(x = ref, y = ref1, by = "s") #3105 individuals
colnames(refs)[colnames(refs) == "hgdp_tgp_meta.Genetic.region"] <- "superpop"
colnames(refs)[colnames(refs) == "hgdp_tgp_meta.Project"] <- "Project"
nvars <- nrow(fread("0410_score.sscore.vars", header = F))
proj <- fread("0410_score.sscore")
names(proj)[5:24] <- paste0("PC", 1:20)
proj[,superpop := "unknown"]
proj[,Project := "MGB"]
pcvecs <- paste0("PC", seq(10))
proj[, (pcvecs) := lapply(.SD, function(d) d/sqrt(nvars)), .SDcols = pcvecs]

pop_forest <- function(training_data, data, ntree=100, seed=2, pcs=1:npc) {
  set.seed(seed)
  form <- formula(paste('as.factor(superpop) ~', paste0('PC', pcs, collapse = '+' )))
  forest <- randomForest(form,
                         data = training_data,
                         importance = T,
                         ntree = ntree)
  print(forest)
  fit_data <- data.frame(predict(forest, data, type='prob'), sample = data$sample)
  fit_data %>%
    gather(predicted_pop, probability, -sample) %>%
    group_by(sample) %>%
    slice(which.max(probability))
}
trdat <- refs[,c("s", "superpop", paste0("PC", 1:20))]
names(trdat)[1] <- "sample"
tedat <- proj[,c("IID", paste0("PC", 1:20))]
names(tedat)[1] <- "sample"

npc=6
pop_pred <- as.data.table(pop_forest(training_data = trdat, data = tedat))
table(pop_pred$predicted_pop)
write.csv(pop_pred, "/Users/shiyue/Desktop/Ancestry/pop_pred.csv")
```R```
