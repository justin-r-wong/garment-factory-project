#author: Justin Wong
#date: 2022-03-23

# This script selects a model using forward selection on the given data.
# The evaluation metrics from forward selection is saved as a csv file named 'forward_selection_summary_metrics.csv'
# The summary statistics from the model chosen is saved as a csv file named 'forward_selection_model_summary.csv'
# The adjusted $R^2$ of the model chosen is saved as a csv file named 'adj_R2_forward_selection_model.csv'
# The plot of the residuals of the chosen model is saved as a png file named 'forward_selection_assumptions_plot1.png'
# The plot of the qq-plot of the chosen model is saved as a png file named 'forward_selection_assumptions_plot1.png'
# The summary statistics from the full model is saved as a csv file named 'full_model_summary.csv'
# The adjusted $R^2$ of the full model is saved as a csv file named 'adj_R2_full_model.csv'
# The results of the F-test between the chosen model and the full model is saved as a csv file named 'forward_selection_f_test.csv'
# The summary statistics on the test set from the model chosen is saved as a csv file named 'forward_selection_test_summary.csv'
# The adjusted $R^2$ of the model chosen on the test set is saved as a csv file named 'forward_selection_adj_R2_test.csv'

doc<-"
Usage:
  src/R/05-forward_selection.R --input=<input> --input2=<input2> --out_dir=<output_dir>
    Options:
    --input=<input>		
      --input2=<input2>	
      --out_dir=<output_dir>		
        "

suppressPackageStartupMessages({
  library(tidyverse)
  library(broom)
  library(GGally)
  library(leaps)
  library(glmnet)
  library(docopt)
  library(ggplotify)
  library(grp1ProjectPackage)
})

opt <- docopt(doc)

training_data <-read_csv(opt$input, show_col_types = FALSE)
testing_data <- read_csv(opt$input2, show_col_types = FALSE)

model_forward_sel <- regsubsets(
  x = actual_productivity ~ .,
  nvmax = 12,
  data = training_data,
  method = "forward")

model_forward_summary <- summary(model_forward_sel)

model_forward_summary_df <- data.frame(
  n_input_variables = 1:11,
  RSQ = model_forward_summary$rsq,
  RSS = model_forward_summary$rss,
  ADJ.R2 = model_forward_summary$adjr2
)
model_selected_1 <- lm(actual_productivity ~ targeted_productivity +
                         smv + wip + incentive + idle_men + no_of_style_change, 
                       data = training_data)
model_selected_summary_1 <- tidy(model_selected_1)

adj_r_squared_1 <- tibble(a=summary(model_selected_1)$adj.r.squared)

assumptions1<-as.ggplot(function() plot(model_selected_1, 1))
assumptions2<-as.ggplot(function() plot(model_selected_1, 2))

full_model <- lm(actual_productivity ~ ., data = training_data)
full_model_summary <- tidy(full_model, 0.95, conf.int = TRUE)

adj_r_squared_full <- tibble(a=summary(full_model)$adj.r.squared)

f_test<-anova(model_selected_1, full_model)


model_1 <- lm(actual_productivity ~ targeted_productivity +
                smv + wip + incentive + idle_men + no_of_style_change,
              data = testing_data)
model_summary <- tidy(model_1)

adj_r_squared <- tibble(a=summary(model_1)$adj.r.squared)

write_csv(model_forward_summary_df, paste0(opt$out_dir, "/forward_selection_summary_metrics.csv"))
write_csv(model_selected_summary_1, paste0(opt$out_dir, "/forward_selection_model_summary.csv"))
write_csv(adj_r_squared_1, paste0(opt$out_dir, "/adj_R2_forward_selection_model.csv"))
ggsave(paste0(opt$out_dir, "/forward_selection_assumptions_plot1.png"),
       assumptions1)
ggsave(paste0(opt$out_dir, "/forward_selection_assumptions_plot2.png"),
       assumptions2)
write_csv(full_model_summary, paste0(opt$out_dir, "/full_model_summary.csv"))
write_csv(adj_r_squared_full, paste0(opt$out_dir, "/adj_R2_full_model.csv"))
write_csv(f_test, paste0(opt$out_dir, "/forward_selection_f_test.csv"))
write_csv(model_summary, paste0(opt$out_dir, "/forward_selection_test_summary.csv"))
write_csv(adj_r_squared, paste0(opt$out_dir, "/forward_selection_adj_R2_test.csv"))