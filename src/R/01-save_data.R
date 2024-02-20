#author: Longfei Guan, Justin Wong
#date: 2022-03-24

#This script reads a dataset from the given URL and saves it as a csv file named 'garments_worker_productivity.csv'

doc<-"
Usage:
  src/R/01-write_data.R --url=<url>  --out_dir=<output_dir> 
    Options:
    --url=<url>		
      --out_dir=<output_dir>		
        "

suppressPackageStartupMessages({
  library(tidyverse)
  library(broom)
  library(GGally)
  library(leaps)
  library(glmnet)
  library(here)
  library(docopt)
  library(grp1ProjectPackage)
})


opt <- docopt(doc)
main <- function(url, out_dir) {
  data <- load_data(opt$url)
  write_csv(data, paste0(out_dir, "/garments_worker_productivity.csv"))
}

main(opt[["--url"]], opt[["--out_dir"]])