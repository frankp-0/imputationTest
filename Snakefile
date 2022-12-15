cohort = ["FHS_Broad", "WHI_Metabolon"]
method = ["zero", "min", "median", "qrilc", "mai", "rf"]

rule all:
    input:
        expand("interData/{cohort}_{method}.tsv.gz", cohort = cohort, method = method),

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
        "sourceData/SCT-metabolomics_ID_map_age_LauraRaffield_2022-08-02.csv",
        "sourceData/topmed_dcc_harmonized_demographic_v4.txt"
    shell:
        """
        bash src/getData.sh
        """

rule cleanMetaboliteData:
    input:
        "sourceData/19_0904_TOPMed_FHS_Broad_C18-neg_metabolomics_NONREDUNDANTonly_tabd.txt",
        "sourceData/19_1203_TOPMed_FHS_Broad_C8-pos_metabolomics_v2_NONREDUNDANTonly_tabd.txt",
        "sourceData/20_0213_TOPMed_FHS_Broad_HILIC-pos_metabolomics_NONREDUNDANTonly_tabd.txt",
        "sourceData/20_0226_TOPMed_FHS_BIDMC_Amide-neg_metabolomics_tabd.txt",
        "sourceData/2022.0124_WHI_Metabolon_BatchNormData.txt",
        "sourceData/2022.0124_WHI_Metabolon_ChemicalAnnotation.txt",
        "R/cleanMetaboliteData.R"
    output:
        "interData/FHS_Broad.tsv",
        "interData/FHS_Broad_map.tsv",
        "interData/WHI_Metabolon_map.tsv",
        "interData/WHI_Metabolon.tsv"
    shell:
        """
        Rscript R/cleanMetaboliteData.R
        """

rule cleanPhenotypeData:
    input:
        "sourceData/omics_sample_metadata_FHS_metabolomics.tab",
        "sourceData/SCT-metabolomics_ID_map_age_LauraRaffield_2022-08-02.csv",
        "sourceData/topmed_dcc_harmonized_demographic_v4.txt",
        "R/cleanPhenotypeData.R"
    output:
        "interData/FHS_Broad_Pheno.tsv",
        "interData/WHI_Metabolon_Pheno.tsv"
    shell:
        """
        Rscript R/cleanPhenotypeData.R
        """

rule impute:
    input:
        "R/impute.R",
        data="interData/{cohort}.tsv"
    output:
        "interData/{cohort}_{method}.tsv.gz"
    shell:
        """
        Rscript R/impute.R \
            --dtFile {input.data} \
            --method {wildcards.method} \
            --ncores 10 \
            --outFile {output}
        """
