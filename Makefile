# Makefile
# Group 1, March 25
#
# This script completes the whole analysis of the project including
# loading/transforming the data, creating plots, selecting and testing
# a model as well as rendering the final report. This script takes no
# arguments.
#
# Usage:
# - to run entire analysis: make all
# - to clean the entire analysis: make clean

all: data/garments_worker_productivity.csv data/filtered_data.csv results/pair_plots.png data/train_data.csv results/forward_selection_summary_metrics.csv results/lasso_lambda_plot.png
		
# loading the data
data/garments_worker_productivity.csv : src/R/01-save_data.R
		Rscript src/R/01-save_data.R --url="https://7e6cd356-86ad-4874-abc7-3a69bbbc39e6.filesusr.com/ugd/c5a545_c1b17c070c984dfcb14cf1c3bb0b6e67.csv?dn=garments_worker_productivity.csv" --out_dir="data"
		
# tidying the data
data/filtered_data.csv : data/garments_worker_productivity.csv src/R/02-clean_data.R
		Rscript src/R/02-clean_data.R --input="data/garments_worker_productivity.csv" --out_dir="data"

# EDA 
results/pair_plots.png : data/filtered_data.csv src/R/03-EDA_figures.R
		Rscript src/R/03-EDA_figures.R --input="data/filtered_data_init.csv" --out_dir="results"

results/day_boxplot.png : data/filtered_data.csv src/R/03-EDA_figures.R
		Rscript src/R/03-EDA_figures.R --input="data/filtered_data_init.csv" --out_dir="results"

results/department_boxplot.png : data/filtered_data.csv src/R/03-EDA_figures.R
		Rscript src/R/03-EDA_figures.R --input="data/filtered_data_init.csv" --out_dir="results"

results/actual_productivity_distribution.png : data/filtered_data.csv src/R/03-EDA_figures.R
		Rscript src/R/03-EDA_figures.R --input="data/filtered_data_init.csv" --out_dir="results"

results/actual_productivity_qqplot.png : data/filtered_data.csv src/R/03-EDA_figures.R
		Rscript src/R/03-EDA_figures.R --input="data/filtered_data_init.csv" --out_dir="results"

results/summary_table_1.csv : data/filtered_data.csv src/R/03-EDA_figures.R
		Rscript src/R/03-EDA_figures.R --input="data/filtered_data_init.csv" --out_dir="results"

# data pre-processing: split into training and testing sets
data/train_data.csv : data/filtered_data.csv src/R/04-train_test_split.R
		Rscript src/R/04-train_test_split.R --input="data/filtered_data.csv" --out_dir="data"

data/test_data.csv : data/filtered_data.csv src/R/04-train_test_split.R
		Rscript src/R/04-train_test_split.R --input="data/filtered_data.csv" --out_dir="data"

# model selection with forward selection
results/forward_selection_summary_metrics.csv : data/train_data.csv data/test_data.csv src/R/05-forward_selection.R
		Rscript src/R/05-forward_selection.R --input="data/train_data.csv" --input2="data/test_data.csv" --out_dir="results"
		
results/forward_selection_model_summary.csv : data/train_data.csv data/test_data.csv src/R/05-forward_selection.R
		Rscript src/R/05-forward_selection.R --input="data/train_data.csv" --input2="data/test_data.csv" --out_dir="results"
		
results/adj_R2_forward_selection_model.csv : data/train_data.csv data/test_data.csv src/R/05-forward_selection.R
		Rscript src/R/05-forward_selection.R --input="data/train_data.csv" --input2="data/test_data.csv" --out_dir="results"
		
results/forward_selection_assumptions_plot1.png : data/train_data.csv data/test_data.csv src/R/05-forward_selection.R
		Rscript src/R/05-forward_selection.R --input="data/train_data.csv" --input2="data/test_data.csv" --out_dir="results"
		
results/forward_selection_assumptions_plot2.png : data/train_data.csv data/test_data.csv src/R/05-forward_selection.R
		Rscript src/R/05-forward_selection.R --input="data/train_data.csv" --input2="data/test_data.csv" --out_dir="results"
		
results/full_model_summary.csv : data/train_data.csv data/test_data.csv src/R/05-forward_selection.R
		Rscript src/R/05-forward_selection.R --input="data/train_data.csv" --input2="data/test_data.csv" --out_dir="results"
		
results/adj_R2_full_model.csv : data/train_data.csv data/test_data.csv src/R/05-forward_selection.R
		Rscript src/R/05-forward_selection.R --input="data/train_data.csv" --input2="data/test_data.csv" --out_dir="results"
		
results/forward_selection_f_test.csv : data/train_data.csv data/test_data.csv src/R/05-forward_selection.R
		Rscript src/R/05-forward_selection.R --input="data/train_data.csv" --input2="data/test_data.csv" --out_dir="results"
		
results/forward_selection_test_summary.csv : data/train_data.csv data/test_data.csv src/R/05-forward_selection.R
		Rscript src/R/05-forward_selection.R --input="data/train_data.csv" --input2="data/test_data.csv" --out_dir="results"
		
results/forward_selection_adj_R2_test.csv : data/train_data.csv data/test_data.csv src/R/05-forward_selection.R
		Rscript src/R/05-forward_selection.R --input="data/train_data.csv" --input2="data/test_data.csv" --out_dir="results"
		
# model selection with lasso
results/lasso_lambda_plot.png : data/train_data.csv data/test_data.csv src/R/06-lasso.R
		Rscript src/R/06-lasso.R --input="data/train_data.csv" --input2="data/test_data.csv" --out_dir="results"

results/lasso_assumptions_plot1.png : data/train_data.csv data/test_data.csv src/R/06-lasso.R
		Rscript src/R/06-lasso.R --input="data/train_data.csv" --input2="data/test_data.csv" --out_dir="results"
	
results/lasso_assumptions_plot2.png : data/train_data.csv data/test_data.csv src/R/06-lasso.R
		Rscript src/R/06-lasso.R --input="data/train_data.csv" --input2="data/test_data.csv" --out_dir="results"

results/adj_R2_lasso.csv : data/train_data.csv data/test_data.csv  src/R/06-lasso.R
		Rscript src/R/06-lasso.R --input="data/train_data.csv" --input2="data/test_data.csv" --out_dir="results"

results/lasso_f_test.csv : data/train_data.csv data/test_data.csv src/R/06-lasso.R
		Rscript src/R/06-lasso.R --input="data/train_data.csv" --input2="data/test_data.csv" --out_dir="results"

results/lasso_test_summary.csv : data/train_data.csv data/test_data.csv src/R/06-lasso.R
		Rscript src/R/06-lasso.R --input="data/train_data.csv" --input2="data/test_data.csv" --out_dir="results"
	
results/adj_R2_test_lasso.csv : data/train_data.csv data/test_data.csv src/R/06-lasso.R
		Rscript src/R/06-lasso.R --input="data/train_data.csv" --input2="data/test_data.csv" --out_dir="results"

# render report
.PHONY: report
report:
	make clean 
	make all
	Rscript -e "rmarkdown::render('notebooks/garments_factory_analysis.Rmd')"

.PHONY: clean
clean:
	rm -r data/*
	rm -r results/*
	rm -rf notebooks/garments_factory_analysis.html