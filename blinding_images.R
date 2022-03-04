# first make random list of words for blinding, and save it as random.csv
# have one random word for each file you want to rename
# https://www.randomlists.com/random-words
# save this file ONE FOLDER LEVEL ABOVE where your files are

# change dir to location of files
setwd(choose.dir(default = "C:\Users\Livia Songster\Documents\JasmineRachelImageAnalysis", caption = "Select folder with all analysis dirs"))

# define file type
filetype <- readline(prompt="Enter filetype of ALL files in the directory: ")


files <- list.files()
wd <- getwd()

# go up one directory level where all the new filenames are saved in csv called "random.csv"
setwd("..")
random <- read.csv("random.csv",header=FALSE)$V1

random <- random[1:length(files)] # make sure both files and random have the same length/number of values

#change back to dir of files to blind
setwd(wd)

#rename files
file.rename(files,paste0(random,filetype))

#save names of files + random name as key
df <- ""
df$File <- files
df$RandomName <- random
setwd("..")
write.csv(df,"Blinding-Key.csv")
