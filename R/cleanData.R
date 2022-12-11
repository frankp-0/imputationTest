library(data.table)
library(magrittr)

#### Helper Functions
# reads metabolomic data from, removes header, and returns a data table
stripHeader <- function(file){
  # use awk to identify where header ends
  comm <- paste0("awk '{ print $1}' ", file, " | grep -hn Method")
  commRes <- system(comm, intern = T)
  idx <- sub(":.*", "", commRes) %>% as.integer() - 1

  # read data, skipping header
  dt <- fread(file, skip = idx)

  # switch HMDB_ID, Assignment_certainty columns for Amide-neg only
  # this is necessary because there is error with column coding for Amide-neg
  if(grepl("Amide", file)){
    tmpID <- dt$HMDB_ID
    dt$HMDB_ID <- dt$`Assignment_certainty (1=match to single HMDB ID, 2=match to more than one HMDB ID)`
    dt$`Assignment_certainty (1=match to single HMDB ID, 2=match to more than one HMDB ID)` <- tmpID
  }

  return(dt)
}

# transposes data to row=subject, col=metabolite/ID
# metabolites labeled with names (instead of IDs)
transposeData <- function(dt){
  idxMetab <- grep("Metabolite", names(dt))
  metNames <- dt$Metabolite
  # keep only columns corresponding to valid subjects
  dt <- dt[, .SD, .SDcols = grep("TOM", names(dt))]
  # transpose data
  ID <- names(dt)
  metMat <- dt %>% as.matrix() %>% t()
  dt <- as.data.table(metMat)
  setnames(dt, metNames)
  dt[, ID := ID]
  return(dt)
}

cleanBroad <- function(file){
  dt <- stripHeader(file)
  # remove internal standards
  dt <- dt[!grepl("internal", HMDB_ID), ]
  # format missing HMDB IDs as NA
  dt[HMDB_ID == "", "HMDB_ID"] <- NA
  # make data frame with metabolite information
  dt[, Assignment := `Assignment_certainty (1=match to single HMDB ID, 2=match to more than one HMDB ID)`]
  mapping <- dt[, .(Metabolite, HMDB_ID, Assignment)]
  # assign arbitrary name to unnamed metabolites
  dt %<>% transposeData()
  return(list(mapping = mapping, dt = dt))
}

#### Process Broad Files
broadFiles <- c("19_1008_TOPMed_WHI_Broad_C18-neg_metabolomics_NONREDUNDANTonly_tabd.txt",
                "19_1126_TOPMed_WHI_Broad_C8-pos_metabolomics_v2_NONREDUNDANTonly_tabd.txt",
                "19_1211_TOPMed_WHI_Broad_HILIC-pos_metabolomics_NONREDUNDANTonly_tabd.txt",
                "20_0226_TOPMed_WHI_BIDMC_Amide-neg_metabolomics_tabd.txt")
broadFiles <- paste0("sourceData/", broadFiles)

broadAssays <- c("C18_neg", "C8_pos", "HILIC_pos", "Amide_neg")

for (i in 1:4){
  cleanedData <- cleanBroad(broadFiles[i])
  fwrite(cleanedData$dt,
         sep = '\t',
         file = paste0("interData/", "WHI_Broad_", broadAssays[i], ".tsv"))
  fwrite(cleanedData$mapping,
         sep = '\t',
         file = paste0("interData/", "WHI_Broad_", broadAssays[i], "_mapping.tsv"))
}

#### Process Metabolon Files
dt <- fread("sourceData/2022.0124_WHI_Metabolon_BatchNormData.txt", header = T)
dt[, ID := TOMID]
dt[, TOMID := NULL]
mapping <- fread("sourceData/2022.0124_WHI_Metabolon_ChemicalAnnotation.txt")
mapping <- mapping[, .(CHEM_ID, LEVEL, HMDB, CHEMICAL_NAME, PLATFORM)]
fwrite(dt, sep = '\t', "interData/WHI_Metabolon.tsv")
fwrite(mapping, sep = '\t', "interData/WHI_Metabolon_mapping.tsv")
