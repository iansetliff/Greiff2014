library(alakazam)

# Load Change-O file
df <- readChangeoDb('/home/ian/NextGenSeq/Greiff2014/output/HighVQuestOutput/Greiff2014_db-pass_parse-select_clone-pass_germ-pass.tab')

# Partitions the data based on the SAMPLE column
clones <- countClones(df, groups="CPRIMER")
head(clones, 5)

# Partitions the data based on both the SAMPLE and ISOTYPE columns
# Weights the clone sizes by the DUPCOUNT column
clones <- countClones(df, groups="CPRIMER", copy="DUPCOUNT")
head(clones, 5)

# Partitions the data on the SAMPLE column
# Calculates a 95% confidence interval via 200 bootstrap realizations
clones <- estimateAbundance(df, group="CPRIMER", ci=0.95, nboot=200)

# Plots a rank abundance curve of the relative clonal abundances
p1 <- plotAbundance(clones)

# Compare diversity curve across values in the "SAMPLE" column
# q ranges from 0 (min_q=0) to 32 (max_q=32) in 0.05 incriments (step_q=0.05)
# A 95% confidence interval will be calculated (ci=0.95)
# 2000 resampling realizations are performed (nboot=200)
sample_div <- rarefyDiversity(df, "CPRIMER", min_q=0, max_q=32, step_q=0.05, 
                              ci=0.95, nboot=200)

# Plot a log-log (log_q=TRUE, log_d=TRUE) plot of sample diversity
# Indicate number of sequences resampled from each group in the title
sample_main <- paste0("Sample diversity ")
p2 <- plotDiversityCurve(sample_div, main_title=sample_main, 
                         legend_title="Sample", log_q=TRUE, log_d=TRUE)