library(data.table)
source("~/Projects/peaky/common.R")

d <- "/scratch/wallace/peaky/derived"
files <- list.files(d,pattern="raw.RData")
message("files found: ",length(files))
print(files)

DATA <- vector("list",length(files))
names(DATA) <- sub("-raw.RData","",files)
for(i in seq_along(files)) {
    f <- files[i]
    message("loading ",f)
    (load(file.path(d,f)))
    DATA[[i]] <- raw$residual
}

message("plotting")

f <- function(x,npoints=100000) {
    y <- sort(x)
    n <- length(x)
    idx <- round(seq(1,n,length.out=npoints))
    x <- idx/(n+1)
    data.frame(x=qnorm(x[-1]),y=y[idx[-1]])
}

qqdata <- lapply(DATA,f,npoints=10000)
lapply(qqdata,dim)

for(i in seq_along(qqdata)) {
    qqdata[[i]]$ti <- title[[i]]
}
lapply(qqdata,head,2)
lapply(qqdata,tail,2)
df <- do.call("rbind",qqdata)
df$posneg <- ifelse(df$y>0,"positive","negative")
#df$y <- abs(df$y)
#df$x <- abs(df$x)

library(ggplot2)
library(cowplot)
ggplot(df,aes(x=x,y=y)) +
geom_abline(col="grey") +
geom_vline(xintercept=0,col="grey") +
geom_hline(yintercept=0,col="grey") +
geom_vline(xintercept=2,linetype="dashed") +
geom_hline(yintercept=2,linetype="dashed") +
geom_point(#aes(col=posneg),
size=0.8) +
facet_wrap(~ti) +
#background_grid() +
#scale_colour_manual("Sign of residual",values=c("positive"="red", "negative"="black")) +
scale_x_continuous("Expected quantile",limits=c(-8,8),breaks=seq(-8,8,by=4)) +
scale_y_continuous("Observed quantile",limits=c(-8,8),breaks=seq(-8,8,by=4)) +
theme(legend.position="bottom")

ggsave(file.path(d,"../figures","NB-residuals-qqplots.pdf"),
       height=8,width=8)
       
