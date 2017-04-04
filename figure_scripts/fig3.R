library(ggplot2)
library(scales)
library(reshape2)


# read data

df <- read.csv(file="../data/aggregates/aggregate_merged_publisher.txt",sep="\t",head=F)

# subset to remove missing data

df_sub <- subset(df,df$V1 != "-" & df$V1 != "")

# rename columns
df_sub$category <- df_sub$V3
df_sub$publisher <- df_sub$V1
df_sub$count <- df_sub$V2

# calculate new columns
# percent: % of papers in category for publisher
# total: sum of all papers in that category

df_sub$percent <- 0
df_sub$total <- 0

df_sub$percent[df_sub$V3 == "downloaded"] <- df_sub$V2[df_sub$V3 == "downloaded"] / sum(subset(df_sub,df_sub$V3 == "downloaded")$V2)
df_sub$total[df_sub$V3 == "downloaded"] <- sum(subset(df_sub,df_sub$V3 == "downloaded")$V2)

df_sub$percent[df_sub$V3 == "corpus"] <- df_sub$V2[df_sub$V3 == "corpus"] / sum(subset(df_sub,df_sub$V3 == "corpus")$V2)
df_sub$total[df_sub$V3 == "corpus"] <- sum(subset(df_sub,df_sub$V3 == "corpus")$V2)

# drop old columns

df_sub$V2 <- NULL
df_sub$V1 <- NULL
df_sub$V3 <- NULL

# transform long dataframe into wide
wide_df <- dcast(melt(df_sub, id.vars=c("publisher", "category")), publisher~variable+category)

# replace all NA with 0, these are all publishers with 0 downloads, thus NA in
# transformation

wide_df$count_downloaded[is.na(wide_df$count_downloaded)] <- 0

# add column for total number of downloads, needed for binomial test

wide_df$total_downloaded <- sum(subset(df_sub,df_sub$V3 == "downloaded")$V2)

# drop all rows with NA in % present in corpus

wide_df <- subset(wide_df, !is.na(wide_df$percent_corpus))

# initialize empty numeric vector for binomial test
pvalues <- numeric()

# perform binomial test: (this takes hours, be warned)
# iterate over each row, perform test, get pvalue for the row,
# append result to pvalues-vector

for(i in unique(wide_df$publisher)){
  data_point = subset(wide_df,wide_df$publisher == i)
  pvalue = binom.test(data_point$count_downloaded,data_point$total_downloaded,data_point$percent_corpus)$p.value
  pvalues <- c(pvalues,pvalue)
  print(i)
}

# once all tests are done: add pvalues-vector as column to wide dataframe,
# do FDR correction

wide_df$pvalues.binom <- pvalues
wide_df$pvalues.binom.fdr <- p.adjust(wide_df$pvalues.binom,method="fdr")

# copy whole DF, just in case

backup <- wide_df

# add category for publishers, mark all publishers with < 300,000 downloads
# as "other"
backup$category<- as.character(backup$publisher)
backup$category[backup$count_downloaded <= 300000] <- "other"

# write table containing all data to disk

write.table(backup,"../data/aggregate/aggregate_finished_binomial.csv",sep="\t", row.names = FALSE,quote=FALSE)

# get subset of significantly different publishers, set % download to 0 for NA

significant_different <- subset(wide_df,wide_df$pvalues.binom.fdr <= 0.05)
significant_different$percent_downloaded[is.na(significant_different$percent_downloaded)] <- 0

# write only under/overrepresented publishers to disk as well

underrepresented <- subset(significant_different,significant_different$percent_corpus > significant_different$percent_downloaded)
overrepresented <- subset(significant_different,significant_different$percent_corpus < significant_different$percent_downloaded)
write.table(overrepresented,"../data/aggregate/overrepresented_publishers.csv",sep="\t", row.names = FALSE,quote=FALSE)
write.table(underrepresented,"../data/aggregate/underrepresented_publishers.csv",sep="\t", row.names = FALSE,quote=FALSE)

# get set of 15 most downloaded publishers that are over/underrepresented in
# comparison corpus/downloads

top15over <- subset(overrepresented, overrepresented$count_downloaded > 55000)
top15under <- subset(underrepresented,underrepresented$count_downloaded > 74000)

ggplot(top15over,aes(x=reorder(top15over$publisher,top15over$count_downloaded),y=top15over$count_downloaded)) +
  geom_bar(stat="identity") +
  scale_x_discrete("Overrepresented publishers, sorted by # of downloads") +
  scale_y_continuous("# of papers downloaded from SciHub",labels=comma) +
  theme_minimal() +
  theme(text=element_text(size=20),
        axis.text=element_text(size=20),
        axis.text.x = element_text(angle = 45, hjust = 1.0))

ggsave("figure3_top.pdf",width=19.6, height=11.5)

ggplot(top15under,aes(x=reorder(top15under$publisher,top15under$count_downloaded),y=top15under$count_downloaded)) +
  geom_bar(stat="identity") +
  scale_x_discrete("Underrepresented publishers, sorted by # of downloads") +
  scale_y_continuous("# of papers downloaded from SciHub",labels=comma) +
  theme_minimal() +
  theme(text=element_text(size=20),
        axis.text=element_text(size=20),
        axis.text.x = element_text(angle = 45, hjust = 1.0))

ggsave("figure3_bottom.pdf",width=19.6, height=11.5)

# plot top10 publishers downloaded

tmp <- as.data.frame(aggregate(backup$count_downloaded,by=list(backup$category),FUN=sum))
tmp$Group.1 <- reorder(tmp$Group.1,tmp$x)
tmp <- tmp[order(-tmp$x),]
tmp$Publisher <- "downloaded"
tmp$x/sum(tmp$x)
ggplot(tmp,aes(x=Publisher,y=x/sum(x),fill=as.factor(Group.1))) + geom_bar(stat="identity") + scale_fill_brewer(palette="Spectral","Publisher") + theme_minimal() + scale_y_continuous("Porportion")
ggsave("supplementary_figure_5_bottom.pdf")

# plot top10 publishers in corpus
tmp <- as.data.frame(aggregate(backup$count_corpus,by=list(backup$category),FUN=sum))
tmp$Group.1 <- reorder(tmp$Group.1,tmp$x)
tmp <- tmp[order(-tmp$x),]
tmp$Publisher <- "corpus"
tmp$x/sum(tmp$x)
tmp
ggplot(tmp,aes(x=Publisher,y=x/sum(x),fill=as.factor(Group.1))) + geom_bar(stat="identity") + scale_fill_brewer(palette="Spectral","Publisher") + theme_minimal() + scale_y_continuous("Porportion")
ggsave("supplementary_figure_5_top.pdf")
