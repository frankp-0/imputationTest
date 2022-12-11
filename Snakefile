rule all:
    input:
        "interData/FHS_Broad.tsv",
        "interData/FHS_Broad_map.tsv",
        "interData/WHI_Metabolon_map.tsv",
        "interData/WHI_Metabolon.tsv"

rule linkSourceData:
    input:
        "src/getData.sh"
    output:
        "sourceData/19_0904_TOPMed_FHS_Broad_C18-neg_metabolomics_NONREDUNDANTonly_tabd.txt",
        "sourceData/19_1203_TOPMed_FHS_Broad_C8-pos_metabolomics_v2_NONREDUNDANTonly_tabd.txt",
        "sourceData/20_0213_TOPMed_FHS_Broad_HILIC-pos_metabolomics_NONREDUNDANTonly_tabd.txt",
        "sourceData/20_0226_TOPMed_FHS_BIDMC_Amide-neg_metabolomics_tabd.txt",
        "sourceData/2022.0124_WHI_Metabolon_BatchNormData.txt",
        "sourceData/2022.0124_WHI_Metabolon_ChemicalAnnotation.txt",
        "sourceData/omics_sample_metadata_FHS_metabolomics.tab",
        "sourceData/SCT-metabolomics_ID_map_age_LauraRaffield_2022-08-02.csv"
    shell:
        """
        bash src/getData.sh
        """

rule cleanMetabolomicsData:
    input:
        "sourceData/19_0904_TOPMed_FHS_Broad_C18-neg_metabolomics_NONREDUNDANTonly_tabd.txt",
        "sourceData/19_1203_TOPMed_FHS_Broad_C8-pos_metabolomics_v2_NONREDUNDANTonly_tabd.txt",
        "sourceData/20_0213_TOPMed_FHS_Broad_HILIC-pos_metabolomics_NONREDUNDANTonly_tabd.txt",
        "sourceData/20_0226_TOPMed_FHS_BIDMC_Amide-neg_metabolomics_tabd.txt",
        "sourceData/2022.0124_WHI_Metabolon_BatchNormData.txt",
        "sourceData/2022.0124_WHI_Metabolon_ChemicalAnnotation.txt",
        "R/cleanSourceData.R"
    output:
        "interData/FHS_Broad.tsv",
        "interData/FHS_Broad_map.tsv",
        "interData/WHI_Metabolon_map.tsv",
        "interData/WHI_Metabolon.tsv"
    shell:
        """
        Rscript R/cleanSourceData.R
        """
