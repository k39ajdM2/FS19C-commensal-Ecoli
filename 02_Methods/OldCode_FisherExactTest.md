# 06 Fisher Exact Test
* Summary: Use output from Roary to run through R script.
* Platform: R

1. Modify `gene_presence_absence.Rtab` similar to `https://github.com/k39ajdM2/Notebook/tree/main/Files/BraddHaley_SampleMatrix.csv` and save as `Matrix.csv`. Modifications include:
  * Rename 1st column heading to `ID`.
  * Add a second row `Rstatus` and label respective group name for each strain. Try to group strains of the same group together (helps make it easier to call specific columns for a group in R script)

2. Run `Matrix.csv` through `FisherExactTest.R`. You will need to modify the code to fit with number of columns and rows for each group and gene in `EcoliMatrix.csv`

  <details><summary>FisherExactTest.R script</summary>

  #####################################################################################################
  #FS19C - comparison of STEC and commensal E. coli pan-genomes
  #Kathy Mou

  #Purpose: Use gene_presence_absence.Rtab generated by roary to identify differences in abundance of genes between STEC and commensal E.coli isolates. Adapted from Bradd Haley.

  #Install libraries
  library(tidyverse)
  library(exact2x2)
  # exact2x2 produces p-values, odds ratios, and odds ratio confidence intervals.

  # library("devtools","BiocManager")
  # BiocManager::install("qvalue")

  library(qvalue)
  # qvalue package adjusts the exact2x2 p-values for false discovery rate (FDR).
  # The vignette can be viewed by typing:
  # browseVignettes(package = "qvalue")

  # Read more about purrr function (much like sapply): https://jennybc.github.io/purrr-tutorial/


  # Read the row of com and stec labels from the CSV spreadsheet, to identify the range of columns for each label.
  lbltype <- read.csv("./Files/EcoliMatrix.csv",header=FALSE,skip=1,nrows=1) # header is false and becomes 1st row, skip 1st row, only print 2nd row (Rstatus)

  # Pull commensals "com" label
  com <- lbltype[]=="com" #pull the com label
  com
  dim(com) # 1 234
  com[1:99]  # Columns   2:99 (i.e.,  98) are com
  com[100:234] # Columns 100:234 (i.e., 135) are stec

  # Skip column headings and com/stec labels; read 1/0 presence/absence data values.
  genomes <- read.csv("./Files/EcoliMatrix.csv",header=FALSE,skip=2) # header is false and becomes 1st row, skip first two rows

  # Assign genome names from the first column to be the rownames for the data object.
  rownames(genomes) <- genomes[,1]

  # Create an empty list.  Each element of this list will store Fisher Exact Test results one genome.
  lst.exact2x2 <- c()

  # Loop over each genome to sum the present and absent counts for com and for stec
  # row = gene names
  for (i in 1:nrow(genomes))
  {
    # Count of com Samples
    genomes[i,235] <- sum(genomes[i,2:99])

    # Count of Not com Samples
    genomes[i,236] <- 98-genomes[i,235]

    # Count of stec Samples
    genomes[i,237] <- sum(genomes[i,100:234])

    # Count of Not stec Samples
    genomes[i,238] <- 135-genomes[i,237]

    # Create a 2x2 matrix containing presence/absence counts to be used by exact2x2
    xi <- matrix(c(genomes[i,235],genomes[i,236],genomes[i,237],genomes[i,238]),nrow=2,ncol=2)

    # Save exact test results for each genome into an element of the list.
    lst.exact2x2[[i]] <- exact2x2(xi,tsmethod="central") # Reference: https://cran.r-project.org/web/packages/exact2x2/exact2x2.pdf
    # central includes confidence interval. Xi must be a 2x2 matrix with nonnegative integers


    # Assign the Genome ID to an element of the list, for ID and labeling purposes.
    lst.exact2x2[[i]]$genomeID <- as.character(genomes[i,1]) # genomes[i,1] prints the first column (also rowname in this case)

  }

  #For myself to experiment what the sections of the script above do - ignore this section
  #genomes[i,235] # 98 aka Count of com Samples
  #sum(genomes[i,2:99]) # 98 aka Count of com Samples
  #genomes[i,236] # 0 aka Count of Not com Samples
  #98-genomes[i,235] # 0 aka Count of Not com Samples
  #sum(genomes[i,100:234]) # 134 aka Count of stec Samples
  #genomes[i,237] # 134 aka Count of stec Samples
  #135-genomes[i,237]] #1 aka Count of Not stec Samples
  #genomes[i,238] #1 aka Count of Not stec Samples

  # Count Sums and proportions
  count.sums <- data.frame(genomes[,235],genomes[,236],genomes[,237],genomes[,238])
  colnames(count.sums) <- c("com.yes","com.no","stec.yes","stec.no") # assign column names to columns 235, 236, 237, 238

  prop.com <- genomes[,235]/(genomes[,235]+genomes[,236]) # proportion of com.yes / (com.yes + com.no)
  prop.stec <- genomes[,237]/(genomes[,237]+genomes[,238]) # proportion of stec.yes / (stec.yes + stec.no)

  count.sums <- data.frame(count.sums, prop.com, prop.stec) # add prop.com and prop.stec with count.sums dataframe


  # Create a data frame from the content of the exact2x2 list.
  p.values <- sapply(lst.exact2x2, function(x){as.numeric(x[1])}) # sapply applies a function over a matrix/vector

  #Sapply applies a function to a list, here that function is as.numeric(x[1]) and apply it to the items in the lst.exact2x2 -  lst.exact2x2 is a list of lists I believe where each item in the list is the genome and each item is another list with the results for that genome. So sapply applies the function to each of the first elements of the sublist, which are the p-values associated with each genome. The function as.numeric(x[1]) is converting the format of the item to a number (I’m not sure what the format was originally). I believe the output is a new list of numbers


  orci <- sapply(lst.exact2x2, function(x){as.numeric(x[2][[1]])})
  # Similar to above, sapply is applying the function to every item in a list. Here I think it is actually three orders – a list of a list of a list. So its applying the function as.numeric on what I believe is the confidence interval. So, its converting it from another format to a number


  str(orci) # compactly display internal structure of R object
  orlcl <- orci[1,] # pull out row 1 aka lower confidence level
  orucl <- orci[2,] # pull out row 2 aka higher confidence level

  or <- sapply(lst.exact2x2, function(x){as.numeric(x[3])})
  # Converting the odds ratio (3rd item in the list) for each genome results into a number (as.numeric) and saving them in a list
  # Odds ratio: https://www.statisticshowto.com/probability-and-statistics/probability-main-index/odds-ratio/

  gid <- sapply(lst.exact2x2, function(x){as.character(x[8])}) # what does this do?
  # Similar to above but instead of applying the function as.numeric to each item, it is applying the function as.character to each item – converting from another format into a string. Here, it is applying the function the genome ID or 8th element in the list

  # "exact.results" contains all results from the exact2x2 Fisher's Exact tests, for each genome.
  # BUT, these p-values should be adjusted to protect against false significance caused by conducting
  # X individual tests, each with 5% probability of false significance.
  exact.results <- data.frame(gid, p.values, count.sums, or, orlcl, orucl)

  original.order <- seq(1:nrow(exact.results))
  # what is the purpose of this?  I am not too sure here, but I think it is saving the order of the exact.results dataframe and using it to reorder subsequent results in the same order


  # The following code conducts an FDR adjustment (i.e., calculates q-values) for each genome.
  q.obj <- qvalue(p=exact.results$p.values) # qvalue measures proportion of false positives when a test is called significant

  # The summary function indicates the number of genomes exhibiting significance based on each
  # of the 3 criteria:  p-value, q-value, local FDR;  where column heading indicates alpha level.

  summary(q.obj)

  #plot(q.obj)

  q.obj$pi0 # 1

  qv <- q.obj$qvalues

  q.exact.results <- data.frame(original.order, exact.results, qv)

  sigq.order <- order(q.exact.results$qv) # order returns a permutation which rearranges its first argument into ascending or descending order

  ord.q.exact.results <- q.exact.results[sigq.order,] # match by rows when combining sigq.order with q.exact.results. That's why pvalues don't match (not in the same order!)

  ord.q.exact.results$sig.order <- seq(1:nrow(ord.q.exact.results)) # order by qv values in ascending order

  # Write the results to a csv file.
  write.csv(ord.q.exact.results, "STECcommensal_Genome2x2ExactTestq-values-SortedFromMostToLeastSignificant.csv")
  </details>

3. After reviewing the results in csv file, we decided they were not as helpful. We refocused our approach and are more interested in seeing what sugar utilization pathway genes are present in STEC that are also found in commensals - find which commensals these are.