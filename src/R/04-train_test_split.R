#author: Anirudh Duggal, Justin Wong
#date: 2022-03-25

# This file ensures we get a user specfied percent break within the dataframe to 
# allow us to fetch a testing and training data frame that will be passed forward
# into analytical methods such as lasso and forward regression models

doc<-"
Usage:
  src/R/04-train_test_split.R --input=<input> --out_dir=<output_dir>
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
set.seed(20221127)
data.filtered <- read_csv(opt$input)
data.filtered$ID <- 1:nrow(data.filtered)
new_data<-train_test_split(data.filtered, 0.75, "ID")
training_data<-as.data.frame(new_data[1])
testing_data<-as.data.frame(new_data[2])

training_data<-clean_data(training_data, "ID")
testing_data<-clean_data(testing_data, "ID")

write_csv(training_data, paste0(opt$out_dir, "/train_data.csv"))
write_csv(testing_data, paste0(opt$out_dir, "/test_data.csv"))