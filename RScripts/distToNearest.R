# Imports
library(alakazam)
library(shazam)
library(ggplot2)

# Read in database file
db <- readChangeoDb('/home/ian/NextGenSeq/Greiff2014_2/output/HighVQuestOutput/Greiff2014_db-pass_parse-select_clone-pass_germ-pass.tab')
# Calculate distance to nearest neighbor
db <- distToNearest(db, model="m1n", symmetry="min")
# Plot resulting histogram with vertical threshold line
p1 <- ggplot() + theme_bw() + 
  ggtitle("Distance to nearest: m1n") + xlab("distance") +
  geom_histogram(data=db, aes(x=DIST_NEAREST), binwidth=0.025, 
                 fill="steelblue", color="white") + 
  geom_vline(xintercept=0.25, linetype=2, color="red")
plot(p1)

