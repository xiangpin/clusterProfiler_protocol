# loading pkg
library(MicrobiotaProcess)
# 2 omics clinical info
meta_mb <- read.csv("IBD_2_subtypes_example/input_data/metabolism_meta.csv",
                    header = TRUE)
meta_mg <- read.csv("IBD_2_subtypes_example/input_data/mg.meta.csv",
                    header = TRUE)

# read 2 omics expression data
metabolism <- read.csv("IBD_2_subtypes_example/input_data/metabolism_expr.csv",
                       row.names = 1,
                       header = TRUE,
                       check.name = FALSE)
metagenome <- read.csv("IBD_2_subtypes_example/input_data/mg.expr.csv",
                       row.names = 1,
                       header = TRUE,
                       check.name = FALSE)

# difference analysis function
DA <- function(expr, meta, DAgroup, filter_p = "fdr", filter_group) {
  mpse <- MPSE(expr)
  mpse <- mpse %>% left_join(meta, by = c("Sample" = "sample"))
  result <- mpse %>%
    filter(Diagnosis %in% DAgroup) %>%
    mp_diff_analysis(
      .abundance = Abundance,
      .group = Diagnosis,
      force = TRUE,
      relative = FALSE,
      filter.p = filter_p
    ) %>%
    mp_extract_feature() %>%
    filter(Sign_Diagnosis == filter_group) %>%
    pull(OTU)
}

# Metagenomic differential analysis
cd_mg <- DA(expr = metagenome, meta = meta_mg,
            DAgroup = c("Control", "CD"),
            filter_group = "CD",
            filter_p = "pvalue")
uc_mg <- DA(expr = metagenome, meta = meta_mg,
            DAgroup = c("Control", "UC"),
            filter_group = "UC",
            filter_p = "pvalue")
mg <- list(cd = cd_mg, uc = uc_mg)

# Save the drawing data needed
saveRDS(mg, "IBD_2_subtypes_example/result/IBD.gene.mpse.rds")


# Metabolomic differential analysis
cd_mb <- DA(expr = metabolism, meta = meta_mb,
            DAgroup = c("Control", "CD"),
            filter_group = "CD")
uc_mb <- DA(expr = metabolism, meta = meta_mb,
            DAgroup = c("Control", "UC"),
            filter_group = "UC")
mb <- list(cd = cd_mb, uc = uc_mb)
# Save the drawing data needed
saveRDS(mb, "IBD_2_subtypes_example/result/IBD.cpd.mpse.rds")
