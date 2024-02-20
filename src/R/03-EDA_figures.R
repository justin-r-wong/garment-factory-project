#author: Longfei Guan, Justin Wong
#date: 2022-03-23

# This scripts runs exploratory data analysis on the given data and outputs graphs and summary table.
# The the correlation values between the variables is saved as a png file named 'pair_plots.png'.
# The boxplot of the actual productivity by day of the week is saved as a png file named 'day_boxplot.png'.
# The boxplot of the actual productivity by half is saved as a png file named 'half_boxplot.png'.
# The boxplot of the actual productivity by department is saved as a png file named 'department_boxplot.png'.
# The distribution of actual productivity is saved as a png file named 'actual_productivity_distribution.png'.
# The QQ plot of actual productivity is saved as a png file named 'actual_productivity_qqplot.png'.
# The summary table of actual productivity for different halves and departments is saved as a csv file named 'summary_table_1.csv'.

doc<-"
Usage:
  src/R/03-EDA_figures --input=<input> --out_dir=<output_dir>
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

data.filtered <-read_csv(opt$input)

options(repr.plot.width = 15, repr.plot.height = 10)

pair_plots <-ggpairs(data.filtered) +
  theme(
    text = element_text(size = 15),
    plot.title = element_text(face = "bold"),
    axis.title = element_text(face = "bold")
  )

data.filtered <- clean_data(data.filtered, "no_of_workers")

options(repr.plot.width = 10, repr.plot.height = 4)

day_boxplot <- create_boxplot(data.filtered, data.filtered$day,
                              data.filtered$actual_productivity,
                              "Actual Productivity by Day of the Week",
                              "Weekend/Weekday", "Actual Productivity")


half_boxplot <- create_boxplot(data.filtered, data.filtered$half,
                               data.filtered$actual_productivity,
                               "Actual Productivity by Half",
                               "Half", "Actual Productivity")

department_boxplot <- create_boxplot(data.filtered, data.filtered$department,
                                     data.filtered$actual_productivity,
                                     "Actual Productivity of Departments",
                                     "Department", "Actual Productivity")


options(repr.plot.width = 10, repr.plot.height = 5)

actual_productivity_distribution <- data.filtered %>%
  ggplot(aes(x = actual_productivity)) +
  geom_histogram(bins = 20) +
  ggtitle("Distribution of Actual Productivity")+
  labs(x = "Actual Productivity") +
  labs(y = "Frequency")+ theme(
    text = element_text(size = 20),
    plot.title = element_text(face = "bold"),
    axis.title = element_text(face = "bold") )

actual_productivity_qqplot <- ggplot(data.filtered, aes(sample = actual_productivity)) + stat_qq() + stat_qq_line()+
  labs(title ="Normal Q-Q Plot", x ="Theoretical Quantities", y = "Sample Quantiles")

summary_table_1 <- data.filtered %>%
  group_by(half, department) %>%
  summarise(count = n(),
            mean = mean(actual_productivity),
            median = median(actual_productivity),
            min = min(actual_productivity),
            max = max(actual_productivity),
            sd = sd(actual_productivity),
            .groups = 'keep'
  )

ggsave(paste0(opt$out_dir, "/pair_plots.png"),
       pair_plots)
write_csv(data.filtered, "data/filtered_data.csv")
ggsave(paste0(opt$out_dir, "/day_boxplot.png"),
       day_boxplot)
ggsave(paste0(opt$out_dir, "/half_boxplot.png"),
       half_boxplot)
ggsave(paste0(opt$out_dir, "/department_boxplot.png"),
       department_boxplot)
ggsave(paste0(opt$out_dir, "/actual_productivity_distribution.png"),
       actual_productivity_distribution)
ggsave(paste0(opt$out_dir, "/actual_productivity_qqplot.png"),
       actual_productivity_qqplot)
write_csv(summary_table_1, paste0(opt$out_dir, "/summary_table_1.csv"))