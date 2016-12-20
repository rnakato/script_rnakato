library("sleuth")
library("biomaRt")

options(mc.cores = 4L) # CPU number

# Data
s2c <- read.table("kallistotable.txt", header = T, stringsAsFactors=F)
s2c <- dplyr::select(s2c, sample = sample, condition)
s2c <- dplyr::mutate(s2c, path = paste("kallisto/", s2c$sample, "/abundance.h5", sep=""))
s2c

# Annotation
mart <- biomaRt::useMart(biomart = "ENSEMBL_MART_ENSEMBL", dataset = "hsapiens_gene_ensembl", host = 'ensembl.org')
t2g <- biomaRt::getBM(attributes = c("ensembl_transcript_id", "ensembl_gene_id", "external_gene_name"), mart = mart)
t2g <- dplyr::rename(t2g, target_id = ensembl_transcript_id, ens_gene = ensembl_gene_id, ext_gene = external_gene_name)

# Execution
so <- sleuth_prep(s2c, ~ condition, target_mapping = t2g)
#so <- sleuth_prep(s2c, ~ condition)
so <- sleuth_fit(so)
so <- sleuth_fit(so, ~1, 'reduced')
so <- sleuth_lrt(so, 'reduced', 'full')
models(so)

sleuth_live(so)
results_table <- sleuth_results(so, 'reduced:full', test_type = 'lrt')


# Gene level analysis
so <- sleuth_prep(s2c, ~condition, target_mapping = t2g, aggregation_column = 'ens_gene')
