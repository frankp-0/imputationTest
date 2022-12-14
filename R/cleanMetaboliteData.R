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
  dt <- dt[!grepl("Internal", HMDB_ID), ]
  # format missing HMDB IDs as NA
  dt[HMDB_ID == "", "HMDB_ID"] <- NA
  # make data frame with metabolite information
  dt[, Assignment := `Assignment_certainty (1=match to single HMDB ID, 2=match to more than one HMDB ID)`]
  map <- dt[, .(Metabolite, HMDB_ID, Assignment)]
  dt %<>% transposeData()
  # assign arbitrary name to unnamed metabolites
  names(dt) <- make.unique(names(dt))
  map$Metabolite <- make.unique(map$Metabolite)
  return(list(map = map, dt = dt))
}

#### Process Broad Files
broadFiles <- c("19_0904_TOPMed_FHS_Broad_C18-neg_metabolomics_NONREDUNDANTonly_tabd.txt",
               "19_1203_TOPMed_FHS_Broad_C8-pos_metabolomics_v2_NONREDUNDANTonly_tabd.txt",
               "20_0213_TOPMed_FHS_Broad_HILIC-pos_metabolomics_NONREDUNDANTonly_tabd.txt",
               "20_0226_TOPMed_FHS_BIDMC_Amide-neg_metabolomics_tabd.txt")
broadFiles <- paste0("sourceData/", broadFiles)

broadPlatforms <- c("C18_neg", "C8_pos", "HILIC_pos", "Amide_neg")

# clean data for each platform
for (i in 1:4){
  cleanedData <- cleanBroad(broadFiles[i])
  cleanedData$map$Platform <- broadPlatforms[i]
  names(cleanedData$dt)[startsWith(names(cleanedData$dt), ".")] <- paste0(".", broadPlatforms[i], names(cleanedData$dt)[startsWith(names(cleanedData$dt), ".")])
  cleanedData$map$Metabolite[startsWith(cleanedData$map$Metabolite, ".")] <- paste0(".", broadPlatforms[i], cleanedData$map$Metabolite[startsWith(cleanedData$map$Metabolite, ".")])
  assign(broadPlatforms[i], cleanedData$dt)
  assign(paste0(broadPlatforms[i], "_map"), cleanedData$map)
}

# combine Broad data across platforms
dtBroad <- Reduce(function(x, y) merge(x, y, by="ID"), list(C18_neg, C8_pos, HILIC_pos, Amide_neg))
mapBroad <- rbind(C18_neg_map, C8_pos_map, HILIC_pos_map, Amide_neg_map)

# make metabolite names unique
names(dtBroad) <- make.unique(names(dtBroad))
mapBroad$Metabolite <- make.unique(mapBroad$Metabolite)

# write Broad data
fwrite(dtBroad, "interData/FHS_Broad.tsv", sep = '\t')
fwrite(mapBroad, "interData/FHS_Broad_map.tsv", sep = '\t')

#### Process Metabolon Files
dt <- fread("sourceData/2022.0124_WHI_Metabolon_BatchNormData.txt", header = T)
anno <- fread("sourceData/2022.0124_WHI_Metabolon_ChemicalAnnotation.txt")
names(dt)[2:ncol(dt)] <- anno$CHEMICAL_NAME[match(names(dt)[2:ncol(dt)], anno$CHEM_ID)]
dt[, ID := TOMID]
dt[, TOMID := NULL]

map <- fread("sourceData/2022.0124_WHI_Metabolon_ChemicalAnnotation.txt")
map <- map[, .(CHEM_ID, LEVEL, HMDB, CHEMICAL_NAME, PLATFORM)]
fwrite(dt, sep = '\t', "interData/WHI_Metabolon.tsv")
fwrite(map, sep = '\t', "interData/WHI_Metabolon_map.tsv")
