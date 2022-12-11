library(data.table)
library(magrittr)

FHS_meta <- fread("sourceData/omics_sample_metadata_FHS_metabolomics.tab")
FHS_demo <- fread("sourceData/topmed_dcc_harmonized_demographic_v4.txt")
WHI <- fread("sourceData/SCT-metabolomics_ID_map_age_LauraRaffield_2022-08-02.csv")

#### FHS
# acquire SAMPLE_ID for demographic data
FHS_demo <- FHS_demo[SUBJECT_ID %in% FHS_meta$SUBJECT_ID,]
FHS_demo[, SAMPLE_ID := FHS_meta$SAMPLE_ID[match(FHS_demo$SUBJECT_ID, FHS_meta$SUBJECT_ID)]]
# make phenotype data table
FHS <- merge(FHS_demo, FHS_meta, by = "SAMPLE_ID")
FHS <- FHS[, .(SAMPLE_ID, annotated_sex_1, Age_at_collection)]
setnames(FHS, c("ID", "Sex", "Age"))
# write phenotye file
fwrite(FHS, "interData/FHS_Broad_Pheno.tsv")

#### WHI
WHI <- WHI[, .(TOMID, metab_age)]
setnames(WHI, c("ID", "Age"))
fwrite(WHI, "interData/WHI_Metabolon_Pheno.tsv")
