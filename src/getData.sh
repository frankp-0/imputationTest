#!/usr/bin/env sh

base="/proj/yunligrp/dbGAP_topmed/longleaf/dbGaP-12526/"
fhs="87816/topmed-dcc/exchange/phs000974_TOPMed_WGS_Framingham/Omics/"
whi="87815/topmed-dcc/exchange/phs001237_TOPMed_WGS_WHI/Omics/"


ln -s $base$fhs/Study_Metadata/omics_sample_metadata_FHS_metabolomics.tab sourceData/
ln -s $base$fhs/Metabolomics/20_0226_TOPMed_FHS_BIDMC_Amide-neg_metabolomics_tabd.txt sourceData/
ln -s $base$fhs/Metabolomics/19_0904_TOPMed_FHS_Broad_C18-neg_metabolomics_NONREDUNDANTonly_tabd.txt sourceData/
ln -s $base$fhs/Metabolomics/19_1203_TOPMed_FHS_Broad_C8-pos_metabolomics_v2_NONREDUNDANTonly_tabd.txt sourceData/
ln -s $base$fhs/Metabolomics/20_0213_TOPMed_FHS_Broad_HILIC-pos_metabolomics_NONREDUNDANTonly_tabd.txt sourceData/

ln -s $base/88883/topmed-dcc/exchange/phs001237_TOPMed_WGS_WHI/dbgap_submission/sub20220802/SCT-metabolomics_ID_map_age_LauraRaffield_2022-08-02.csv sourceData/
ln -s $base$whi/Metabolomics/2022.0124_WHI_Metabolon_BatchNormData.txt sourceData/
ln -s $base$whi/Metabolomics/2022.0124_WHI_Metabolon_ChemicalAnnotation.txt sourceData/
