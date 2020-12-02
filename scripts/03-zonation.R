# 03 Zonation
# ———————————
# I want to define diatom assemblage zones within the record so that it is 
# easier to describe and compare with other sequences. This is done through a 
# cluster analysis that identifies stratigraphically adjacent 
# samples that contain similar diatom assemblages. The analysis chosen is the 
# Constrained Incremental Sum of Squares (CONISS) method as outlined by Grimm 
# (1987). First, a matrix of dissimilarities between samples is computed. The 
# CONISS algorithm then computes a statistic known as the "sum of squares"* 
# between each pair of adjacent samples (each sample can be considered a cluster 
# of just one sample at this stage). The pair with the smallest sum of squares 
# is joined into a cluster and then the sum of squares is recalculated for all 
# samples with these newly joined samples recieving one sum of squares value for 
# their newly formed cluster. The clusters with the smallest sum of squares is 
# joined and the sum of squares recalulated. This process continues, clustering 
# samples into successively larger groups (it is therefore an agglomerative 
# technique).

# * The sum of squares is the squared difference between the value of a taxon in 
# one sample of a cluster divided by the average value of that taxon across all 
# samples in that cluster, which is then summed for each taxon, which is then 
# summed for each sample in the cluster.

# Prior to learning how to use R, I had performed a cluster analysis on these 
# data using the CONISS algorithm (Grimm, 1987) that had been built into the 
# Tilia program (Grimm, 2011). I have performed a similar analysis here so that
# the diatom assemblage zones that I defined on the basis of that original 
# analysis remain as close to their original ones as possible.




# 1. Load requirements ----------------------------------------------------

library(rioja) # for chclust()

source("scripts/02-manipulate.R")




# 2. Calculate distances between samples ----------------------------------

# Steps:
#
# — Samples containing no diatoms are removed. 
#
# — The percentage relative abundances are divided by 100 to transform them to 
#   unit proportions (i.e. out of 1.0). This step is only necessary to keep the 
#   result the same as the one I obtained from Tilia. If this step is not done, 
#   the dendrogram looks the same except the x-axis values are just 100 times 
#   larger.
#
# — The data are then square-root transformed. This step is necessary as the 
#   record is dominated by one taxon (P. ocellata). Square-root transforming 
#   ensures the less abundant taxa play a more important role in the cluster 
#   analysis than they would otherwise. My supervisor says this is what you must 
#   always do and reading around the literature it does seem to be standard 
#   practice for diatom abundance data.
#
# — The squared Euclidean distance between samples is then calculated. This 
#   dissimilarity index is used because it is the one that the Tilia program
#   uses and once again I am trying to match the results I previously obtained.
#   Grimm (1987) says that the combination of square-root transforming and then
#   calculating the squared Euclidean distance has proved "particularly 
#   satisfactory" for abundance data.

dist_matrix <- taxa$rel_ab_4 %>%
  # add depths to data frame
  mutate(
    depth = imported$depths$depth,
    sample_no = NULL
  ) %>%
  # remove samples with no diatoms
  column_to_rownames("depth") %>%
  # transform data (to proportions out of 1.0 then square root)
  filter(., rowSums(.) > 0) %>% 
  `/`(100) %>% 
  sqrt() %>%
  # remove outlier
  rownames_to_column("depth") %>%
  mutate(depth = as.numeric(depth)) %>%
  slice(., -44) %>%
  column_to_rownames("depth") %>%
  # calculate squared euclidean distances
  designdist(., method = "A+B-2*J", terms = "quadratic")




# 3. Run cluster analysis -------------------------------------------------

clusters <- chclust(dist_matrix, method = "coniss")

# bstick(clusters, ng = 30)
# 11 statistically significant zones




# 4. Quick plot of dendrogram to check ------------------------------------

# library(ggdendro)
# library(ggplot2)
# ddata <- dendro_data(clusters, type = "rectangle")
# ggplot(segment(ddata)) +
#   geom_segment(aes(x = x, y = y, xend = xend, yend = yend)) +
#   coord_flip() +
#   scale_x_reverse() +
#   labs(title = "Final dendrogram",
#        subtitle = "(taxa ≥4 %,\nno P. ocellata split\noutlier removed)",
#        x = "Depth (m)",
#        y = "Total sum of squares") +
#   theme(aspect.ratio = 3) +
#   geom_hline(yintercept = 13.2)



