rule all:
    input:
        "interData/WHI_Broad_Amide_neg_mapping.tsv",
        "interData/WHI_Broad_Amide_neg.tsv",
        "interData/WHI_Broad_C18_neg_mapping.tsv",
        "interData/WHI_Broad_C18_neg.tsv",
        "interData/WHI_Broad_C8_pos_mapping.tsv",
        "interData/WHI_Broad_C8_pos.tsv",
        "interData/WHI_Broad_HILIC_pos_mapping.tsv",
        "interData/WHI_Broad_HILIC_pos.tsv",
        "interData/WHI_Metabolon_mapping.tsv",
        "interData/WHI_Metabolon.tsv"

rule cleanData:
    input:
        "sourceData/WHI_Metabolomics/19_1008_TOPMed_WHI_Broad_C18-neg_metabolomics_NONREDUNDANTonly_tabd.txt",
        "sourceData/WHI_Metabolomics/19_1126_TOPMed_WHI_Broad_C8-pos_metabolomics_v2_NONREDUNDANTonly_tabd.txt",
        "sourceData/WHI_Metabolomics/19_1211_TOPMed_WHI_Broad_HILIC-pos_metabolomics_NONREDUNDANTonly_tabd.txt",
        "sourceData/WHI_Metabolomics/20_0226_TOPMed_WHI_BIDMC_Amide-neg_metabolomics_tabd.txt",
        "sourceData/WHI_Metabolomics/2022.0124_WHI_Metabolon_BatchNormData.txt",
        "R/cleanData.R"
    output:
        "interData/WHI_Broad_Amide_neg_mapping.tsv",
        "interData/WHI_Broad_Amide_neg.tsv",
        "interData/WHI_Broad_C18_neg_mapping.tsv",
        "interData/WHI_Broad_C18_neg.tsv",
        "interData/WHI_Broad_C8_pos_mapping.tsv",
        "interData/WHI_Broad_C8_pos.tsv",
        "interData/WHI_Broad_HILIC_pos_mapping.tsv",
        "interData/WHI_Broad_HILIC_pos.tsv",
        "interData/WHI_Metabolon_mapping.tsv",
        "interData/WHI_Metabolon.tsv"
    shell:
        """
        Rscript R/cleanData.R
        """
