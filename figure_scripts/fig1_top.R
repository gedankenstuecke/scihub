library(ggplot2)
library(scales)

# read data

df <- read.csv(file="../data/aggregates/aggregate_published_date.txt",sep="\t",head=F)

# convert years to numerical from factors, as includes missing data so far
df$V3 <- as.numeric(as.character(df$V1))

# subset for real dates and not nonsense

df_sub <- subset(df,df$V3 > 1000 & df$V3 < 2018)

# plot
ggplot(df_sub,aes(x=V3,y=V2)) +
  geom_line()+
  geom_vline(xintercept = 1918,color="red") +
  geom_vline(xintercept=1914,color="red") +
  geom_vline(xintercept=1939,color="red") +
  geom_vline(xintercept=1945,color="red") +
  scale_x_continuous("year of publication") +
  scale_y_continuous("# of articles in SciHub",labels = comma) +
  theme_minimal() +
  theme(text=element_text(size=40),
        axis.text=element_text(size=40),
        axis.text.x = element_text(angle = -25, hjust = 0.5))

ggsave("figure1_top.pdf",width=19.6, height=11.5)
