library(beanplot)
library(DescTools)

tool_bar_chart <- function(builds) {
  builds <- builds[!is.na(builds$status), ]
  success <- prop.table(table(builds$status, builds$tool), 2)
  success <- apply(success, 2, rev)
  
  print(success)
  
  pdf("figures/tool-status.pdf", 4.5, 1)
  par(mar=c(1.8, 3.5, 0, 6.5), mgp=c(3, 0.5, 0), xpd=T)
  barplot(success, horiz=T, las=1, legend.text=c("success", "failure"), col=c("gray85", "gray30"),
    args.legend=list(x=1.5, y=3.5), axes=F)
  y_labels <- seq(0, 1, by=0.25)
  axis(side=1, at=y_labels, labels=to_percent(y_labels))
  dev <- dev.off()
}

tool_association <- function(builds) {
  builds <- builds[!is.na(builds$status), ]
  contingency <- table(builds$status, builds$tool)
  test <- chisq.test(contingency)
  
  cat("\ntool / success:\n")
  cat(sprintf("p-value: %s\n", test$p.value))
  cat(sprintf("Cramer's V: %s (df=%s)\n\n", CramerV(contingency), test$parameter))
}

association <- function(builds, variable, label) {
  builds <- builds[!is.na(builds$status), ]
  column <- builds[, variable]
  status <- builds$status
  
  threshold <- min(boxplot.stats(column)$out)
  beanplot(column[status], column[!status], side="both", names="passed vs. failed", log="",
    ylim=c(0, threshold), what=c(F, T, T, F), beanlines="median", col=list("gray85", "gray30"))
  mtext(label, line=0.5)
  
  cat(sprintf("%s / success:\n", variable))
  cat(sprintf("Mean success: %f, fail: %f\n", mean(column[status]), mean(column[!status])))
  cat(sprintf("Median success: %f, fail: %f", median(column[status]), median(column[!status])))
  print(wilcox.test(column[status], column[!status]))
}

count_dates <- function(builds, variable) {
  dates <- as.POSIXlt(builds[, variable], tz="GMT")
  newest <- max(dates)
  builds[, variable] <- as.numeric(newest - dates, unit="days")
  builds
}

all_associations <- function(builds) {
  pdf("figures/assoc.pdf", 8.4, 5)
  par(mfrow=c(1, 4), mar=c(2, 2, 2, 1.3), mgp=c(3, 0.5, 0), cex=1)

  association(builds, "in_files", "file count")
  association(builds, "stars", "stars")
  
  builds <- count_dates(builds, "created")
  association(builds, "created", "age [days]")
  builds <- count_dates(builds, "pushed")
  association(builds, "pushed", "last update [days]")
  
  dev <- dev.off()
}

tool_properties <- function (builds) {
  builds <- count_dates(builds, "created")
  builds <- count_dates(builds, "pushed")
  print(aggregate(builds[, c('created', 'pushed', 'in_files')], list(builds$tool), mean))
  
  builds <- builds[builds$status %in% F,]
  maven <- builds[builds$tool == 'Maven', ]
  dep <- maven[maven$error_category %in% 'dependencies', ]
  cat(sprintf("\nFailed Maven builds caused by dep.: %s\n", to_percent(nrow(dep) / nrow(maven))))
}
