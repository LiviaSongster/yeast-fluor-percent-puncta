# select Percent-Puncta-Results
rm(list=ls()) # clears R environment
# use line 4 for windows
# setwd(choose.dir(default = "Y:/LiviaSongster/07-Scripts-macros/imageJ macro/perc-puncta-for-neallab/Percent-Puncta-Results", caption = "Select Percent-Puncta-Results"))

# ideal outputs
#save the names of the files you want to import
file_names <- list.files(path = ".", full.names = FALSE, recursive = FALSE) #where you have your files
#combines all the csv files and adds a column at the end with the name of the file the data came from
# install.packages("data.table")
library(data.table)
df.colnames <- c("File.Name","Strain","Cell.ID","Sum.Puncta.Int.Den","Whole.Cell.Int.Den","Fraction.Puncta.Int.Den",
                 "Number.Puncta","Avg.Puncta.Area.um2","Total.Puncta.Area.um2","Whole.Cell.Area.um2","Puncta.Per.um2","Fraction.Puncta.Cell.Area")

finaldf <- data.frame(matrix(ncol = length(df.colnames), nrow = (length(file_names)/2)))
colnames(finaldf) <- df.colnames
cellfiles <- file_names[grep("totalcell",file_names)]
punctafiles <- gsub("totalcell", "puncta", cellfiles)



for (x in 1:length(punctafiles)){
  temp_puncta <- read.csv(punctafiles[x])
  temp_cell <- read.csv(cellfiles[x])
  # start populating the finaldf
  # file name
  finaldf[x,1] <- punctafiles[x]
  # strain
  finaldf[x,2] <- strsplit(punctafiles[x],'_')[[1]][2]
  # cell id
  finaldf[x,3] <- strsplit(punctafiles[x],'_')[[1]][1]
  # sum puncta int den
  finaldf[x,4] <- sum(temp_puncta[,6])
  # whole cell int den
  finaldf[x,5] <- temp_cell[,6]
  # Fraction.Puncta.Int.Den
  finaldf[x,6] <- finaldf[x,4] / finaldf[x,5]
  # Number.Puncta
  finaldf[x,7] <- max(temp_puncta[,1])
  # Avg.Puncta.Area.um2
  finaldf[x,8] <- mean(temp_puncta[,2])
  # Total.Puncta.Area.um2
  finaldf[x,9] <- sum(temp_puncta[,2])
  # Whole.Cell.Area.um2
  finaldf[x,10] <- temp_cell[,2]
  # Puncta.Per.um2
  finaldf[x,11] <- finaldf[x,7] / temp_cell[,2]
  # Fraction.Puncta.Cell.Area
  finaldf[x,12] <- finaldf[x,9] / finaldf[x,10]
  rm(temp_puncta,temp_cell)
}
write.csv(finaldf,"../Compiled_perc_puncta_prism.csv")
