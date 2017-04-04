library(ggplot2)
library(scales)

dfp <- read.csv(file="../data/aggregates/aggregate_downloads_journal.txt",head=F,sep="\t")

plot1 <- ggplot(subset(dfp,dfp$V1 != "error resolving"),aes(x=reorder(V1,V2),y=V2)) +
  geom_point() +
  scale_x_discrete("Journal, sorted by #") +
  scale_y_continuous("# of papers downloaded from SciHub",labels=comma) +
  theme_minimal() +
  theme(text=element_text(size=30),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_blank()
        )

ggsave("supplementary_figure_4_bottom.pdf",width=19.6, height=11.5)

plot2 <- ggplot(subset(dfp,dfp$V2 > 54000 & dfp$V1 != "error resolving"),aes(x=reorder(V1,V2),y=V2)) +
  geom_bar(stat="identity") +
  scale_x_discrete("Journal, sorted by #") +
  scale_y_continuous("# of papers downloaded from SciHub",labels=comma) +
  theme_minimal() +
  theme(text=element_text(size=20),
        axis.text=element_text(size=20),
        axis.text.x = element_text(angle = 45, hjust = 1.0))

  ggsave("figure2_bottom.pdf",width=19.6, height=11.5)
