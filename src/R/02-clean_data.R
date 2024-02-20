#author: Anirudh Duggal, Justin Wong
#date: 2022-03-25

# This script makes sure that the dataset being used in all following processes and evaluation methods 
# is cleaned and contains only those variables of interest

doc<-"
Usage:
  src/R/02-clean_data.R --input=<input> --out_dir=<output_dir>
    Options:
    --input=<input>		
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
main <- function(input, out_dir) {
  data_df <- read_csv(opt$input)
  data.filtered <-
    clean_data(data_df, c("date", "team")) %>%
    mutate(wip = ifelse((is.na(wip)), 0, wip)) %>%
    mutate(department = ifelse((department == "finishing "), "finishing", department)) %>%
    mutate(department = ifelse((department == "sweing"), "sewing", department)) %>%
    mutate(department = as.factor(department)) %>%
    mutate(day = if_else(day %in% c("Monday", "Tuesday", "Wednesday", "Thursday"), "Weekday", "Weekend")) %>%
    mutate(half = if_else(quarter %in% c("Quarter1", "Quarter2"), "Half1", "Half2"))  %>%
    clean_data(., "quarter") %>%
    mutate(day = as.factor(day)) %>%
    mutate(half = as.factor(half))
  write_csv(data.filtered, paste0(opt$out_dir, "/filtered_data_init.csv"))
}
main(opt[["--input"]], opt[["--out_dir"]])