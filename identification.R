library(tidyverse)

# set work path
wkdir = ""
setwd(wkdir)

# set save path
save_path = ""

# define the candiate
candi = "candidate.358"
fid = "candidate"

# create the ASD/EUD proportion result file
commercial_breed = c("Duroc", "Landrace", "Yorkshire")
write.table(matrix(c("EUD", "ASD", "iid", "fid"), 1, 4), 
            paste0(save_path, "/candidate_ASD_EUD_proportion.txt"), 
            row.names = F, col.names = F, quote = F)

setwd(paste0(wkdir, "/", candi)) # set the data path
iid = gsub("candidate.", "", candi) # get the candidate ID

results = list.files(pattern = ".Q$") # get the result file name

# extract the ASD and EUD proportion
i = 1
fam = read.table(paste0(gsub("[.].*", "", results[i]), ".fam"))
result = read.table(results[i])

# define the ASD and EUD by breed information
fam$label[fam$V1 %in% commercial_breed] = "EUD"
fam$label[fam$V1 == fid] = "candidate"
fam$label[is.na(fam$label)] = "ASD"

# calculate the average of ASD and EUD proportion
data = data.frame(fid = fam$V1, iid = fam$V2, result, group = fam$label)
data = aggregate(data, list(data$group), mean)
rownames(data) = data$Group.1
data = data[, 4:5]

# define the ASD and EUD proportion by the structure results
ttt = c(which(data[which(rownames(data) == "EUD"), ] == max(data[which(rownames(data) == "EUD"), ])), 
        which(data[which(rownames(data) == "ASD"), ] == max(data[which(rownames(data) == "ASD"), ])))
data = data[which(rownames(data) == "candidate"), ttt]
data$iid = iid
data$fid = "Duroc×Diannanxiaoer"
colnames(data) = c("EUD", "ASD", "iid", "fid")

# save the ASD and EUD proportion results
write.table(data, paste0(save_path, "/candidate_ASD_EUD_proportion.txt"), 
            row.names = F, col.names = F, quote = F, append = T)

#----------------------------------------------------------------------------
# summarize the breed-level proportion for each indigenous breed
res = matrix(NA, length(results) - 1, 4)
for(i in 2:length(results)){
  # i = 2
  fam = read.table(paste0(gsub("[.].*", "", results[i]), ".fam"))
  result = read.table(results[i])
  
  native_breed = gsub("[.].*", "", results[i]) # get the indigenous breed information
  
  # calculate the average of D/L/Y/indigenous_breed proportion
  data = data.frame(fid = fam$V1, iid = fam$V2, result)
  data = aggregate(data, list(data$fid), mean)
  rownames(data) = data$Group.1
  data = data[, 4:8]
  
  # define the breed proportion according to the maximum ancestry proportion
  ttt = c(which(data[which(rownames(data) == "Duroc"), ] == max(data[which(rownames(data) == "Duroc"), ])), 
          which(data[which(rownames(data) == "Landrace"), ] == max(data[which(rownames(data) == "Landrace"), ])), 
          which(data[which(rownames(data) == "Yorkshire"), ] == max(data[which(rownames(data) == "Yorkshire"), ])), 
          which(data[which(rownames(data) == native_breed), ] == max(data[which(rownames(data) == native_breed), ])))
  
  res[i - 1, ] = as.numeric(data[which(rownames(data) == "candidate"), ttt])
}
res = data.frame(res)
colnames(res) = c(commercial_breed, "native_breed")
res$unknown = 1 - rowSums(res)

rownames(res) = gsub("[.].*", "", results[2:length(results)])
res = arrange(res, desc(native_breed), desc(unknown))

# save the breed-level results
write.csv(res, paste0(save_path, "/", iid, ".csv"))




