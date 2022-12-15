library(data.table)
library(magrittr)
library(imputeLCMD)
library(optparse)
library(MAI)
library(missForest)
library(doParallel)

option_list <- list(
  make_option("--dtFile", type = "character"),
  make_option("--method", type = "character"),
  make_option("--ncores", type = "integer"),
  make_option("--outFile", type = "character")
)

parser <- OptionParser(usage = "%prog [options]", option_list = option_list)
args <- parse_args(parser, positional_arguments = 0)
opt <- args$options


doImpute <- function(dtFile, method, ncores){
  dt <- fread(dtFile)
  ID <- dt$ID
  dt[, ID := NULL]
                                        # remove metabolites with > 50% missingness
  dt <- dt[, .SD, .SDcols = colMeans(is.na(dt)) < 0.5]
                                        # index metabolites with < 1% missingness
  toKeep <- colMeans(is.na(dt)) > 0.01

                                        # imputation
  if (method == "zero"){
    dtImp <- apply(dt, 1, function(x) {x[is.na(x)] <- 0; x})
  } else if(method == "min"){
    dtImp <- apply(dt, 1, function(x) {x[is.na(x)] <- min(x, na.rm = T)/2; x})
  } else if (method == "median"){
    dtImp <- apply(dt, 1, function(x) {x[is.na(x)] <- median(x, na.rm = T)/2; x})
  } else if(method == "qrilc"){
    dtImp <- data.table(t(impute.QRILC(dt)[[1]]))
  } else if(method == "mai"){
    dtImp <- data.table(MAI(as.matrix(dt))[["Imputed_data"]])
  } else if (method == "rf"){
    registerDoParallel(ncores-1)
    dtImp <- missForest(dt, parallelize = "variables", verbose = TRUE)
  }
                                        # remove metabolites with < 1% missingness
  dtImp <- data.table(t(dtImp))[, .SD, .SDcols = toKeep]
  dtImp$ID <- ID
  return(dtImp)
}

dtImp <- doImpute(opt$dtFile, opt$method, opt$ncores)
fwrite(dtImp, opt$outFile, compress = "auto")
