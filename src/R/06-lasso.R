#author: Justin Wong
#date: 2022-03-23

# This script selects a model using LASSO on the given data.
# The plot of the lambda chosen by cross-validation is saved as a png file named 'lasso_lambda_plot.png'
# The plot of the residuals of the chosen model is saved as a png file named 'lasso_assumptions_plot1.png'
# The plot of the qq-plot of the chosen model is saved as a png file named 'lasso_assumptions_plot2.png'
# The adjusted $R^2$ of the model chosen is saved as a csv file named 'adj_R2_lasso.csv'
# The results of the F-test between the chosen model and the full model is saved as a csv file named 'lasso_f_test.csv'
# The summary statistics on the test set from the model chosen is saved as a csv file named 'lasso_test_summary.csv'
# The adjusted $R^2$ of the model chosen on the test set is saved as a csv file named 'adj_R2_test_lasso.csv'

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
options(repr.plot.width = 10, repr.plot.height = 14)

opt <- docopt(doc)

training_data <-read_csv(opt$input, show_col_types = FALSE)
testing_data <- read_csv(opt$input2, show_col_types = FALSE)


data_X_train <- training_data %>% select(-"actual_productivity")  %>% data.matrix()
data_Y_train <- training_data %>% select("actual_productivity")  %>% data.matrix()

data_X_test <- testing_data %>% select(-"actual_productivity")  %>% data.matrix()
data_Y_test <- testing_data %>% select("actual_productivity")  %>% data.matrix()

data_cv_lambda_LASSO <- cv.glmnet(
  x = data_X_train, y = data_Y_train,
  alpha = 1)

lasso_plot<-as.ggplot(function() plot(data_cv_lambda_LASSO, main = "Lambda Selection by CV with LASSO"))
lambda_min_MSE_LASSO <- round(data_cv_lambda_LASSO$lambda.min, 4)

data_LASSO_min <- glmnet(
  x = data_X_train, y = data_Y_train,
  alpha = 1,
  lambda = lambda_min_MSE_LASSO
)

variables_selected_LASSO <- as_tibble(as.matrix(coef(data_LASSO_min)),rownames='covariate') %>%
  filter(covariate != '(Intercept)' & abs(s0) > 10e-6) %>% 
  pull(covariate)

LASSO_model <- lm(actual_productivity ~ targeted_productivity +
                    smv + incentive + idle_men + no_of_style_change, 
                  data = training_data)

assumptions1<-as.ggplot(function() plot(LASSO_model, 1))
assumptions2<-as.ggplot(function() plot(LASSO_model, 2))

adj_r_squared_LASSO <- tibble(a=summary(LASSO_model)$adj.r.squared)

full_model <- lm(actual_productivity ~ ., data = training_data)

lasso_f_test<- anova(LASSO_model, full_model)


model_2 <- lm(actual_productivity ~ targeted_productivity +
                smv + incentive + idle_men + no_of_style_change, 
              data = testing_data)
model_summary_2 <- tidy(model_2)

adj_r_squared_2 <- tibble(a=summary(model_2)$adj.r.squared)

ggsave(paste0(opt$out_dir, "/lasso_lambda_plot.png"),
       lasso_plot)
ggsave(paste0(opt$out_dir, "/lasso_assumptions_plot1.png"),
       assumptions1)
ggsave(paste0(opt$out_dir, "/lasso_assumptions_plot2.png"),
       assumptions2)
write_csv(adj_r_squared_LASSO, paste0(opt$out_dir, "/adj_R2_lasso.csv"))
write_csv(lasso_f_test, paste0(opt$out_dir, "/lasso_f_test.csv"))
write_csv(model_summary_2, paste0(opt$out_dir, "/lasso_test_summary.csv"))
write_csv(adj_r_squared_2, paste0(opt$out_dir, "/adj_R2_test_lasso.csv"))