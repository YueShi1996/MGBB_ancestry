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
